-- PawSure Insurance Pet Claims Analytics – Stored Procedures
-- Author: Soundarya S
-- Created Date: 2025-10-01
-- Description: All SPs for CRUD & ETL: Insert, Update, KPI, Stage Load, Stage→Fact ETL

USE PawSureDB;
GO


/****************************************************************************************
 Author        : Soundarya S
 Created Date  : 2025-10-01
 Purpose       : Insert a new insurance claim into FactClaim table.
 Business Need : PawSure must store every incoming claim from portal / API reliably
                 so that high-cost and fraud-prone claims can be analyzed downstream.
****************************************************************************************/
CREATE PROCEDURE paw.usp_InsertClaim
    @CustomerID INT,
    @PetTypeID INT,
    @PetAgeYears DECIMAL(4,1),
    @CityID INT,
    @ClinicID INT,
    @DiseaseID INT,
    @ClaimAmountUSD DECIMAL(10,2),
    @ClaimStatus VARCHAR(10),
    @SubmissionDate DATE
AS
BEGIN
    INSERT INTO paw.FactClaim
    (CustomerID, PetTypeID, PetAgeYears, CityID, ClinicID, DiseaseID,
     ClaimAmountUSD, ClaimStatus, SubmissionDate)
    VALUES
    (@CustomerID, @PetTypeID, @PetAgeYears, @CityID, @ClinicID, @DiseaseID,
     @ClaimAmountUSD, @ClaimStatus, @SubmissionDate);
END;
GO



/****************************************************************************************
 Author        : Soundarya S
 Created Date  : 2025-10-01
 Purpose       : Update status of claim after investigation.
 Business Need : PawSure Fraud/Risk Operations changes statuses (Pending→Approved/Rejected)
                 after verification. This SP centralizes status change logic.
****************************************************************************************/
CREATE PROCEDURE paw.usp_UpdateClaimStatus
    @ClaimID BIGINT,
    @NewStatus VARCHAR(10),
    @DaysToApprove INT = NULL
AS
BEGIN
    UPDATE paw.FactClaim
    SET ClaimStatus    = @NewStatus,
        DaysToApprove  = @DaysToApprove,
        ApprovalDate   = CASE WHEN @DaysToApprove IS NULL THEN NULL 
                              ELSE DATEADD(DAY,@DaysToApprove,SubmissionDate) END
    WHERE ClaimID = @ClaimID;
END;
GO



/****************************************************************************************
 Author        : Soundarya S
 Created Date  : 2025-10-01
 Purpose       : Return KPI metrics by city for dashboards.
 Business Need : Risk & Finance teams require city-level insights to identify cities
                 where high-cost / fraud-prone patterns are observed.
****************************************************************************************/
CREATE PROCEDURE paw.usp_GetCityKPI
AS
BEGIN
    SELECT * FROM paw.vKPI_AvgDaysToApproveByCity ORDER BY AvgDaysToApprove DESC;
END;
GO



/****************************************************************************************
 Author        : Soundarya S
 Created Date  : 2025-10-01
 Purpose       : Insert raw claim row into StageClaims table (EXTRACT step)
 Business Need : Raw messy claim records arrive daily from partner clinics (CSV/API).
                 Those raw claims must land in stage area first, THEN data quality
                 rules will standardize and load into FactClaim.
****************************************************************************************/
CREATE PROCEDURE paw.usp_Stage_InsertRawClaim
    @CustomerID       VARCHAR(20),
    @PetTypeName      VARCHAR(50),
    @PetAgeYears      VARCHAR(10),
    @CityName         VARCHAR(50),
    @ClinicName       VARCHAR(100),
    @DiseaseName      VARCHAR(200),
    @ClaimAmountUSD   VARCHAR(50),
    @ClaimStatus      VARCHAR(20),
    @SubmissionDate   VARCHAR(20)
AS
BEGIN
    INSERT INTO paw.StageClaims
    (CustomerID,PetTypeName,PetAgeYears,CityName,ClinicName,DiseaseName,ClaimAmountUSD,ClaimStatus,SubmissionDate)
    VALUES
    (@CustomerID,@PetTypeName,@PetAgeYears,@CityName,@ClinicName,@DiseaseName,@ClaimAmountUSD,@ClaimStatus,@SubmissionDate);
END;
GO



/****************************************************************************************
 Author        : Soundarya S
 Created Date  : 2025-10-01
 Purpose       : Transform raw stage data + Load into FactClaim
 Business Need : Raw clinic CSV files arrive in Azure Blob Storage. ETL pipeline loads 
                 them into StageClaims. This SP performs data quality, maps to dim tables,
                 and inserts valid rows into FactClaim for fraud/high-cost analysis.
****************************************************************************************/
CREATE PROCEDURE paw.usp_Stage_To_FactClaim_Load
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @CustomerID VARCHAR(20),
            @PetTypeName VARCHAR(50),
            @PetAgeYears VARCHAR(10),
            @CityName VARCHAR(50),
            @ClinicName VARCHAR(100),
            @DiseaseName VARCHAR(200),
            @ClaimAmountUSD VARCHAR(50),
            @ClaimStatus VARCHAR(20),
            @SubmissionDate VARCHAR(20);

    DECLARE cur CURSOR FOR
    SELECT CustomerID,PetTypeName,PetAgeYears,CityName,ClinicName,DiseaseName,ClaimAmountUSD,ClaimStatus,SubmissionDate
    FROM paw.StageClaims;

    OPEN cur;
    FETCH NEXT FROM cur INTO @CustomerID,@PetTypeName,@PetAgeYears,@CityName,@ClinicName,@DiseaseName,@ClaimAmountUSD,@ClaimStatus,@SubmissionDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @CityID INT = (SELECT CityID FROM paw.DimCity WHERE LOWER(CityName)=LOWER(LTRIM(RTRIM(@CityName))));
        DECLARE @ClinicID INT = (SELECT ClinicID FROM paw.DimClinic WHERE LOWER(ClinicName)=LOWER(LTRIM(RTRIM(@ClinicName))));
        DECLARE @PetTypeID INT = (SELECT PetTypeID FROM paw.DimPetType WHERE LOWER(PetTypeName)=LOWER(LTRIM(RTRIM(@PetTypeName))));
        DECLARE @DiseaseID INT = (SELECT DiseaseID FROM paw.DimDisease WHERE LOWER(DiseaseName)=LOWER(LTRIM(RTRIM(@DiseaseName))));

        IF @CityID IS NULL OR @ClinicID IS NULL OR @PetTypeID IS NULL OR @DiseaseID IS NULL
        BEGIN
            INSERT INTO paw.RejectLog
            (RawCustomerID,RawPetTypeName,RawPetAgeYears,RawCityName,RawClinicName,RawDiseaseName,
             RawClaimAmountUSD,RawClaimStatus,RawSubmissionDate,Reason)
            VALUES
            (@CustomerID,@PetTypeName,@PetAgeYears,@CityName,@ClinicName,@DiseaseName,
             @ClaimAmountUSD,@ClaimStatus,@SubmissionDate,'Dimension lookup failed');

        END
        ELSE
        BEGIN
            INSERT INTO paw.FactClaim
            (CustomerID,PetTypeID,PetAgeYears,CityID,ClinicID,DiseaseID,ClaimAmountUSD,
             ClaimStatus,SubmissionDate)
            VALUES
            (CAST(@CustomerID AS INT),@PetTypeID,CAST(@PetAgeYears AS DECIMAL(4,1)),@CityID,@ClinicID,
             @DiseaseID,CAST(@ClaimAmountUSD AS DECIMAL(10,2)),@ClaimStatus,CAST(@SubmissionDate AS DATE));
        END

        FETCH NEXT FROM cur INTO @CustomerID,@PetTypeName,@PetAgeYears,@CityName,@ClinicName,@DiseaseName,@ClaimAmountUSD,@ClaimStatus,@SubmissionDate;
    END

    CLOSE cur;
    DEALLOCATE cur;

END;
GO
