USE BIClass;
GO

-- =============================================
-- STEP 0A: Drop FK constraints before dropping tables
--          Must go in child -> parent order
-- =============================================

-- Drop FK on DimProduct that points to DimProductSubcategory
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DimProduct_DimProductSubcategory'
)
BEGIN
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
        DROP CONSTRAINT [FK_DimProduct_DimProductSubcategory];
END
GO

-- Drop FK on DimProductSubcategory that points to DimProductCategory
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DimProductSubcategory_DimProductCategory'
)
BEGIN
    ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
        DROP CONSTRAINT [FK_DimProductSubcategory_DimProductCategory];
END
GO

-- Drop FK on DimProductSubcategory that points to UserAuthorization
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DimProductSubcategory_UserAuthorization'
)
BEGIN
    ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
        DROP CONSTRAINT [FK_DimProductSubcategory_UserAuthorization];
END
GO

-- Drop FK on DimProductCategory that points to UserAuthorization
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DimProductCategory_UserAuthorization'
)
BEGIN
    ALTER TABLE [CH01-01-Dimension].[DimProductCategory]
        DROP CONSTRAINT [FK_DimProductCategory_UserAuthorization];
END
GO

-- =============================================
-- STEP 0B: Now safely drop tables child -> parent
-- =============================================
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductSubcategory];
GO
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductCategory];
GO


-- =============================================
-- STEP 0: Create PkSequence schema if needed
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'PkSequence')
BEGIN
    EXEC('CREATE SCHEMA PkSequence')
END
GO

-- =============================================
-- STEP 1: Create Sequence objects
-- =============================================
DROP SEQUENCE IF EXISTS PkSequence.DimProductCategorySequenceObject;
GO
CREATE SEQUENCE PkSequence.DimProductCategorySequenceObject
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    NO CYCLE
    CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimProductSubcategorySequenceObject;
GO
CREATE SEQUENCE PkSequence.DimProductSubcategorySequenceObject
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    NO CYCLE
    CACHE 10;
GO

-- Add sequences for any other tables as needed
DROP SEQUENCE IF EXISTS PkSequence.DimProductSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimProductSequenceObject
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    NO CYCLE
    CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimCustomerSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimCustomerSequenceObject
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    NO CYCLE
    CACHE 10;
GO

-- =============================================
-- STEP 2: Create DimProductCategory table
--         SEQUENCE replaces IDENTITY for PK
-- =============================================
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductCategory];
GO

CREATE TABLE [CH01-01-Dimension].[DimProductCategory]
(
    ProductCategoryKey      INT             NOT NULL
        CONSTRAINT [DF_DimProductCategory_ProductCategoryKey]
            DEFAULT (NEXT VALUE FOR PkSequence.DimProductCategorySequenceObject)
        CONSTRAINT [PK_DimProductCategory] PRIMARY KEY,
    ProductCategoryName     NVARCHAR(50)    NOT NULL,
    UserAuthorizationKey    INT             NOT NULL    DEFAULT 1,
    DateAdded               DATETIME2(7)    NULL        DEFAULT SYSDATETIME(),
    DateOfLastUpdate        DATETIME2(7)    NULL        DEFAULT SYSDATETIME(),

    CONSTRAINT [FK_DimProductCategory_UserAuthorization]
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey)
);
GO

-- =============================================
-- STEP 3: Create DimProductSubcategory table
-- =============================================
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductSubcategory];
GO

CREATE TABLE [CH01-01-Dimension].[DimProductSubcategory]
(
    ProductSubcategoryKey   INT             NOT NULL
        CONSTRAINT [DF_DimProductSubcategory_ProductSubcategoryKey]
            DEFAULT (NEXT VALUE FOR PkSequence.DimProductSubcategorySequenceObject)
        CONSTRAINT [PK_DimProductSubcategory] PRIMARY KEY,
    ProductSubcategoryName  NVARCHAR(50)    NOT NULL,
    ProductCategoryKey      INT             NOT NULL,
    UserAuthorizationKey    INT             NOT NULL    DEFAULT 1,
    DateAdded               DATETIME2(7)    NULL        DEFAULT SYSDATETIME(),
    DateOfLastUpdate        DATETIME2(7)    NULL        DEFAULT SYSDATETIME(),

    CONSTRAINT [FK_DimProductSubcategory_DimProductCategory]
        FOREIGN KEY (ProductCategoryKey)
        REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey),

    CONSTRAINT [FK_DimProductSubcategory_UserAuthorization]
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey)
);
GO

-- =============================================
-- STEP 4: Add FK + SubcategoryKey to DimProduct
-- =============================================
-- Only add column if it doesn't already exist
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimProduct]')
    AND name = 'ProductSubcategoryKey'
)
BEGIN
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD ProductSubcategoryKey INT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DimProduct_DimProductSubcategory'
)
BEGIN
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD CONSTRAINT [FK_DimProduct_DimProductSubcategory]
            FOREIGN KEY (ProductSubcategoryKey)
            REFERENCES [CH01-01-Dimension].[DimProductSubcategory](ProductSubcategoryKey);
END
GO

-- =============================================
-- STEP 5: Helper to reset all sequences
--         Call this before a full reload
-- =============================================
CREATE OR ALTER PROCEDURE [Process].[usp_ResetAllSequences]
AS
BEGIN
    ALTER SEQUENCE PkSequence.DimProductCategorySequenceObject    RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductSubcategorySequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductSequenceObject            RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimCustomerSequenceObject           RESTART WITH 1;
    -- Add all other sequences here
END
GO

-- =============================================
-- STEP 6: Master load procedure
-- =============================================
CREATE OR ALTER PROCEDURE [Process].[usp_LoadStarSchema]
    @TruncateData         BIT = 0,
    @UserAuthorizationKey INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @TruncateData = 1
    BEGIN
        -- Child tables first (reverse FK order)
        TRUNCATE TABLE [CH01-01-Dimension].[DimProduct];
        TRUNCATE TABLE [CH01-01-Dimension].[DimProductSubcategory];
        TRUNCATE TABLE [CH01-01-Dimension].[DimProductCategory];
        TRUNCATE TABLE [CH01-01-Dimension].[DimCustomer];
        -- NOTE: FileUpload.OriginallyLoadedData intentionally excluded

        -- Reset sequences to stay in sync after truncate
        EXEC Process.usp_ResetAllSequences;
    END

    EXEC [Process].[usp_LoadDimProductCategory]     @UserAuthorizationKey = @UserAuthorizationKey;
    EXEC [Process].[usp_LoadDimProductSubcategory]  @UserAuthorizationKey = @UserAuthorizationKey;
    EXEC [Process].[usp_LoadDimProduct]             @UserAuthorizationKey = @UserAuthorizationKey;
    EXEC [Process].[usp_LoadDimCustomer]            @UserAuthorizationKey = @UserAuthorizationKey;
END
GO