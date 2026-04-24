USE BIClass;
GO

CREATE OR ALTER PROCEDURE [Project2].[DropForeignKeysFromStarSchemaData]
AS
BEGIN
 
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

CREATE OR ALTER PROCEDURE [Project2].[TruncateStarSchemaData]
AS
BEGIN
  
    SET NOCOUNT ON;

    TRUNCATE TABLE [CH01-01-Fact].[Data];

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

    TRUNCATE TABLE Process.WorkflowSteps;

    EXEC [Process].[usp_ResetAllSequences];

    PRINT '✅ All tables truncated and sequences reset';
END;
GO

CREATE OR ALTER PROCEDURE [Project2].[AddForeignKeysToStarSchemaData]
AS
BEGIN

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

CREATE OR ALTER PROCEDURE [Project2].[LoadStarSchemaData]
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    PRINT '========================================';
    PRINT 'EOS Group 3 - Starting ETL Pipeline';
    PRINT '========================================';

    PRINT 'Step 1: Dropping all foreign keys...';
    EXEC [Project2].[DropForeignKeysFromStarSchemaData];

    PRINT 'Step 2: Truncating tables and resetting sequences...';
    EXEC [Project2].[TruncateStarSchemaData];

    PRINT 'Step 3: Loading dimensions...';

    PRINT '  Loading DimProductCategory (Person 4)...';
    EXEC [Process].[usp_LoadDimProductCategory] @UserAuthorizationKey = 4;

    PRINT '  Loading DimProductSubcategory (Person 4)...';
    EXEC [Process].[usp_LoadDimProductSubcategory] @UserAuthorizationKey = 4;

    PRINT '  Loading DimProduct (Person 4)...';
    EXEC [Process].[usp_LoadDimProduct] @UserAuthorizationKey = 4;

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

    PRINT '  Loading DimTerritory (Person 5)...';
    EXEC [Process].[usp_LoadDimTerritory] @UserAuthorizationKey = 5;

    PRINT '  Loading SalesManagers (Person 5)...';
    EXEC [Process].[usp_LoadSalesManagers] @UserAuthorizationKey = 5;

    PRINT 'Step 4: Loading fact table (Person 5)...';
    EXEC [Process].[usp_LoadFactData] @UserAuthorizationKey = 5;

    PRINT 'Step 5: Restoring all foreign keys...';
    EXEC [Project2].[AddForeignKeysToStarSchemaData];

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

CREATE OR ALTER PROCEDURE [Process].[usp_ShowWorkflowSteps]
AS
BEGIN

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
