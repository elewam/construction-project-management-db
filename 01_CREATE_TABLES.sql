-- SQL Script to create core tables and lookup tables

-- 1. Organizations Table
CREATE TABLE Organizations (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Location VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Projects Table
CREATE TABLE Projects (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    OrganizationId INT REFERENCES Organizations(Id),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Status VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. ApartmentUnits Table
CREATE TABLE ApartmentUnits (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    UnitNumber VARCHAR(50) NOT NULL,
    Size INT,
    Price DECIMAL(10, 2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. ProjectMilestones Table
CREATE TABLE ProjectMilestones (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    MilestoneName VARCHAR(255) NOT NULL,
    MilestoneDate DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. LineItems Table
CREATE TABLE LineItems (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    Description TEXT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Resources Table
CREATE TABLE Resources (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Type VARCHAR(100),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. ProjectResources Table
CREATE TABLE ProjectResources (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    ResourceId INT REFERENCES Resources(Id),
    Quantity INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. TimeTracking Table
CREATE TABLE TimeTracking (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    ResourceId INT REFERENCES Resources(Id),
    HoursWorked DECIMAL(5, 2),
    DateWorked DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. CostTransactions Table
CREATE TABLE CostTransactions (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    Description TEXT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    TransactionDate DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. SalesmanPerformance Table
CREATE TABLE SalesmanPerformance (
    Id SERIAL PRIMARY KEY,
    SalesmanId INT,
    ProjectId INT REFERENCES Projects(Id),
    PerformanceScore DECIMAL(5, 2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. SupplierPerformance Table
CREATE TABLE SupplierPerformance (
    Id SERIAL PRIMARY KEY,
    SupplierId INT,
    PerformanceScore DECIMAL(5, 2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Payables Table
CREATE TABLE Payables (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    Amount DECIMAL(10, 2) NOT NULL,
    DueDate DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. Receivables Table
CREATE TABLE Receivables (
    Id SERIAL PRIMARY KEY,
    ProjectId INT REFERENCES Projects(Id),
    Amount DECIMAL(10, 2) NOT NULL,
    DueDate DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lookup Tables

-- 1. Resource Types Lookup Table
CREATE TABLE ResourceTypes (
    Id SERIAL PRIMARY KEY,
    TypeName VARCHAR(100) NOT NULL
);

-- 2. Work Status Lookup Table
CREATE TABLE WorkStatus (
    Id SERIAL PRIMARY KEY,
    StatusName VARCHAR(100) NOT NULL
);

-- 3. Payment Methods Lookup Table
CREATE TABLE PaymentMethods (
    Id SERIAL PRIMARY KEY,
    MethodName VARCHAR(100) NOT NULL
);

-- 4. Supplier Types Lookup Table
CREATE TABLE SupplierTypes (
    Id SERIAL PRIMARY KEY,
    TypeName VARCHAR(100) NOT NULL
);

-- 5. Performance Metrics Lookup Table
CREATE TABLE PerformanceMetrics (
    Id SERIAL PRIMARY KEY,
    MetricName VARCHAR(100) NOT NULL
);