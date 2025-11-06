-- PawSure Insurance Pet Claims Analytics – Schema & Dimension Tables
-- Author: Soundarya S
-- Created Date: 2025-10-01
-- Description: Set up schema and dimension tables for PawSure Pet Insurance Claims project.

USE PawSureDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='paw')
    EXEC('CREATE SCHEMA paw');
GO

CREATE TABLE paw.DimCity (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(50) NOT NULL,
    StateName VARCHAR(50) NULL
);
GO

CREATE TABLE paw.DimPetType (
    PetTypeID INT IDENTITY(1,1) PRIMARY KEY,
    PetTypeName VARCHAR(20) NOT NULL CHECK (PetTypeName IN ('Dog','Cat'))
);
GO

CREATE TABLE paw.DimDisease (
    DiseaseID INT IDENTITY(1,1) PRIMARY KEY,
    DiseaseName VARCHAR(100) NOT NULL,
    Category VARCHAR(40) NOT NULL,
    TypicalCostBand VARCHAR(20) NOT NULL
);
GO

CREATE TABLE paw.DimClinic (
    ClinicID INT IDENTITY(1,1) PRIMARY KEY,
    ClinicName VARCHAR(100) NOT NULL,
    CityID INT NOT NULL FOREIGN KEY REFERENCES paw.DimCity(CityID)
);
GO
