USE BIClass;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimProductCategory]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

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

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Process].[usp_LoadDimProductCategory]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @UserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimProductSubcategory]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

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

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Process].[usp_LoadDimProductSubcategory]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @UserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimProduct]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

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
