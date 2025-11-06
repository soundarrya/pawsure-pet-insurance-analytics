-- PawSure Insurance Pet Claims Analytics – KPI Views
-- Author: Soundarya S
-- Created Date: 2025-10-01
-- Description: Business KPI Views for Approval Rate, City SLA, Disease Cost, Clinic Performance

USE PawSureDB;
GO

---------------------------------------------------
-- 1) Approval rate by month
---------------------------------------------------
CREATE VIEW paw.vKPI_ClaimApprovalRateByMonth AS
SELECT 
    CONVERT(CHAR(7), SubmissionDate, 126) AS Month,   -- yyyy-MM
    COUNT(*) AS TotalClaims,
    SUM(CASE WHEN ClaimStatus='Approved' THEN 1 ELSE 0 END) AS ApprovedClaims,
    CAST(100.0 * SUM(CASE WHEN ClaimStatus='Approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0)
         AS DECIMAL(5,2)) AS ApprovalRatePct
FROM paw.FactClaim
GROUP BY CONVERT(CHAR(7), SubmissionDate, 126);
GO

---------------------------------------------------
-- 2) Avg days to approve by city
---------------------------------------------------
CREATE VIEW paw.vKPI_AvgDaysToApproveByCity AS
SELECT 
    c.CityName,
    AVG(CAST(fc.DaysToApprove AS DECIMAL(10,2))) AS AvgDaysToApprove
FROM paw.FactClaim fc
JOIN paw.DimCity c ON c.CityID = fc.CityID
WHERE fc.ClaimStatus='Approved'
GROUP BY c.CityName;
GO

---------------------------------------------------
-- 3) Top high cost diseases
---------------------------------------------------
CREATE VIEW paw.vKPI_TopHighCostDiseases AS
SELECT TOP 10
    d.DiseaseName,
    d.Category,
    COUNT(*) AS ClaimCount,
    AVG(fc.ClaimAmountUSD) AS AvgAmountUSD,
    SUM(fc.ClaimAmountUSD) AS TotalPaidUSD
FROM paw.FactClaim fc
JOIN paw.DimDisease d ON d.DiseaseID = fc.DiseaseID
WHERE fc.ClaimStatus='Approved'
GROUP BY d.DiseaseName, d.Category
ORDER BY AvgAmountUSD DESC;
GO

---------------------------------------------------
-- 4) Clinic high claim approval ratio
---------------------------------------------------
CREATE VIEW paw.vKPI_ClinicHighClaimRatio AS
SELECT 
    cl.ClinicName,
    ci.CityName,
    COUNT(*) AS TotalClaims,
    SUM(CASE WHEN fc.ClaimStatus='Approved' THEN 1 ELSE 0 END) AS ApprovedClaims,
    CAST(100.0 * SUM(CASE WHEN fc.ClaimStatus='Approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0)
         AS DECIMAL(5,2)) AS ApprovalRatePct,
    AVG(fc.ClaimAmountUSD) AS AvgClaimAmountUSD
FROM paw.FactClaim fc
JOIN paw.DimClinic cl ON cl.ClinicID = fc.ClinicID
JOIN paw.DimCity ci ON ci.CityID = cl.CityID
GROUP BY cl.ClinicName, ci.CityName;
GO
