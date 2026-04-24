-- =============================================
-- PERSON 1 (PM) - SQL ANALYSIS QUERIES
-- Author: Andrew (Project Manager)
-- Purpose: Business intelligence analysis of loaded dimension data
-- Date: April 23, 2026
-- =============================================

USE BIClass;
GO

PRINT '========================================';
PRINT 'PERSON 1 - PM ANALYSIS QUERIES';
PRINT 'Project Manager: Andrew';
PRINT '========================================';
GO

-- =============================================
-- QUERY 1: Data Load Summary
-- Description: Shows total records loaded into each dimension table and which team member loaded it
-- Business Value: Validates ETL completion and provides quick visibility into data volume across the star schema
-- =============================================
PRINT '
QUERY 1: Data Load Summary by Dimension Table';
PRINT '-------------------------------------------';

SELECT 
    'DimCustomer' AS DimensionTable,
    COUNT(*) AS TotalRecords,
    'Person 3' AS LoadedBy
FROM [CH01-01-Dimension].[DimCustomer]

UNION ALL

SELECT 'DimGender', COUNT(*), 'Person 3'
FROM [CH01-01-Dimension].[DimGender]

UNION ALL

SELECT 'DimMaritalStatus', COUNT(*), 'Person 3'
FROM [CH01-01-Dimension].[DimMaritalStatus]

UNION ALL

SELECT 'DimOccupation', COUNT(*), 'Person 3'
FROM [CH01-01-Dimension].[DimOccupation]

UNION ALL

SELECT 'DimOrderDate', COUNT(*), 'Person 3'
FROM [CH01-01-Dimension].[DimOrderDate]

UNION ALL

SELECT 'DimProductCategory', COUNT(*), 'Person 4'
FROM [CH01-01-Dimension].[DimProductCategory]

UNION ALL

SELECT 'DimProductSubcategory', COUNT(*), 'Person 4'
FROM [CH01-01-Dimension].[DimProductSubcategory]

UNION ALL

SELECT 'DimProduct', COUNT(*), 'Person 4'
FROM [CH01-01-Dimension].[DimProduct]

ORDER BY TotalRecords DESC;
GO

-- =============================================
-- QUERY 2: Product Hierarchy Analysis
-- Description: Shows the relationship between Categories, Subcategories, and Products with percentage distribution
-- Business Value: Identifies which product categories are most diverse and helps understand portfolio balance
-- =============================================
PRINT '
QUERY 2: Product Category Hierarchy Analysis';
PRINT '-------------------------------------------';

SELECT 
    cat.ProductCategoryName AS Category,
    COUNT(DISTINCT sub.ProductSubcategoryKey) AS Subcategories,
    COUNT(DISTINCT p.ProductKey) AS Products,
    CAST(COUNT(DISTINCT p.ProductKey) * 100.0 / 
         SUM(COUNT(DISTINCT p.ProductKey)) OVER () AS DECIMAL(5,2)) AS PctOfTotalProducts
FROM [CH01-01-Dimension].[DimProductCategory] cat
LEFT JOIN [CH01-01-Dimension].[DimProductSubcategory] sub 
    ON sub.ProductCategoryKey = cat.ProductCategoryKey
LEFT JOIN [CH01-01-Dimension].[DimProduct] p 
    ON p.ProductSubcategoryKey = sub.ProductSubcategoryKey
GROUP BY cat.ProductCategoryName
ORDER BY Products DESC;
GO

-- =============================================
-- QUERY 3: Detailed Product Subcategory Breakdown
-- Description: Drills down to show product count within each subcategory organized by parent category
-- Business Value: Helps category managers identify which subcategories need product development or expansion
-- =============================================
PRINT '
QUERY 3: Products by Subcategory (Detailed View)';
PRINT '-------------------------------------------';

SELECT 
    cat.ProductCategoryName AS Category,
    sub.ProductSubcategoryName AS Subcategory,
    COUNT(p.ProductKey) AS ProductCount
FROM [CH01-01-Dimension].[DimProductCategory] cat
JOIN [CH01-01-Dimension].[DimProductSubcategory] sub 
    ON sub.ProductCategoryKey = cat.ProductCategoryKey
LEFT JOIN [CH01-01-Dimension].[DimProduct] p 
    ON p.ProductSubcategoryKey = sub.ProductSubcategoryKey
GROUP BY cat.ProductCategoryName, sub.ProductSubcategoryName
HAVING COUNT(p.ProductKey) > 0
ORDER BY cat.ProductCategoryName, ProductCount DESC;
GO

-- =============================================
-- QUERY 4: Customer Demographics by Occupation
-- Description: Segments the customer base by occupation type with counts and percentages
-- Business Value: Enables occupation-based customer segmentation for targeted marketing campaigns
-- =============================================
PRINT '
QUERY 4: Customer Distribution by Occupation';
PRINT '-------------------------------------------';

SELECT 
    Occupation,
    COUNT(*) AS CustomerCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PctOfTotal
FROM FileUpload.OriginallyLoadedData
WHERE Occupation IS NOT NULL
GROUP BY Occupation
ORDER BY CustomerCount DESC;
GO

-- =============================================
-- QUERY 5: Gender Distribution Analysis
-- Description: Analyzes customer base gender composition showing counts and percentage representation
-- Business Value: Informs product development decisions and helps evaluate if marketing reaches both genders effectively
-- =============================================
PRINT '
QUERY 5: Customer Gender Distribution';
PRINT '-------------------------------------------';

SELECT 
    g.Gender,
    g.GenderDescription,
    COUNT(DISTINCT old.CustomerName) AS Customers,
    CAST(COUNT(DISTINCT old.CustomerName) * 100.0 / 
         SUM(COUNT(DISTINCT old.CustomerName)) OVER () AS DECIMAL(5,2)) AS Percentage
FROM [CH01-01-Dimension].[DimGender] g
LEFT JOIN FileUpload.OriginallyLoadedData old 
    ON old.Gender = g.Gender
GROUP BY g.Gender, g.GenderDescription
ORDER BY Customers DESC;
GO

-- =============================================
-- QUERY 6: Marital Status Analysis
-- Description: Segments customers by marital status calculating distribution percentages
-- Business Value: Enables marital-status-based targeting for family versus individual product campaigns
-- =============================================
PRINT '
QUERY 6: Customer Marital Status Breakdown';
PRINT '-------------------------------------------';

SELECT 
    ms.MaritalStatus,
    ms.MaritalStatusDescription,
    COUNT(DISTINCT old.CustomerName) AS Customers,
    CAST(COUNT(DISTINCT old.CustomerName) * 100.0 / 
         SUM(COUNT(DISTINCT old.CustomerName)) OVER () AS DECIMAL(5,2)) AS Percentage
FROM [CH01-01-Dimension].[DimMaritalStatus] ms
LEFT JOIN FileUpload.OriginallyLoadedData old 
    ON old.MaritalStatus = ms.MaritalStatus
GROUP BY ms.MaritalStatus, ms.MaritalStatusDescription
ORDER BY Customers DESC;
GO

-- =============================================
-- QUERY 7: Order Date Temporal Analysis
-- Description: Analyzes order patterns over time breaking down volume and customers by year and month
-- Business Value: Identifies seasonal peaks and troughs for inventory planning and demand forecasting
-- =============================================
PRINT '
QUERY 7: Order Volume by Year and Month';
PRINT '-------------------------------------------';

SELECT 
    od.[Year],
    od.MonthName,
    od.MonthNumber,
    COUNT(DISTINCT old.CustomerName) AS UniqueCustomers,
    COUNT(*) AS TotalOrders
FROM [CH01-01-Dimension].[DimOrderDate] od
JOIN FileUpload.OriginallyLoadedData old 
    ON old.OrderDate = od.OrderDate
GROUP BY od.[Year], od.MonthName, od.MonthNumber
ORDER BY od.[Year], od.MonthNumber;
GO

-- =============================================
-- QUERY 8: Year-over-Year Order Comparison
-- Description: Aggregates order data annually comparing total orders, unique customers, and orders per customer
-- Business Value: Measures annual business growth and tracks customer engagement through repeat purchase behavior
-- =============================================
PRINT '
QUERY 8: Year-over-Year Order Summary';
PRINT '-------------------------------------------';

SELECT 
    od.[Year],
    COUNT(*) AS TotalOrders,
    COUNT(DISTINCT old.CustomerName) AS UniqueCustomers,
    CAST(COUNT(*) * 1.0 / COUNT(DISTINCT old.CustomerName) AS DECIMAL(10,2)) AS OrdersPerCustomer
FROM [CH01-01-Dimension].[DimOrderDate] od
JOIN FileUpload.OriginallyLoadedData old 
    ON old.OrderDate = od.OrderDate
GROUP BY od.[Year]
ORDER BY od.[Year];
GO

-- =============================================
-- QUERY 9: Top Products by Order Frequency
-- Description: Identifies the most frequently ordered products showing complete category hierarchy
-- Business Value: Reveals which specific SKUs drive transaction volume for inventory and marketing prioritization
-- =============================================
PRINT '
QUERY 9: Top 10 Most Ordered Products';
PRINT '-------------------------------------------';

SELECT TOP 10
    p.ProductName,
    sub.ProductSubcategoryName,
    cat.ProductCategoryName,
    COUNT(*) AS OrderCount
FROM FileUpload.OriginallyLoadedData old
JOIN [CH01-01-Dimension].[DimProduct] p 
    ON p.ProductName = old.ProductName
JOIN [CH01-01-Dimension].[DimProductSubcategory] sub 
    ON sub.ProductSubcategoryKey = p.ProductSubcategoryKey
JOIN [CH01-01-Dimension].[DimProductCategory] cat 
    ON cat.ProductCategoryKey = sub.ProductCategoryKey
GROUP BY p.ProductName, sub.ProductSubcategoryName, cat.ProductCategoryName
ORDER BY OrderCount DESC;
GO

-- =============================================
-- QUERY 10: Customer Demographics Cross-Analysis
-- Description: Performs multi-dimensional customer segmentation combining Gender, Marital Status, and Occupation
-- Business Value: Creates detailed customer personas for precision marketing and highly targeted campaigns
-- =============================================
PRINT '
QUERY 10: Customer Segmentation (Multi-Dimensional)';
PRINT '-------------------------------------------';

SELECT 
    old.Gender,
    old.MaritalStatus,
    old.Occupation,
    COUNT(DISTINCT old.CustomerName) AS Customers,
    CAST(COUNT(DISTINCT old.CustomerName) * 100.0 / 
         SUM(COUNT(DISTINCT old.CustomerName)) OVER () AS DECIMAL(5,2)) AS PctOfTotal
FROM FileUpload.OriginallyLoadedData old
WHERE old.Gender IS NOT NULL 
  AND old.MaritalStatus IS NOT NULL 
  AND old.Occupation IS NOT NULL
GROUP BY old.Gender, old.MaritalStatus, old.Occupation
HAVING COUNT(DISTINCT old.CustomerName) > 10
ORDER BY Customers DESC;
GO

-- =============================================
-- QUERY 11: Data Quality Validation
-- Description: Validates referential integrity by checking that orders can properly join to dimension tables
-- Business Value: Ensures ETL process correctly loaded all reference data before analytics and reporting
-- =============================================
PRINT '
QUERY 11: Data Quality Check (Referential Integrity)';
PRINT '-------------------------------------------';

SELECT 
    'Orders with Valid Products' AS ValidationCheck,
    COUNT(*) AS RecordCount
FROM FileUpload.OriginallyLoadedData old
WHERE EXISTS (
    SELECT 1 
    FROM [CH01-01-Dimension].[DimProduct] p 
    WHERE p.ProductName = old.ProductName
)

UNION ALL

SELECT 
    'Orders with Valid Dates',
    COUNT(*)
FROM FileUpload.OriginallyLoadedData old
WHERE EXISTS (
    SELECT 1 
    FROM [CH01-01-Dimension].[DimOrderDate] od 
    WHERE od.OrderDate = old.OrderDate
)

UNION ALL

SELECT 
    'Orders with Valid Customers',
    COUNT(*)
FROM FileUpload.OriginallyLoadedData old
WHERE EXISTS (
    SELECT 1 
    FROM [CH01-01-Dimension].[DimCustomer] c 
    WHERE c.CustomerName = old.CustomerName
);
GO

-- =============================================
-- QUERY 12: ETL Performance Metrics
-- Description: Analyzes ETL workflow performance showing procedures executed, rows loaded, and execution times
-- Business Value: Monitors ETL pipeline efficiency and identifies performance bottlenecks for optimization
-- =============================================
PRINT '
QUERY 12: ETL Workflow Performance Summary';
PRINT '-------------------------------------------';

SELECT 
    ua.GroupMemberFirstName + ' ' + ua.GroupMemberLastName AS TeamMember,
    COUNT(*) AS ProceduresExecuted,
    SUM(ws.WorkFlowStepTableRowCount) AS TotalRowsLoaded,
    AVG(DATEDIFF(MILLISECOND, ws.StartingDateTime, ws.EndingDateTime)) AS AvgDurationMS,
    MAX(DATEDIFF(MILLISECOND, ws.StartingDateTime, ws.EndingDateTime)) AS MaxDurationMS
FROM Process.WorkflowSteps ws
JOIN DbSecurity.UserAuthorization ua 
    ON ua.UserAuthorizationKey = ws.UserAuthorizationKey
GROUP BY ua.GroupMemberFirstName, ua.GroupMemberLastName
ORDER BY TotalRowsLoaded DESC;
GO

PRINT '
========================================';
PRINT 'ALL ANALYSIS QUERIES COMPLETED';
PRINT '========================================';
GO
