-- ============================================================
-- File:        05_Workflow_MasterProcedures.sql
-- Project:     PROJECT 2 RECREATE THE BICLASS DATABASE STAR SCHEMA
-- Group:       EOS_grp_3
-- Author:      Kazi Islam (Person 6 - Workflow Architect)
-- Description: Contains all workflow management stored procedures.
--              Includes DropForeignKeysFromStarSchemaData,
--              TruncateStarSchemaData, AddForeignKeysToStarSchemaData,
--              and usp_ShowWorkflowSteps.
--              Must be run after 01_DatabaseSchema_SetupFixed.sql.
--              NOTE: If you get a duplicate key error on WorkflowSteps
--              during testing, run this to fix it:
--              ALTER SEQUENCE PkSequence.WorkflowStepsSequenceObject
--              RESTART WITH <MAX(WorkFlowStepKey) + 1>;
-- ============================================================

USE BIClass;
GO

-- =============================================
-- Procedure:   [Project2].[DropForeignKeysFromStarSchemaData]
-- Description: Drops all FK constraints from the star schema
--              so tables can be truncated without errors.
--              Drops fact table FKs first, then dimension FKs.
--              Called by LoadStarSchemaData before truncating.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[DropForeignKeysFromStarSchemaData]
    @UserAuthorizationKey INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    -- ----------------------------------------
    -- Drop Fact table FKs first
    -- Must be dropped before dimension tables
    -- ----------------------------------------
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_SalesManagers')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_SalesManagers;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimGender')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimGender;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimMaritalStatus')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimMaritalStatus;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimOccupation')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimOccupation;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimOrderDate')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimOrderDate;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimTerritory')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimTerritory;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimProduct')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimProduct;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Data_DimCustomer')
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT FK_Data_DimCustomer;

    -- ----------------------------------------
    -- Drop Dimension FKs
    -- Grandchild before parent
    -- ----------------------------------------
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_DimProductSubcategory')
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
            DROP CONSTRAINT FK_DimProduct_DimProductSubcategory;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_DimProductCategory')
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
            DROP CONSTRAINT FK_DimProductSubcategory_DimProductCategory;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
            DROP CONSTRAINT FK_DimProductSubcategory_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductCategory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProductCategory]
            DROP CONSTRAINT FK_DimProductCategory_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
            DROP CONSTRAINT FK_DimProduct_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimCustomer_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimCustomer]
            DROP CONSTRAINT FK_DimCustomer_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimGender_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimGender]
            DROP CONSTRAINT FK_DimGender_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMaritalStatus_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus]
            DROP CONSTRAINT FK_DimMaritalStatus_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOccupation_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimOccupation]
            DROP CONSTRAINT FK_DimOccupation_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOrderDate_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimOrderDate]
            DROP CONSTRAINT FK_DimOrderDate_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimTerritory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimTerritory]
            DROP CONSTRAINT FK_DimTerritory_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SalesManagers_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[SalesManagers]
            DROP CONSTRAINT FK_SalesManagers_UserAuthorization;

    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_WorkflowSteps_UserAuthorization')
        ALTER TABLE [Process].[WorkflowSteps]
            DROP CONSTRAINT FK_WorkflowSteps_UserAuthorization;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime = @StartTime,
        @WorkFlowDescription = N'Drop Foreign Keys From Star Schema',
        @WorkFlowStepTableRowCount = 0,
        @UserAuthorizationKey = @UserAuthorizationKey;
END
GO


-- =============================================
-- Procedure:   [Project2].[TruncateStarSchemaData]
-- Description: Truncates all star schema tables and resets
--              all data sequences back to 1.
--              Does NOT reset WorkflowSteps sequence so that
--              audit log entries are never overwritten.
--              Called by LoadStarSchemaData after dropping FKs.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[TruncateStarSchemaData]
    @UserAuthorizationKey INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    -- ----------------------------------------
    -- Truncate fact table first
    -- Then dimensions (parent last)
    -- ----------------------------------------
    TRUNCATE TABLE [CH01-01-Fact].[Data];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProduct];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProductSubcategory];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProductCategory];
    TRUNCATE TABLE [CH01-01-Dimension].[DimCustomer];
    TRUNCATE TABLE [CH01-01-Dimension].[DimGender];
    TRUNCATE TABLE [CH01-01-Dimension].[DimMaritalStatus];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOccupation];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOrderDate];
    TRUNCATE TABLE [CH01-01-Dimension].[DimTerritory];
    TRUNCATE TABLE [CH01-01-Dimension].[SalesManagers];

    -- ----------------------------------------
    -- Reset data sequences only
    -- WorkflowSteps sequence is intentionally
    -- excluded to preserve audit log ordering
    -- ----------------------------------------
    ALTER SEQUENCE PkSequence.DimCustomerSequenceObject           RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimGenderSequenceObject             RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimMaritalStatusSequenceObject      RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimOccupationSequenceObject         RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimOrderDateSequenceObject          RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductSequenceObject            RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductCategorySequenceObject    RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductSubcategorySequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimTerritorySequenceObject          RESTART WITH 1;
    ALTER SEQUENCE PkSequence.SalesManagersSequenceObject         RESTART WITH 1;
    ALTER SEQUENCE PkSequence.FactDataSequenceObject              RESTART WITH 1;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime = @StartTime,
        @WorkFlowDescription = N'Truncate Star Schema Data',
        @WorkFlowStepTableRowCount = 0,
        @UserAuthorizationKey = @UserAuthorizationKey;
END
GO


-- =============================================
-- Procedure:   [Project2].[AddForeignKeysToStarSchemaData]
-- Description: Recreates all FK constraints after the star
--              schema has been loaded with fresh data.
--              Uses IF NOT EXISTS to avoid duplicate FK errors.
--              Called by LoadStarSchemaData after all dims loaded.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[AddForeignKeysToStarSchemaData]
    @UserAuthorizationKey INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    -- ----------------------------------------
    -- Dimension FKs (parent before child)
    -- ----------------------------------------
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_DimProductCategory')
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
            ADD CONSTRAINT FK_DimProductSubcategory_DimProductCategory
            FOREIGN KEY (ProductCategoryKey)
            REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_DimProductSubcategory')
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
            ADD CONSTRAINT FK_DimProduct_DimProductSubcategory
            FOREIGN KEY (ProductSubcategoryKey)
            REFERENCES [CH01-01-Dimension].[DimProductSubcategory](ProductSubcategoryKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductCategory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProductCategory]
            ADD CONSTRAINT FK_DimProductCategory_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
            ADD CONSTRAINT FK_DimProductSubcategory_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
            ADD CONSTRAINT FK_DimProduct_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimCustomer_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimCustomer]
            ADD CONSTRAINT FK_DimCustomer_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimGender_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimGender]
            ADD CONSTRAINT FK_DimGender_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMaritalStatus_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus]
            ADD CONSTRAINT FK_DimMaritalStatus_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOccupation_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimOccupation]
            ADD CONSTRAINT FK_DimOccupation_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOrderDate_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimOrderDate]
            ADD CONSTRAINT FK_DimOrderDate_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimTerritory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimTerritory]
            ADD CONSTRAINT FK_DimTerritory_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SalesManagers_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[SalesManagers]
            ADD CONSTRAINT FK_SalesManagers_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_WorkflowSteps_UserAuthorization')
        ALTER TABLE [Process].[WorkflowSteps]
            ADD CONSTRAINT FK_WorkflowSteps_UserAuthorization
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime = @StartTime,
        @WorkFlowDescription = N'Add Foreign Keys To Star Schema',
        @WorkFlowStepTableRowCount = 0,
        @UserAuthorizationKey = @UserAuthorizationKey;
END
GO


-- =============================================
-- Procedure:   [Process].[usp_ShowWorkflowSteps]
-- Description: Queries Process.WorkflowSteps joined to
--              UserAuthorization to show who did what,
--              how many rows were affected, and how long
--              each step took in milliseconds.
--              Used by Person 7 for JTable display in
--              the JDBC application demo video.
-- =============================================
CREATE OR ALTER PROCEDURE [Process].[usp_ShowWorkflowSteps]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ws.WorkFlowStepKey,
        ws.WorkFlowStepDescription,
        ws.WorkFlowStepTableRowCount,
        ws.StartingDateTime,
        ws.EndingDateTime,
        DATEDIFF(MILLISECOND, ws.StartingDateTime, ws.EndingDateTime) AS ExecutionTimeMS,
        ws.ClassTime,
        ua.GroupMemberFirstName + ' ' + ua.GroupMemberLastName AS GroupMember
    FROM Process.WorkflowSteps AS ws
    INNER JOIN DbSecurity.UserAuthorization AS ua
        ON ua.UserAuthorizationKey = ws.UserAuthorizationKey
    ORDER BY ws.WorkFlowStepKey;
END
GO


-- ============================================================
-- VERIFICATION: Run to confirm all procs work correctly
-- ============================================================

EXEC [Project2].[DropForeignKeysFromStarSchemaData] @UserAuthorizationKey = 6;
EXEC [Project2].[TruncateStarSchemaData] @UserAuthorizationKey = 6;
EXEC [Project2].[AddForeignKeysToStarSchemaData] @UserAuthorizationKey = 6;

-- Reload product dimensions after truncate
EXEC [Process].[usp_LoadDimProductCategory] @UserAuthorizationKey = 6;
EXEC [Process].[usp_LoadDimProductSubcategory] @UserAuthorizationKey = 6;
EXEC [Process].[usp_LoadDimProduct] @UserAuthorizationKey = 6;

-- Show full workflow log
EXEC [Process].[usp_ShowWorkflowSteps];

-- =============================================
-- Procedure:   [Project2].[LoadStarSchemaData]
-- Description: Master orchestration procedure that runs
--              the full ETL pipeline in correct order.
--              Drops FKs, truncates, loads all dimensions,
--              loads fact table, then recreates FKs.
--              This is the main proc called by Person 7
--              in the JDBC application.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[LoadStarSchemaData]
    @UserAuthorizationKey INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    -- Drop all foreign keys before truncating
    EXEC [Project2].[DropForeignKeysFromStarSchemaData]
        @UserAuthorizationKey = @UserAuthorizationKey;

    -- Truncate all tables and reset sequences
    EXEC [Project2].[TruncateStarSchemaData]
        @UserAuthorizationKey = @UserAuthorizationKey;

    -- Load dimensions in correct order (parent before child)
    EXEC [Process].[usp_LoadDimProductCategory]
        @UserAuthorizationKey = @UserAuthorizationKey;
    EXEC [Process].[usp_LoadDimProductSubcategory]
        @UserAuthorizationKey = @UserAuthorizationKey;
    EXEC [Process].[usp_LoadDimProduct]
        @UserAuthorizationKey = @UserAuthorizationKey;

    -- NOTE: Persons 3 and 5 procs go here once they are done
    -- EXEC [Process].[usp_LoadDimCustomer]        @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadDimGender]          @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadDimMaritalStatus]   @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadDimOccupation]      @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadDimOrderDate]       @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadDimTerritory]       @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadSalesManagers]      @UserAuthorizationKey = @UserAuthorizationKey;
    -- EXEC [Process].[usp_LoadFactData]           @UserAuthorizationKey = @UserAuthorizationKey;

    -- Recreate all foreign keys after loading
    EXEC [Project2].[AddForeignKeysToStarSchemaData]
        @UserAuthorizationKey = @UserAuthorizationKey;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime = @StartTime,
        @WorkFlowDescription = N'Load Star Schema Data - Master',
        @WorkFlowStepTableRowCount = 0,
        @UserAuthorizationKey = @UserAuthorizationKey;
END
GO