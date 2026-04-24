USE BIClass;
GO

-- ============================================================
-- Person 4 (Azm) - ETL Developer 2
-- 03_DimensionLoaders_ProductHierarchy.sql  --  FIXED VERSION
-- Fix: Captured @@ROWCOUNT into @RowCount variable before
--      calling usp_TrackWorkFlows. Passing @@ROWCOUNT directly
--      always resulted in 0 because it resets after every statement.
-- ============================================================

-- ============================================================
-- PROCEDURE 1: Load DimProductCategory (parent)
-- Must run before DimProductSubcategory and DimProduct
-- ============================================================
CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimProductCategory]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- Author: Azm
    -- Procedure: [Process].[usp_LoadDimProductCategory]
    -- Create date: 2024
    -- Description: Loads distinct product categories from
    --              FileUpload.OriginallyLoadedData into
    --              [CH01-01-Dimension].[DimProductCategory].
    --              Must run before Subcategory and Product loaders.
    -- =============================================

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimProductCategory]
        (ProductCategoryName, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT DISTINCT
        old.ProductCategory,
        @UserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM FileUpload.OriginallyLoadedData AS old
    WHERE old.ProductCategory IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM [CH01-01-Dimension].[DimProductCategory] pc
            WHERE pc.ProductCategoryName = old.ProductCategory
        );

    -- FIX: Capture BEFORE calling EXEC - @@ROWCOUNT resets after each statement
    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Process].[usp_LoadDimProductCategory]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @UserAuthorizationKey;
END;
GO


-- ============================================================
-- PROCEDURE 2: Load DimProductSubcategory (child of Category)
-- Must run after DimProductCategory, before DimProduct
-- ============================================================
CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimProductSubcategory]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- Author: Azm
    -- Procedure: [Process].[usp_LoadDimProductSubcategory]
    -- Create date: 2024
    -- Description: Loads distinct product subcategories and
    --              resolves their parent ProductCategoryKey via
    --              a join to DimProductCategory.
    --              Depends on DimProductCategory being loaded first.
    -- =============================================

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimProductSubcategory]
        (ProductSubcategoryName, ProductCategoryKey, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT DISTINCT
        old.ProductSubcategory,
        cat.ProductCategoryKey,
        @UserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM FileUpload.OriginallyLoadedData AS old
    JOIN [CH01-01-Dimension].[DimProductCategory] cat
        ON cat.ProductCategoryName = old.ProductCategory
    WHERE old.ProductSubcategory IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM [CH01-01-Dimension].[DimProductSubcategory] ps
            WHERE ps.ProductSubcategoryName = old.ProductSubcategory
        );

    -- FIX: Capture BEFORE calling EXEC
    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Process].[usp_LoadDimProductSubcategory]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @UserAuthorizationKey;
END;
GO


-- ============================================================
-- PROCEDURE 3: Load DimProduct (grandchild - deepest in hierarchy)
-- Must run after both Category and Subcategory are loaded
-- ============================================================
CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimProduct]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- Author: Azm
    -- Procedure: [Process].[usp_LoadDimProduct]
    -- Create date: 2024
    -- Description: Loads distinct products from source data,
    --              resolving ProductSubcategoryKey via join.
    --              Source column is ProductName (not Product).
    --              Depends on DimProductSubcategory being loaded first.
    -- =============================================

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimProduct]
        (ProductName, ProductSubcategoryKey, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT DISTINCT
        old.ProductName,
        sub.ProductSubcategoryKey,
        @UserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM FileUpload.OriginallyLoadedData AS old
    JOIN [CH01-01-Dimension].[DimProductSubcategory] sub
        ON sub.ProductSubcategoryName = old.ProductSubcategory
    WHERE old.ProductName IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM [CH01-01-Dimension].[DimProduct] p
            WHERE p.ProductName = old.ProductName
        );

    -- FIX: Capture BEFORE calling EXEC
    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Process].[usp_LoadDimProduct]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @UserAuthorizationKey;
END;
GO

PRINT '✅ Person 4 - All 3 product hierarchy procedures created (@@ROWCOUNT bug fixed)!';
GO
