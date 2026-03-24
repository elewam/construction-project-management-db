-- Construction Project Management Database
-- SQL Scripts for Microsoft Access
-- Create all tables with relationships

-- ============================================
-- 1. ORGANIZATIONS TABLE
-- ============================================
CREATE TABLE Organizations (
    OrgID AUTOINCREMENT PRIMARY KEY,
    OrgName TEXT(255) NOT NULL,
    OrgType TEXT(50),
    ContactPerson TEXT(100),
    Email TEXT(100),
    Phone TEXT(20),
    Address TEXT(255),
    City TEXT(50),
    State TEXT(2),
    ZipCode TEXT(10),
    Country TEXT(50),
    PaymentTerms TEXT(50),
    Rating NUMBER,
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO
);

-- ============================================
-- 2. PROJECTS TABLE
-- ============================================
CREATE TABLE Projects (
    ProjectID AUTOINCREMENT PRIMARY KEY,
    ProjectName TEXT(255) NOT NULL,
    BuildingAddress TEXT(255) NOT NULL,
    City TEXT(50),
    State TEXT(2),
    ZipCode TEXT(10),
    ClientOrgID NUMBER,
    ProjectStatus TEXT(50) DEFAULT 'Planning',
    StartDate DATETIME,
    EndDate DATETIME,
    ActualEndDate DATETIME,
    BudgetAmount CURRENCY,
    ActualCost CURRENCY DEFAULT 0,
    ProgressPercent NUMBER DEFAULT 0,
    ProjectManager TEXT(100),
    TotalUnits NUMBER,
    UnitsCompleted NUMBER DEFAULT 0,
    UnitsPreSold NUMBER DEFAULT 0,
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ClientOrgID) REFERENCES Organizations(OrgID)
);

-- ============================================
-- 3. PROJECT MILESTONES TABLE
-- ============================================
CREATE TABLE ProjectMilestones (
    MilestoneID AUTOINCREMENT PRIMARY KEY,
    ProjectID NUMBER NOT NULL,
    MilestoneName TEXT(255) NOT NULL,
    PlannedDate DATETIME,
    ActualDate DATETIME,
    Status TEXT(50) DEFAULT 'Planned',
    PercentComplete NUMBER DEFAULT 0,
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- ============================================
-- 4. APARTMENT UNITS TABLE
-- ============================================
CREATE TABLE ApartmentUnits (
    UnitID AUTOINCREMENT PRIMARY KEY,
    ProjectID NUMBER NOT NULL,
    UnitNumber TEXT(50) NOT NULL,
    UnitType TEXT(50),
    SquareFootage NUMBER,
    ConstructionStatus TEXT(50) DEFAULT 'Planning',
    SalesStatus TEXT(50) DEFAULT 'Available',
    PreSalePrice CURRENCY,
    ListPrice CURRENCY,
    SalesmanID NUMBER,
    BuyerName TEXT(100),
    BuyerEmail TEXT(100),
    SaleDate DATETIME,
    ConstructionStartDate DATETIME,
    ConstructionEndDate DATETIME,
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- ============================================
-- 5. LINE ITEMS TABLE
-- ============================================
CREATE TABLE LineItems (
    LineItemID AUTOINCREMENT PRIMARY KEY,
    ProjectID NUMBER NOT NULL,
    MilestoneID NUMBER,
    LineDescription TEXT(255) NOT NULL,
    CostCategory TEXT(50),
    VendorOrgID NUMBER,
    BudgetAmount CURRENCY,
    ActualCost CURRENCY DEFAULT 0,
    Quantity NUMBER,
    UnitOfMeasure TEXT(20),
    UnitPrice CURRENCY,
    StartDate DATETIME,
    EndDate DATETIME,
    Status TEXT(50) DEFAULT 'Planned',
    PercentComplete NUMBER DEFAULT 0,
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (MilestoneID) REFERENCES ProjectMilestones(MilestoneID),
    FOREIGN KEY (VendorOrgID) REFERENCES Organizations(OrgID)
);

-- ============================================
-- 6. RESOURCES TABLE
-- ============================================
CREATE TABLE Resources (
    ResourceID AUTOINCREMENT PRIMARY KEY,
    OrgID NUMBER NOT NULL,
    ResourceName TEXT(100) NOT NULL,
    ResourceType TEXT(50),
    Role TEXT(50),
    HourlyRate CURRENCY,
    Availability NUMBER DEFAULT 100,
    StartDate DATETIME DEFAULT NOW(),
    EndDate DATETIME,
    Status TEXT(50) DEFAULT 'Active',
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (OrgID) REFERENCES Organizations(OrgID)
);

-- ============================================
-- 7. PROJECT RESOURCES (MANY-TO-MANY)
-- ============================================
CREATE TABLE ProjectResources (
    AssignmentID AUTOINCREMENT PRIMARY KEY,
    ProjectID NUMBER NOT NULL,
    LineItemID NUMBER,
    ResourceID NUMBER NOT NULL,
    AssignmentStartDate DATETIME,
    AssignmentEndDate DATETIME,
    PlannedHours NUMBER,
    ActualHours NUMBER DEFAULT 0,
    HourlyRate CURRENCY,
    TotalCost CURRENCY DEFAULT 0,
    PercentAllocated NUMBER DEFAULT 100,
    Status TEXT(50) DEFAULT 'Planned',
    CreatedDate DATETIME DEFAULT NOW(),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (LineItemID) REFERENCES LineItems(LineItemID),
    FOREIGN KEY (ResourceID) REFERENCES Resources(ResourceID)
);

-- ============================================
-- 8. TIME TRACKING TABLE
-- ============================================
CREATE TABLE TimeTracking (
    TimeEntryID AUTOINCREMENT PRIMARY KEY,
    AssignmentID NUMBER NOT NULL,
    WorkDate DATETIME NOT NULL,
    HoursWorked NUMBER NOT NULL,
    Notes MEMO,
    EnteredBy TEXT(100),
    EnteredDate DATETIME DEFAULT NOW(),
    ApprovedBy TEXT(100),
    ApprovedDate DATETIME,
    Status TEXT(50) DEFAULT 'Draft',
    LastModified DATETIME DEFAULT NOW(),
    FOREIGN KEY (AssignmentID) REFERENCES ProjectResources(AssignmentID)
);

-- ============================================
-- 9. COST TRANSACTIONS TABLE
-- ============================================
CREATE TABLE CostTransactions (
    TransactionID AUTOINCREMENT PRIMARY KEY,
    LineItemID NUMBER,
    ProjectID NUMBER NOT NULL,
    TransactionType TEXT(50),
    VendorOrgID NUMBER,
    TransactionDate DATETIME NOT NULL,
    Amount CURRENCY NOT NULL,
    Description TEXT(255),
    InvoiceNumber TEXT(50),
    InvoiceDate DATETIME,
    DueDate DATETIME,
    PaidDate DATETIME,
    Status TEXT(50) DEFAULT 'Pending',
    ApprovedBy TEXT(100),
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (LineItemID) REFERENCES LineItems(LineItemID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (VendorOrgID) REFERENCES Organizations(OrgID)
);

-- ============================================
-- 10. SALESMAN PERFORMANCE TABLE
-- ============================================
CREATE TABLE SalesmanPerformance (
    PerformanceID AUTOINCREMENT PRIMARY KEY,
    ResourceID NUMBER NOT NULL,
    ProjectID NUMBER NOT NULL,
    UnitsShowings NUMBER DEFAULT 0,
    UnitsPresented NUMBER DEFAULT 0,
    UnitsSold NUMBER DEFAULT 0,
    ConversionRate NUMBER DEFAULT 0,
    TotalSalesValue CURRENCY DEFAULT 0,
    Commission CURRENCY DEFAULT 0,
    Month DATETIME,
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ResourceID) REFERENCES Resources(ResourceID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- ============================================
-- 11. SUPPLIER PERFORMANCE TABLE
-- ============================================
CREATE TABLE SupplierPerformance (
    PerformanceID AUTOINCREMENT PRIMARY KEY,
    VendorOrgID NUMBER NOT NULL,
    ProjectID NUMBER NOT NULL,
    OnTimeDeliveries NUMBER DEFAULT 0,
    LateDeliveries NUMBER DEFAULT 0,
    QualityIssues NUMBER DEFAULT 0,
    TotalOrders NUMBER DEFAULT 0,
    OnTimeRate NUMBER DEFAULT 0,
    QualityRating NUMBER DEFAULT 0,
    Month DATETIME,
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (VendorOrgID) REFERENCES Organizations(OrgID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- ============================================
-- 12. PAYABLES TABLE
-- ============================================
CREATE TABLE Payables (
    PayableID AUTOINCREMENT PRIMARY KEY,
    VendorOrgID NUMBER NOT NULL,
    InvoiceNumber TEXT(50),
    InvoiceDate DATETIME,
    DueDate DATETIME,
    Amount CURRENCY NOT NULL,
    Description TEXT(255),
    Status TEXT(50) DEFAULT 'Pending',
    PaidDate DATETIME,
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (VendorOrgID) REFERENCES Organizations(OrgID)
);

-- ============================================
-- 13. RECEIVABLES TABLE
-- ============================================
CREATE TABLE Receivables (
    ReceivableID AUTOINCREMENT PRIMARY KEY,
    ProjectID NUMBER NOT NULL,
    UnitID NUMBER,
    BuyerName TEXT(100),
    InvoiceNumber TEXT(50),
    InvoiceDate DATETIME,
    DueDate DATETIME,
    Amount CURRENCY NOT NULL,
    AmountPaid CURRENCY DEFAULT 0,
    Status TEXT(50) DEFAULT 'Draft',
    LastPaymentDate DATETIME,
    LastModified DATETIME DEFAULT NOW(),
    Notes MEMO,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (UnitID) REFERENCES ApartmentUnits(UnitID)
);

-- ============================================
-- 14. LOOKUP TABLES
-- ============================================

CREATE TABLE LU_ProjectStatus (
    StatusID AUTOINCREMENT PRIMARY KEY,
    StatusName TEXT(50) NOT NULL UNIQUE
);

CREATE TABLE LU_CostCategories (
    CategoryID AUTOINCREMENT PRIMARY KEY,
    CategoryName TEXT(50) NOT NULL UNIQUE
);

CREATE TABLE LU_ResourceRoles (
    RoleID AUTOINCREMENT PRIMARY KEY,
    RoleName TEXT(50) NOT NULL UNIQUE
);

CREATE TABLE LU_ConstructionStatus (
    StatusID AUTOINCREMENT PRIMARY KEY,
    StatusName TEXT(50) NOT NULL UNIQUE
);

CREATE TABLE LU_SalesStatus (
    StatusID AUTOINCREMENT PRIMARY KEY,
    StatusName TEXT(50) NOT NULL UNIQUE
);

-- ============================================
-- INSERT LOOKUP TABLE DATA
-- ============================================

INSERT INTO LU_ProjectStatus (StatusName) VALUES ('Planning');
INSERT INTO LU_ProjectStatus (StatusName) VALUES ('Active');
INSERT INTO LU_ProjectStatus (StatusName) VALUES ('On Hold');
INSERT INTO LU_ProjectStatus (StatusName) VALUES ('Completed');
INSERT INTO LU_ProjectStatus (StatusName) VALUES ('Cancelled');

INSERT INTO LU_CostCategories (CategoryName) VALUES ('Labor');
INSERT INTO LU_CostCategories (CategoryName) VALUES ('Materials');
INSERT INTO LU_CostCategories (CategoryName) VALUES ('Equipment');
INSERT INTO LU_CostCategories (CategoryName) VALUES ('Subcontractor');
INSERT INTO LU_CostCategories (CategoryName) VALUES ('Other');

INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Project Manager');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Foreman');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Carpenter');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Electrician');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Plumber');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('HVAC Technician');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Painter');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Laborer');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Equipment Operator');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Salesman');
INSERT INTO LU_ResourceRoles (RoleName) VALUES ('Admin');

INSERT INTO LU_ConstructionStatus (StatusName) VALUES ('Planning');
INSERT INTO LU_ConstructionStatus (StatusName) VALUES ('Framing');
INSERT INTO LU_ConstructionStatus (StatusName) VALUES ('Rough-In');
INSERT INTO LU_ConstructionStatus (StatusName) VALUES ('Finishing');
INSERT INTO LU_ConstructionStatus (StatusName) VALUES ('Complete');

INSERT INTO LU_SalesStatus (StatusName) VALUES ('Available');
INSERT INTO LU_SalesStatus (StatusName) VALUES ('Pre-Sold');
INSERT INTO LU_SalesStatus (StatusName) VALUES ('Sold');
INSERT INTO LU_SalesStatus (StatusName) VALUES ('On Hold');
