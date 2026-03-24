-- ============================================
-- QUERY SUITE FOR CONSTRUCTION DATABASE
-- ============================================

-- ====================
-- 1. PROJECT QUERIES
-- ====================

-- Query 1.1: Project Summary with Budget Variance
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.BuildingAddress,
    p.ProjectStatus,
    p.ProgressPercent,
    p.StartDate,
    p.EndDate,
    p.BudgetAmount,
    p.ActualCost,
    (p.BudgetAmount - p.ActualCost) as BudgetVariance,
    IIf(p.ActualCost > p.BudgetAmount, 'OVER', 'UNDER') as BudgetStatus,
    p.TotalUnits,
    p.UnitsCompleted,
    p.UnitsPreSold,
    o.OrgName as ClientName
FROM Projects p
LEFT JOIN Organizations o ON p.ClientOrgID = o.OrgID
ORDER BY p.ProjectID;

-- Query 1.2: Projects with Overdue Status
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.EndDate,
    TODAY() as CurrentDate,
    DATEDIFF(dd, p.EndDate, TODAY()) as DaysOverdue,
    p.ProjectStatus,
    p.ProgressPercent
FROM Projects p
WHERE p.EndDate < TODAY() 
  AND p.ProjectStatus <> 'Completed'
ORDER BY DATEDIFF(dd, p.EndDate, TODAY()) DESC;

-- Query 1.3: Active Projects Dashboard
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.ProjectStatus,
    p.ProgressPercent,
    COUNT(DISTINCT pm.MilestoneID) as TotalMilestones,
    SUM(IIf(pm.Status = 'Completed', 1, 0)) as CompletedMilestones,
    p.BudgetAmount,
    p.ActualCost,
    (p.BudgetAmount - p.ActualCost) as RemainingBudget
FROM Projects p
LEFT JOIN ProjectMilestones pm ON p.ProjectID = pm.ProjectID
WHERE p.ProjectStatus = 'Active'
GROUP BY p.ProjectID, p.ProjectName, p.ProjectStatus, p.ProgressPercent, p.BudgetAmount, p.ActualCost
ORDER BY p.ProgressPercent DESC;

-- Query 1.4: Project Milestone Status Report
SELECT 
    p.ProjectName,
    pm.MilestoneID,
    pm.MilestoneName,
    pm.PlannedDate,
    pm.ActualDate,
    pm.Status,
    pm.PercentComplete,
    IIf(pm.ActualDate IS NULL AND pm.PlannedDate < TODAY(), 'OVERDUE', 
        IIf(pm.ActualDate IS NULL AND pm.PlannedDate >= TODAY(), 'ON TRACK', 'COMPLETED')) as MilestoneStatus
FROM Projects p
INNER JOIN ProjectMilestones pm ON p.ProjectID = pm.ProjectID
ORDER BY p.ProjectID, pm.PlannedDate;

-- ====================
-- 2. LINE ITEM QUERIES
-- ====================

-- Query 2.1: Line Items by Cost Category
SELECT 
    p.ProjectName,
    li.CostCategory,
    COUNT(li.LineItemID) as ItemCount,
    SUM(li.BudgetAmount) as TotalBudget,
    SUM(li.ActualCost) as TotalActual,
    SUM(li.BudgetAmount - li.ActualCost) as TotalVariance,
    IIf(SUM(li.ActualCost) > SUM(li.BudgetAmount), 'OVER', 'UNDER') as Status
FROM Projects p
LEFT JOIN LineItems li ON p.ProjectID = li.ProjectID
WHERE li.CostCategory IS NOT NULL
GROUP BY p.ProjectName, li.CostCategory
ORDER BY p.ProjectName, SUM(li.ActualCost) DESC;

-- Query 2.2: Line Items Breakdown by Vendor
SELECT 
    p.ProjectName,
    o.OrgName as VendorName,
    COUNT(li.LineItemID) as LineItemCount,
    SUM(li.BudgetAmount) as BudgetAmount,
    SUM(li.ActualCost) as ActualCost,
    AVG(li.PercentComplete) as AvgCompletion,
    SUM(IIf(li.Status = 'Completed', 1, 0)) as CompletedItems
FROM Projects p
LEFT JOIN LineItems li ON p.ProjectID = li.ProjectID
LEFT JOIN Organizations o ON li.VendorOrgID = o.OrgID
WHERE li.VendorOrgID IS NOT NULL
GROUP BY p.ProjectName, o.OrgName
ORDER BY p.ProjectName, SUM(li.ActualCost) DESC;

-- Query 2.3: In-Progress Line Items (Incomplete)
SELECT 
    p.ProjectName,
    li.LineItemID,
    li.LineDescription,
    li.CostCategory,
    o.OrgName as VendorName,
    li.Status,
    li.PercentComplete,
    li.BudgetAmount,
    li.ActualCost,
    li.StartDate,
    li.EndDate,
    (li.BudgetAmount - li.ActualCost) as RemainingBudget
FROM Projects p
INNER JOIN LineItems li ON p.ProjectID = li.ProjectID
LEFT JOIN Organizations o ON li.VendorOrgID = o.OrgID
WHERE li.Status IN ('In Progress', 'Planned') 
  AND li.PercentComplete < 100
ORDER BY p.ProjectName, li.PercentComplete DESC;

-- ====================
-- 3. RESOURCE QUERIES
-- ====================

-- Query 3.1: Resource Utilization Report
SELECT 
    r.ResourceID,
    r.ResourceName,
    r.Role,
    o.OrgName as Organization,
    COUNT(pr.AssignmentID) as ActiveAssignments,
    SUM(pr.PlannedHours) as TotalPlannedHours,
    SUM(pr.ActualHours) as TotalActualHours,
    IIf(SUM(pr.PlannedHours) > 0, 
        (SUM(pr.ActualHours) / SUM(pr.PlannedHours) * 100), 0) as UtilizationRate,
    r.Availability,
    r.Status
FROM Resources r
LEFT JOIN Organizations o ON r.OrgID = o.OrgID
LEFT JOIN ProjectResources pr ON r.ResourceID = pr.ResourceID AND pr.Status IN ('Active', 'In Progress')
GROUP BY r.ResourceID, r.ResourceName, r.Role, o.OrgName, r.Availability, r.Status
ORDER BY UtilizationRate DESC;

-- Query 3.2: Resource Assignments by Project
SELECT 
    p.ProjectName,
    r.ResourceName,
    r.Role,
    pr.AssignmentStartDate,
    pr.AssignmentEndDate,
    pr.PlannedHours,
    pr.ActualHours,
    pr.HourlyRate,
    pr.TotalCost,
    pr.PercentAllocated,
    pr.Status
FROM Projects p
INNER JOIN ProjectResources pr ON p.ProjectID = pr.ProjectID
INNER JOIN Resources r ON pr.ResourceID = r.ResourceID
WHERE pr.Status IN ('Active', 'In Progress', 'Planned')
ORDER BY p.ProjectName, r.ResourceName;

-- Query 3.3: Resource Availability Status
SELECT 
    r.ResourceID,
    r.ResourceName,
    r.Role,
    r.Availability as AvailabilityPercent,
    r.Status,
    r.HourlyRate,
    COUNT(pr.AssignmentID) as CurrentAssignments,
    SUM(pr.PercentAllocated) as TotalAllocation
FROM Resources r
LEFT JOIN ProjectResources pr ON r.ResourceID = pr.ResourceID AND pr.Status = 'Active'
WHERE r.Status = 'Active'
GROUP BY r.ResourceID, r.ResourceName, r.Role, r.Availability, r.Status, r.HourlyRate
ORDER BY r.Availability ASC;

-- Query 3.4: Labor Cost Analysis by Project
SELECT 
    p.ProjectName,
    SUM(pr.TotalCost) as TotalLaborCost,
    SUM(pr.PlannedHours) as PlannedHours,
    SUM(pr.ActualHours) as ActualHours,
    AVG(pr.HourlyRate) as AvgHourlyRate,
    COUNT(DISTINCT r.ResourceID) as UniqueResources
FROM Projects p
INNER JOIN ProjectResources pr ON p.ProjectID = pr.ProjectID
INNER JOIN Resources r ON pr.ResourceID = r.ResourceID
WHERE r.ResourceType = 'Labor'
GROUP BY p.ProjectName
ORDER BY SUM(pr.TotalCost) DESC;

-- ====================
-- 4. TIME TRACKING QUERIES
-- ====================

-- Query 4.1: Time Entries Pending Approval
SELECT 
    tt.TimeEntryID,
    r.ResourceName,
    p.ProjectName,
    li.LineDescription,
    tt.WorkDate,
    tt.HoursWorked,
    tt.Status,
    tt.EnteredBy,
    tt.EnteredDate
FROM TimeTracking tt
INNER JOIN ProjectResources pr ON tt.AssignmentID = pr.AssignmentID
INNER JOIN Resources r ON pr.ResourceID = r.ResourceID
INNER JOIN Projects p ON pr.ProjectID = p.ProjectID
LEFT JOIN LineItems li ON pr.LineItemID = li.LineItemID
WHERE tt.Status = 'Submitted'
ORDER BY tt.WorkDate DESC;

-- Query 4.2: Time Summary by Resource and Month
SELECT 
    r.ResourceName,
    r.Role,
    MONTH(tt.WorkDate) as Month,
    YEAR(tt.WorkDate) as Year,
    SUM(tt.HoursWorked) as TotalHours,
    COUNT(tt.TimeEntryID) as EntryCount,
    SUM(pr.HourlyRate * tt.HoursWorked) as TotalCost
FROM TimeTracking tt
INNER JOIN ProjectResources pr ON tt.AssignmentID = pr.AssignmentID
INNER JOIN Resources r ON pr.ResourceID = r.ResourceID
WHERE tt.Status = 'Approved'
GROUP BY r.ResourceName, r.Role, MONTH(tt.WorkDate), YEAR(tt.WorkDate)
ORDER BY r.ResourceName, YEAR(tt.WorkDate) DESC, MONTH(tt.WorkDate) DESC;

-- Query 4.3: Unapproved and Draft Time Entries
SELECT 
    r.ResourceName,
    p.ProjectName,
    SUM(IIf(tt.Status = 'Draft', tt.HoursWorked, 0)) as DraftHours,
    SUM(IIf(tt.Status = 'Submitted', tt.HoursWorked, 0)) as SubmittedHours,
    COUNT(IIf(tt.Status = 'Draft', 1, NULL)) as DraftCount,
    COUNT(IIf(tt.Status = 'Submitted', 1, NULL)) as SubmittedCount
FROM TimeTracking tt
INNER JOIN ProjectResources pr ON tt.AssignmentID = pr.AssignmentID
INNER JOIN Resources r ON pr.ResourceID = r.ResourceID
INNER JOIN Projects p ON pr.ProjectID = p.ProjectID
WHERE tt.Status IN ('Draft', 'Submitted')
GROUP BY r.ResourceName, p.ProjectName
ORDER BY r.ResourceName;


-- ====================
-- 5. APARTMENT UNIT QUERIES
-- ====================

-- Query 5.1: Apartment Inventory and Sales Status
SELECT 
    p.ProjectName,
    au.UnitNumber,
    au.UnitType,
    au.SquareFootage,
    au.ConstructionStatus,
    au.SalesStatus,
    au.PreSalePrice,
    au.ListPrice,
    au.BuyerName,
    au.SaleDate
FROM Projects p
INNER JOIN ApartmentUnits au ON p.ProjectID = au.ProjectID
ORDER BY p.ProjectName, CAST(au.UnitNumber AS NUMBER);

-- Query 5.2: Sales Summary by Project
SELECT 
    p.ProjectName,
    p.TotalUnits,
    p.UnitsCompleted,
    p.UnitsPreSold,
    COUNT(CASE WHEN au.SalesStatus = 'Sold' THEN 1 END) as UnitsSold,
    COUNT(CASE WHEN au.SalesStatus = 'Pre-Sold' THEN 1 END) as UnitsPreSold_Count,
    COUNT(CASE WHEN au.SalesStatus = 'Available' THEN 1 END) as UnitsAvailable,
    SUM(au.ListPrice) as TotalListValue,
    SUM(CASE WHEN au.SalesStatus = 'Sold' THEN au.ListPrice ELSE 0 END) as SoldValue,
    (COUNT(CASE WHEN au.SalesStatus = 'Sold' THEN 1 END) / COUNT(*)) * 100 as SalesPercentage
FROM Projects p
LEFT JOIN ApartmentUnits au ON p.ProjectID = au.ProjectID
GROUP BY p.ProjectName, p.TotalUnits, p.UnitsCompleted, p.UnitsPreSold
ORDER BY SalesPercentage DESC;

-- Query 5.3: Units by Construction Status
SELECT 
    p.ProjectName,
    au.ConstructionStatus,
    COUNT(*) as UnitCount,
    AVG(au.SquareFootage) as AvgSquareFootage,
    COUNT(DISTINCT au.UnitType) as UnitTypeVariety
FROM Projects p
INNER JOIN ApartmentUnits au ON p.ProjectID = au.ProjectID
GROUP BY p.ProjectName, au.ConstructionStatus
ORDER BY p.ProjectName, 
    CASE au.ConstructionStatus 
        WHEN 'Planning' THEN 1
        WHEN 'Framing' THEN 2
        WHEN 'Rough-In' THEN 3
        WHEN 'Finishing' THEN 4
        WHEN 'Complete' THEN 5
    END;

-- Query 5.4: Salesman Performance by Project
SELECT 
    p.ProjectName,
    r.ResourceName,
    sp.Month,
    sp.UnitsShowings,
    sp.UnitsPresented,
    sp.UnitsSold,
    sp.ConversionRate,
    sp.TotalSalesValue,
    sp.Commission
FROM Projects p
INNER JOIN SalesmanPerformance sp ON p.ProjectID = sp.ProjectID
INNER JOIN Resources r ON sp.ResourceID = r.ResourceID
ORDER BY p.ProjectName, sp.Month DESC;


-- ====================
-- 6. COST & FINANCIAL QUERIES
-- ====================

-- Query 6.1: Budget vs Actual by Project
SELECT 
    p.ProjectName,
    p.BudgetAmount,
    p.ActualCost,
    (p.BudgetAmount - p.ActualCost) as BudgetVariance,
    IIf(p.BudgetAmount > 0, ((p.BudgetAmount - p.ActualCost) / p.BudgetAmount * 100), 0) as VariancePercent,
    p.ProgressPercent
FROM Projects p
ORDER BY 
    CASE 
        WHEN p.ActualCost > p.BudgetAmount THEN 0
        ELSE 1
    END,
    ABS(p.ActualCost - p.BudgetAmount) DESC;

-- Query 6.2: Cost by Organization
SELECT 
    o.OrgName,
    o.OrgType,
    SUM(ct.Amount) as TotalAmount,
    COUNT(ct.TransactionID) as TransactionCount,
    AVG(ct.Amount) as AvgTransactionAmount
FROM Organizations o
LEFT JOIN CostTransactions ct ON o.OrgID = ct.VendorOrgID
GROUP BY o.OrgName, o.OrgType
ORDER BY SUM(ct.Amount) DESC;

-- Query 6.3: Pending Invoices and Payables
SELECT 
    p.PayableID,
    o.OrgName,
    p.InvoiceNumber,
    p.InvoiceDate,
    p.DueDate,
    p.Amount,
    p.Status,
    DATEDIFF(dd, TODAY(), p.DueDate) as DaysUntilDue
FROM Payables p
INNER JOIN Organizations o ON p.VendorOrgID = o.OrgID
WHERE p.Status IN ('Pending', 'Approved')
ORDER BY p.DueDate ASC;

-- Query 6.4: Receivables Aging Report
SELECT 
    r.ReceivableID,
    r.BuyerName,
    p.ProjectName,
    r.InvoiceNumber,
    r.InvoiceDate,
    r.DueDate,
    r.Amount,
    r.AmountPaid,
    (r.Amount - r.AmountPaid) as OutstandingAmount,
    r.Status,
    DATEDIFF(dd, r.DueDate, TODAY()) as DaysOverdue
FROM Receivables r
INNER JOIN Projects p ON r.ProjectID = p.ProjectID
WHERE r.Status IN ('Draft', 'Sent', 'Partial', 'Overdue')
ORDER BY DATEDIFF(dd, r.DueDate, TODAY()) DESC;

-- Query 6.5: Cost Transaction History for Project
SELECT 
    ct.TransactionID,
    ct.TransactionType,
    o.OrgName,
    ct.TransactionDate,
    ct.Amount,
    ct.InvoiceNumber,
    ct.InvoiceDate,
    ct.DueDate,
    ct.PaidDate,
    ct.Status,
    ct.Description
FROM CostTransactions ct
LEFT JOIN Organizations o ON ct.VendorOrgID = o.OrgID
ORDER BY ct.TransactionDate DESC;


-- ====================
-- 7. PERFORMANCE QUERIES
-- ====================

-- Query 7.1: Supplier Performance Summary
SELECT 
    o.OrgName,
    sp.Month,
    sp.TotalOrders,
    sp.OnTimeDeliveries,
    sp.LateDeliveries,
    sp.QualityIssues,
    sp.OnTimeRate,
    sp.QualityRating
FROM SupplierPerformance sp
INNER JOIN Organizations o ON sp.VendorOrgID = o.OrgID
WHERE sp.Month >= DATE_ADD(MONTH, -12, TODAY())
ORDER BY o.OrgName, sp.Month DESC;

-- Query 7.2: Top Performing Suppliers
SELECT TOP 10
    o.OrgName,
    AVG(sp.OnTimeRate) as AvgOnTimeRate,
    AVG(sp.QualityRating) as AvgQualityRating,
    COUNT(sp.PerformanceID) as RecordsCount
FROM SupplierPerformance sp
INNER JOIN Organizations o ON sp.VendorOrgID = o.OrgID
GROUP BY o.OrgName
ORDER BY (AVG(sp.OnTimeRate) + AVG(sp.QualityRating)) DESC;

-- Query 7.3: Salesman Performance Leaderboard
SELECT 
    r.ResourceName,
    COUNT(DISTINCT sp.Month) as MonthsTracked,
    SUM(sp.UnitsShowings) as TotalShowings,
    SUM(sp.UnitsSold) as TotalSold,
    AVG(sp.ConversionRate) as AvgConversionRate,
    SUM(sp.TotalSalesValue) as TotalSalesValue,
    SUM(sp.Commission) as TotalCommission
FROM SalesmanPerformance sp
INNER JOIN Resources r ON sp.ResourceID = r.ResourceID
GROUP BY r.ResourceName
ORDER BY SUM(sp.Commission) DESC;

-- Query 7.4: Quality Issues by Supplier
SELECT 
    o.OrgName,
    SUM(sp.QualityIssues) as TotalQualityIssues,
    AVG(sp.QualityRating) as AvgQualityRating,
    COUNT(sp.PerformanceID) as MonthsTracked
FROM SupplierPerformance sp
INNER JOIN Organizations o ON sp.VendorOrgID = o.OrgID
GROUP BY o.OrgName
HAVING SUM(sp.QualityIssues) > 0
ORDER BY SUM(sp.QualityIssues) DESC;