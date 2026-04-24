USE BIClass;
GO

-- ============================================================
-- Person 6 (Kazi) - Workflow Architect / Master ETL Orchestrator
-- 05_Workflow_MasterProcedures.sql  --  FIXED VERSION
-- Fix: AddForeignKeysToStarSchemaData now restores ALL star
--      schema foreign keys, not just WorkflowSteps.
--      Previously dropped all FKs but only re-added one.
-- ============================================================

-- ============================================================
-- PROCEDURE 1: Drop ALL Foreign Keys before truncating
-- ============================================================
CREATE OR ALTER PROCEDURE [Project2].[DropForeignKeysFromStarSchemaData]
AS
BEGIN
    -- =============================================
    -- Author: Kazi
    -- Procedure: [Project2].[DropForeignKeysFromStarSchemaData]
    -- Create date: 2024
    -- Description: Dynamically drops all foreign key constraints
    --              in the star schema schemas so tables can be
    --              safely truncated before a full reload.
    -- =============================================
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = '';

    SELECT @SQL = @SQL +
        'ALTER TABLE [' + SCHEMA_NAME(fk.schema_id) + '].[' + OBJECT_NAME(fk.parent_object_id) + '] ' +
        'DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
    FROM sys.foreign_keys fk
    WHERE SCHEMA_NAME(fk.schema_id) IN ('CH01-01-Fact', 'CH01-01-Dimension', 'Process');

    IF LEN(@SQL) > 0
        EXEC sp_executesql @SQL;

    PRINT '✅ All star schema foreign keys dropped';
END;
GO


-- ============================================================
-- PROCEDURE 2: Truncate All Star Schema Data + Reset Sequences
-- ============================================================
CREATE OR ALTER PROCEDURE [Project2].[TruncateStarSchemaData]
AS
BEGIN
    -- =============================================
    -- Author: Kazi
    -- Procedure: [Project2].[TruncateStarSchemaData]
    -- Create date: 2024
    -- Description: Truncates all star schema tables in
    --              correct order (fact first, then dimensions)
    --              and resets all sequence objects.
    --              Must be called AFTER DropForeignKeys.
    -- =============================================
    SET NOCOUNT ON;

    -- Fact table first (references all dimensions)
    TRUNCATE TABLE [CH01-01-Fact].[Data];

    -- Dimension tables (child before parent for product hierarchy)
    TRUNCATE TABLE [CH01-01-Dimension].[DimProduct];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProductSubcategory];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProductCategory];
    TRUNCATE TABLE [CH01-01-Dimension].[DimCustomer];
    TRUNCATE TABLE [CH01-01-Dimension].[DimGender];
    TRUNCATE TABLE [CH01-01-Dimension].[DimMaritalStatus];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOccupation];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOrderDate];
    TRUNCATE TABLE [CH01-01-Dimension].[SalesManagers];
    TRUNCATE TABLE [CH01-01-Dimension].[DimTerritory];

    -- Reset workflow steps so each full run starts fresh
    TRUNCATE TABLE Process.WorkflowSteps;

    -- Reset all sequences back to 1
    EXEC [Process].[usp_ResetAllSequences];

    PRINT '✅ All tables truncated and sequences reset';
END;
GO


-- ============================================================
-- PROCEDURE 3: Add ALL Foreign Keys Back After Loading
-- FIX: Original only re-added WorkflowSteps FK.
--      Now restores the full star schema FK structure.
-- ============================================================
CREATE OR ALTER PROCEDURE [Project2].[AddForeignKeysToStarSchemaData]
AS
BEGIN
    -- =============================================
    -- Author: Kazi
    -- Procedure: [Project2].[AddForeignKeysToStarSchemaData]
    -- Create date: 2024
    -- Description: Re-creates all foreign key constraints
    --              in the star schema after data has been loaded.
    --              Must be called AFTER all dimension and fact
    --              table loaders have completed.
    -- =============================================
    SET NOCOUNT ON;

    -- Product hierarchy FKs
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_DimProductCategory')
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
            ADD CONSTRAINT [FK_DimProductSubcategory_DimProductCategory]
            FOREIGN KEY (ProductCategoryKey)
            REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_DimProductSubcategory')
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
            ADD CONSTRAINT [FK_DimProduct_DimProductSubcategory]
            FOREIGN KEY (ProductSubcategoryKey)
            REFERENCES [CH01-01-Dimension].[DimProductSubcategory](ProductSubcategoryKey);

    -- UserAuthorization FKs for all dimension tables
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductCategory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProductCategory]
            ADD CONSTRAINT [FK_DimProductCategory_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
            ADD CONSTRAINT [FK_DimProductSubcategory_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimCustomer_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimCustomer]
            ADD CONSTRAINT [FK_DimCustomer_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimGender_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimGender]
            ADD CONSTRAINT [FK_DimGender_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMaritalStatus_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus]
            ADD CONSTRAINT [FK_DimMaritalStatus_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOccupation_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimOccupation]
            ADD CONSTRAINT [FK_DimOccupation_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOrderDate_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimOrderDate]
            ADD CONSTRAINT [FK_DimOrderDate_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
            ADD CONSTRAINT [FK_DimProduct_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimTerritory_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[DimTerritory]
            ADD CONSTRAINT [FK_DimTerritory_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SalesManagers_UserAuthorization')
        ALTER TABLE [CH01-01-Dimension].[SalesManagers]
            ADD CONSTRAINT [FK_SalesManagers_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    -- WorkflowSteps FK
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_WorkflowSteps_UserAuthorization')
        ALTER TABLE Process.WorkflowSteps
            ADD CONSTRAINT [FK_WorkflowSteps_UserAuthorization]
            FOREIGN KEY (UserAuthorizationKey)
            REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey);

    PRINT '✅ All star schema foreign keys restored';
END;
GO


-- ============================================================
-- PROCEDURE 4: Master ETL Orchestrator
-- Executes the complete ETL pipeline in correct order
-- ============================================================
CREATE OR ALTER PROCEDURE [Project2].[LoadStarSchemaData]
AS
BEGIN
    -- =============================================
    -- Author: Kazi
    -- Procedure: [Project2].[LoadStarSchemaData]
    -- Create date: 2024
    -- Description: Master orchestrator for the complete ETL
    --              pipeline. Drops FKs, truncates tables,
    --              loads all dimensions and fact table in the
    --              correct dependency order, then restores FKs.
    --              Call this one procedure to reload the entire
    --              star schema from FileUpload.OriginallyLoadedData.
    -- =============================================
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    PRINT '========================================';
    PRINT 'EOS Group 3 - Starting ETL Pipeline';
    PRINT '========================================';

    -- Step 1: Drop all foreign keys before truncating
    PRINT 'Step 1: Dropping all foreign keys...';
    EXEC [Project2].[DropForeignKeysFromStarSchemaData];

    -- Step 2: Truncate all tables and reset sequences
    PRINT 'Step 2: Truncating tables and resetting sequences...';
    EXEC [Project2].[TruncateStarSchemaData];

    -- Step 3: Load dimensions (parents before children!)
    PRINT 'Step 3: Loading dimensions...';

    -- Person 4: Product hierarchy (Category -> Subcategory -> Product)
    PRINT '  Loading DimProductCategory (Person 4)...';
    EXEC [Process].[usp_LoadDimProductCategory] @UserAuthorizationKey = 4;

    PRINT '  Loading DimProductSubcategory (Person 4)...';
    EXEC [Process].[usp_LoadDimProductSubcategory] @UserAuthorizationKey = 4;

    PRINT '  Loading DimProduct (Person 4)...';
    EXEC [Process].[usp_LoadDimProduct] @UserAuthorizationKey = 4;

    -- Person 3: Independent dimensions (no hierarchy dependencies)
    PRINT '  Loading DimCustomer (Person 3)...';
    EXEC [Project2].[Load_DimCustomer] @GroupMemberUserAuthorizationKey = 3;

    PRINT '  Loading DimGender (Person 3)...';
    EXEC [Project2].[Load_DimGender] @GroupMemberUserAuthorizationKey = 3;

    PRINT '  Loading DimMaritalStatus (Person 3)...';
    EXEC [Project2].[Load_DimMaritalStatus] @GroupMemberUserAuthorizationKey = 3;

    PRINT '  Loading DimOccupation (Person 3)...';
    EXEC [Project2].[Load_DimOccupation] @GroupMemberUserAuthorizationKey = 3;

    PRINT '  Loading DimOrderDate (Person 3)...';
    EXEC [Project2].[Load_DimOrderDate] @GroupMemberUserAuthorizationKey = 3;

    -- Person 5: Territory and SalesManagers
    PRINT '  Loading DimTerritory (Person 5)...';
    EXEC [Process].[usp_LoadDimTerritory] @UserAuthorizationKey = 5;

    PRINT '  Loading SalesManagers (Person 5)...';
    EXEC [Process].[usp_LoadSalesManagers] @UserAuthorizationKey = 5;

    -- Step 4: Load fact table AFTER all dimensions are populated
    PRINT 'Step 4: Loading fact table (Person 5)...';
    EXEC [Process].[usp_LoadFactData] @UserAuthorizationKey = 5;

    -- Step 5: Restore all foreign key constraints
    PRINT 'Step 5: Restoring all foreign keys...';
    EXEC [Project2].[AddForeignKeysToStarSchemaData];

    -- Track master ETL in workflow log
    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Project2].[LoadStarSchemaData] - Complete ETL Pipeline',
        @WorkFlowStepTableRowCount = 0,
        @UserAuthorizationKey      = 6;

    PRINT '========================================';
    PRINT '✅ ETL COMPLETE!';
    PRINT 'Run: EXEC [Process].[usp_ShowWorkflowSteps]';
    PRINT '========================================';
END;
GO


-- ============================================================
-- PROCEDURE 5: Show Workflow Execution Log (for JTable display)
-- ============================================================
CREATE OR ALTER PROCEDURE [Process].[usp_ShowWorkflowSteps]
AS
BEGIN
    -- =============================================
    -- Author: Kazi
    -- Procedure: [Process].[usp_ShowWorkflowSteps]
    -- Create date: 2024
    -- Description: Returns the complete workflow execution log
    --              with timing, row counts, and team member info.
    --              Results are loaded into a JTable in the
    --              JDBC application for presentation.
    -- =============================================
    SET NOCOUNT ON;

    SELECT
        ws.WorkFlowStepKey                                              AS [Step],
        ws.WorkFlowStepDescription                                      AS [Procedure],
        ws.WorkFlowStepTableRowCount                                    AS [Rows Loaded],
        ws.StartingDateTime                                             AS [Start Time],
        ws.EndingDateTime                                               AS [End Time],
        DATEDIFF(MILLISECOND, ws.StartingDateTime, ws.EndingDateTime)   AS [Duration (ms)],
        ua.GroupMemberFirstName + ' ' + ua.GroupMemberLastName          AS [Executed By],
        ua.UserAuthorizationKey                                         AS [Person #]
    FROM Process.WorkflowSteps ws
    JOIN DbSecurity.UserAuthorization ua
        ON ua.UserAuthorizationKey = ws.UserAuthorizationKey
    ORDER BY ws.StartingDateTime ASC;
END;
GO

PRINT '✅ Person 6 - All 5 master orchestrator procedures created (AddForeignKeys bug fixed)!';
GO
