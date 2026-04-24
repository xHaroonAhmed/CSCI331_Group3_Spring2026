USE BIClass;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadSalesManagers]
    @UserAuthorizationKey INT
AS 
BEGIN 
    SET NOCOUNT ON; 

    DECLARE @StartTime DATETIME2 = SYSDATETIME();
    DECLARE @RowCount INT;
    
    -- Load distinct sales managers from source
    ;WITH DistinctManagers AS (
        SELECT DISTINCT old.SalesManager
        FROM FileUpload.OriginallyLoadedData AS old 
        WHERE old.SalesManager IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 
            FROM [CH01-01-Dimension].[SalesManagers] AS dim 
            WHERE dim.SalesManager = old.SalesManager
        )
    )
    INSERT INTO [CH01-01-Dimension].[SalesManagers] (
        SalesManagerKey,
        SalesManager, 
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
    )
    SELECT
        NEXT VALUE FOR PkSequence.SalesManagersSequenceObject OVER (ORDER BY SalesManager),
        SalesManager,
        @UserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME() 
    FROM DistinctManagers;

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows] 
        @StartTime = @StartTime,
        @WorkFlowDescription = N'[Process].[usp_LoadSalesManagers]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey = @UserAuthorizationKey; 
END;
GO 

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimTerritory]
    @UserAuthorizationKey INT
AS
BEGIN 
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2 = SYSDATETIME();
    DECLARE @RowCount INT;

    INSERT INTO [CH01-01-Dimension].[DimTerritory] (
        TerritoryGroup,
        TerritoryCountry,
        TerritoryRegion,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
    )
    SELECT DISTINCT
        old.TerritoryGroup,
        old.TerritoryCountry,
        old.TerritoryRegion,
        @UserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM FileUpload.OriginallyLoadedData AS old
    WHERE old.TerritoryGroup IS NOT NULL
      AND old.TerritoryCountry IS NOT NULL
      AND old.TerritoryRegion IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM [CH01-01-Dimension].[DimTerritory] AS terr
        WHERE terr.TerritoryGroup = old.TerritoryGroup
          AND terr.TerritoryCountry = old.TerritoryCountry
          AND terr.TerritoryRegion = old.TerritoryRegion
    );

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime = @StartTime,
        @WorkFlowDescription = N'[Process].[usp_LoadDimTerritory]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey = @UserAuthorizationKey;
END;
GO 

CREATE OR ALTER PROCEDURE [Process].[usp_LoadFactData]
    @UserAuthorizationKey INT
AS 
BEGIN  
    SET NOCOUNT ON;  
    DECLARE @StartTime DATETIME2 = SYSDATETIME(); 
    DECLARE @RowCount INT;

    
    INSERT INTO [CH01-01-Fact].[Data] (
        
        SalesKey,
        SalesManagerKey,
        OccupationKey,
        TerritoryKey,
        ProductKey,
        CustomerKey,
        ProductCategory,
        SalesManager,
        ProductSubcategory,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        OrderDate,
        MonthName,
        MonthNumber,
        Year,
        CustomerName,
        MaritalStatus,
        Gender,
        Education,
        Occupation,
        TerritoryRegion,
        TerritoryCountry,
        TerritoryGroup,
        OrderQuantity,
        UnitPrice,
        ProductStandardCost,
        SalesAmount,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
    )
    SELECT
        
        NEXT VALUE FOR PkSequence.FactDataSequenceObject OVER (ORDER BY old.OrderDate),
        
        sm.SalesManagerKey,         
        occ.OccupationKey,            
        terr.TerritoryKey,           
        prod.ProductKey,              
        cust.CustomerKey,            
        old.ProductCategory,
        old.SalesManager,
        old.ProductSubcategory,
        old.ProductCode,
        old.ProductName,
        old.Color,
        old.ModelName,
        old.OrderDate,
        old.MonthName,
        old.MonthNumber,
        old.Year,
        old.CustomerName,
        old.MaritalStatus,
        old.Gender,
        old.Education,
        old.Occupation,
        old.TerritoryRegion,
        old.TerritoryCountry,
        old.TerritoryGroup,
        old.OrderQuantity,
        old.UnitPrice,
        old.ProductStandardCost,
        old.SalesAmount,
        @UserAuthorizationKey, 
        SYSDATETIME(), 
        SYSDATETIME()
    FROM FileUpload.OriginallyLoadedData AS old
        INNER JOIN [CH01-01-Dimension].[SalesManagers] sm 
            ON sm.SalesManager = old.SalesManager
        INNER JOIN [CH01-01-Dimension].[DimOccupation] occ 
            ON occ.Occupation = old.Occupation
        INNER JOIN [CH01-01-Dimension].[DimTerritory] terr 
            ON terr.TerritoryCountry = old.TerritoryCountry 
            AND terr.TerritoryGroup = old.TerritoryGroup 
            AND terr.TerritoryRegion = old.TerritoryRegion
        INNER JOIN [CH01-01-Dimension].[DimProduct] prod 
            ON prod.ProductName = old.ProductName
        INNER JOIN [CH01-01-Dimension].[DimCustomer] cust 
            ON cust.CustomerName = old.CustomerName;
    
    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime = @StartTime,
        @WorkFlowDescription = N'[Process].[usp_LoadFactData]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey = @UserAuthorizationKey;
END;
GO 

PRINT '✅ Person 5 - All 3 procedures created successfully!';
PRINT '   - [Process].[usp_LoadSalesManagers] (4 sales managers)';
PRINT '   - [Process].[usp_LoadDimTerritory] (10 territories)';
PRINT '   - [Process].[usp_LoadFactData] (60,398 fact rows)';
GO
