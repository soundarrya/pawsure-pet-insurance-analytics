-- PawSure Insurance Pet Claims Analytics – Sample Synthetic Data (100 rows)
-- Author: Soundarya S
-- Created Date: 2025-10-01
-- Description: Generate 100 synthetic claim records over last 12 months.

USE PawSureDB;
GO

-- always clean before reinsert
TRUNCATE TABLE paw.FactClaim;
GO

;WITH Tally AS (
    SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
),
RandBase AS (
    SELECT 
        n,
        ABS(CHECKSUM(NEWID())) AS rseed
    FROM Tally
),
Picks AS (
    SELECT
        n,
        rseed,
        1 + (rseed % 1000) AS r1,
        1 + ((rseed/7) % 1000) AS r2,
        1 + ((rseed/13) % 1000) AS r3
    FROM RandBase
)
INSERT INTO paw.FactClaim (
    CustomerID, PetTypeID, PetAgeYears, CityID, ClinicID, DiseaseID,
    ClaimAmountUSD, ClaimStatus, SubmissionDate, DaysToApprove, ApprovalDate
)
SELECT
    10000 + (p.r1 % 90000) AS CustomerID,
    CASE WHEN (p.r2 % 100) < 65 THEN 1 ELSE 2 END AS PetTypeID, -- Dog=1 Cat=2
    CAST(((p.r3 % 150)/10.0)+0.5 AS DECIMAL(4,1)) AS PetAgeYears,
    ((p.r1 % 5) + 1) AS CityID, -- 5 cities
    ((p.r2 % 2) + 1) + ((p.r1 % 5) * 2) AS ClinicID, -- 2 per city
    ((p.r3 % 11) + 1) AS DiseaseID, -- 11 diseases
    CAST(
        CASE ((p.r3 % 11) +1)
            WHEN 4 THEN 2000 + (p.r1 % 3500)
            WHEN 11 THEN 2000 + (p.r1 % 3500)
            WHEN 1 THEN  800 + (p.r1 % 2200)
            WHEN 3 THEN  800 + (p.r1 % 1800)
            WHEN 5 THEN  900 + (p.r1 % 1600)
            WHEN 8 THEN  600 + (p.r1 % 2000)
            WHEN 9 THEN  800 + (p.r1 % 2000)
            WHEN 2 THEN  450 + (p.r1 % 1200)
            WHEN 10 THEN 150 + (p.r1 % 350)
            ELSE 120 + (p.r1 % 300)
        END AS DECIMAL(10,2)) AS ClaimAmountUSD,
    CASE WHEN (p.r2 % 100) < 78 THEN 'Approved'
         WHEN (p.r2 % 100) < 90 THEN 'Rejected'
         ELSE 'Pending' END AS ClaimStatus,
    DATEADD(DAY, -1*((p.r1 % 365)), CAST(GETDATE() AS date)) AS SubmissionDate, -- 12 months window
    CASE WHEN (p.r2 % 100) < 78 THEN 2 + (p.r3 % 28)
         WHEN (p.r2 % 100) < 90 THEN 3 + (p.r1 % 10)
         ELSE NULL END AS DaysToApprove,
    CASE WHEN (p.r2 % 100) < 78 THEN DATEADD(DAY,(2 + (p.r3 % 28)),DATEADD(DAY,-1*((p.r1 % 365)),CAST(GETDATE() AS date)))
         ELSE NULL END AS ApprovalDate
FROM Picks p;
GO
