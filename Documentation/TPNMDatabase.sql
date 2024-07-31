-- Clean up the database, if needed
-- DROP TABLE Allocation;
-- DROP TABLE ExtRange;
-- DROP TABLE Department;
-- DROP TABLE Forbidden;
-- DROP TABLE Country;

-- Create tables for TPNM database
CREATE TABLE Country (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(2) UNIQUE,
    Code VARCHAR(4) UNIQUE,
    Description VARCHAR(100),
    CONSTRAINT CK_Code CHECK (Code LIKE '+[0-9]' OR Code LIKE '+[0-9][0-9]'  OR Code LIKE '+[0-9][0-9][0-9]')
);

CREATE TABLE Forbidden (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Country INT, -- Reference to the country
    Extension VARCHAR(15),
    Description VARCHAR(100),
    FOREIGN KEY (Country) REFERENCES Country(ID), -- Validate that the forbidden extension belongs to a country
    CONSTRAINT UC_Extension_Country UNIQUE (Extension, Country) -- Validate that the extension is forbidden only once per country
);

CREATE TABLE Department (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Country INT, -- Reference to the country
    Name VARCHAR(15),
    Description VARCHAR(100),
    FOREIGN KEY (Country) REFERENCES Country(ID), -- Validate that the department belongs to a country
    CONSTRAINT UC_Name_Country UNIQUE (Name, Country) -- Validate that the department code is unique within a country
);

CREATE TABLE ExtRange (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Department INT, -- Reference to the department that refers to a country
    Span VARCHAR(15),
    SpanStart VARCHAR(15),
    SpanEnd VARCHAR(15),
    Description VARCHAR(100),
    FOREIGN KEY (Department) REFERENCES Department(ID), -- Validate that the extension range belongs to a department
    CONSTRAINT UC_Department_Span_SpanStart_SpanEnd UNIQUE (Department, Span, SpanStart, SpanEnd) -- Validate that the extension range is unique within a department
);

CREATE TABLE Allocation (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ExtRange INT, -- Reference to the extension range that refers to a department that refers to a country
    Extension VARCHAR(15),
    State VARCHAR(50),
    CreatedOn DATETIME,
    Description VARCHAR(100),
    FOREIGN KEY (ExtRange) REFERENCES ExtRange(ID), -- Validate that the extension belongs to a range
    CONSTRAINT UC_ExtRange_Extension UNIQUE (ExtRange, Extension) -- Validate that the extension is allocated only once within a range
);