-- PawSure Insurance Pet Claims Analytics – Fact Table + Lookups
-- Author: Soundarya S
-- Created Date: 2025-10-01
-- Description: Create FactClaim table and insert lookup values (city, pet type, disease, clinic)

USE PawSureDB;
GO

--------------------------------
-- FactClaim Table
--------------------------------
CREATE TABLE paw.FactClaim (
    ClaimID BIGINT IDENTITY(100001,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    PetTypeID INT NOT NULL REFERENCES paw.DimPetType(PetTypeID),
    PetAgeYears DECIMAL(4,1) NOT NULL CHECK (PetAgeYears BETWEEN 0 AND 25),
    CityID INT NOT NULL REFERENCES paw.DimCity(CityID),
    ClinicID INT NOT NULL REFERENCES paw.DimClinic(ClinicID),
    DiseaseID INT NOT NULL REFERENCES paw.DimDisease(DiseaseID),
    ClaimAmountUSD DECIMAL(10,2) NOT NULL CHECK (ClaimAmountUSD > 0),
    ClaimStatus VARCHAR(10) NOT NULL CHECK (ClaimStatus IN ('Approved','Rejected','Pending')),
    SubmissionDate DATE NOT NULL,
    DaysToApprove INT NULL CHECK (DaysToApprove IS NULL OR DaysToApprove BETWEEN 0 AND 60),
    ApprovalDate DATE NULL,
    SuspectedFraud AS (CASE WHEN ClaimStatus='Approved' AND ClaimAmountUSD>2500 AND DaysToApprove>=20 THEN 1 ELSE 0 END) PERSISTED
);
GO

--------------------------------
-- Lookups: City
--------------------------------
INSERT INTO paw.DimCity (CityName, StateName)
VALUES 
('Bangalore','Karnataka'),
('Chennai','Tamil Nadu'),
('Hyderabad','Telangana'),
('Mumbai','Maharashtra'),
('Delhi','Delhi');
GO

--------------------------------
-- Lookups: Pet Type
--------------------------------
INSERT INTO paw.DimPetType (PetTypeName)
VALUES ('Dog'),('Cat');
GO

--------------------------------
-- Lookups: Disease
--------------------------------
INSERT INTO paw.DimDisease (DiseaseName, Category, TypicalCostBand)
VALUES
('Cranial Cruciate Ligament Rupture','Orthopedic','High'),
('Patellar Luxation','Orthopedic','Medium'),
('Hip Dysplasia','Orthopedic','High'),
('Femoral Shaft Fracture','Orthopedic','Very High'),
('Intervertebral Disc Disease','Orthopedic','High'),
('Atopic Dermatitis','Dermatology','Low'),
('Pyoderma (Bacterial Skin Infection)','Dermatology','Low'),
('Diabetes Mellitus','Chronic','High'),
('Chronic Kidney Disease','Chronic','High'),
('Acute Gastroenteritis','Gastrointestinal','Low'),
('Mast Cell Tumor','Oncology','Very High');
GO

--------------------------------
-- Lookups: Clinic (2 per city)
--------------------------------
INSERT INTO paw.DimClinic (ClinicName, CityID)
SELECT c.ClinicName, d.CityID
FROM (
    VALUES
      ('Paws & Claws Specialty Center', 'Bangalore'),
      ('IndiVet Orthopedic Hospital',   'Bangalore'),
      ('Marina Pet Care Hospital',      'Chennai'),
      ('Bayview Animal Clinic',         'Chennai'),
      ('Charminar Pet Ortho Center',    'Hyderabad'),
      ('Lakeside Veterinary Hospital',  'Hyderabad'),
      ('Western Pet Trauma Center',     'Mumbai'),
      ('Gateway Animal Hospital',       'Mumbai'),
      ('Capital Pet Specialty Clinic',  'Delhi'),
      ('North Ridge Veterinary',        'Delhi')
) AS c(ClinicName, CityName)
JOIN paw.DimCity d ON d.CityName = c.CityName;
GO
