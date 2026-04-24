USE [BIClass];
GO


IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_WorkflowSteps_UserAuthorization')
    ALTER TABLE [Process].[WorkflowSteps] DROP CONSTRAINT [FK_WorkflowSteps_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_DimProductSubcategory')
    ALTER TABLE [CH01-01-Dimension].[DimProduct] DROP CONSTRAINT [FK_DimProduct_DimProductSubcategory];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_DimProductCategory')
    ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory] DROP CONSTRAINT [FK_DimProductSubcategory_DimProductCategory];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductSubcategory_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory] DROP CONSTRAINT [FK_DimProductSubcategory_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProductCategory_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimProductCategory] DROP CONSTRAINT [FK_DimProductCategory_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimCustomer_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimCustomer] DROP CONSTRAINT [FK_DimCustomer_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimGender_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimGender] DROP CONSTRAINT [FK_DimGender_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMaritalStatus_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] DROP CONSTRAINT [FK_DimMaritalStatus_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOccupation_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimOccupation] DROP CONSTRAINT [FK_DimOccupation_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimOrderDate_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimOrderDate] DROP CONSTRAINT [FK_DimOrderDate_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimProduct] DROP CONSTRAINT [FK_DimProduct_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimTerritory_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[DimTerritory] DROP CONSTRAINT [FK_DimTerritory_UserAuthorization];
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SalesManagers_UserAuthorization')
    ALTER TABLE [CH01-01-Dimension].[SalesManagers] DROP CONSTRAINT [FK_SalesManagers_UserAuthorization];
GO


DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductSubcategory];
GO
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductCategory];
GO
DROP TABLE IF EXISTS [Process].[WorkflowSteps];
GO
DROP TABLE IF EXISTS [DbSecurity].[UserAuthorization];
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DbSecurity')
    EXEC('CREATE SCHEMA DbSecurity');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Process')
    EXEC('CREATE SCHEMA Process');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'PkSequence')
    EXEC('CREATE SCHEMA PkSequence');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Project2')
    EXEC('CREATE SCHEMA Project2');
GO

-- FIX: This schema is required by Person 3's source views
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'EOS_Group_3')
    EXEC('CREATE SCHEMA EOS_Group_3');
GO


DROP SEQUENCE IF EXISTS PkSequence.DimCustomerSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimCustomerSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimGenderSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimGenderSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimMaritalStatusSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimMaritalStatusSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimOccupationSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimOccupationSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimOrderDateSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimOrderDateSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimProductSequenceObject;
GO
CREATE SEQUENCE PkSequence.DimProductSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimProductCategorySequenceObject;
GO
CREATE SEQUENCE PkSequence.DimProductCategorySequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimProductSubcategorySequenceObject;
GO
CREATE SEQUENCE PkSequence.DimProductSubcategorySequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.DimTerritorySequenceObject;
GO
CREATE SEQUENCE PkSequence.DimTerritorySequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.SalesManagersSequenceObject;
GO
CREATE SEQUENCE PkSequence.SalesManagersSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.FactDataSequenceObject;
GO
CREATE SEQUENCE PkSequence.FactDataSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

DROP SEQUENCE IF EXISTS PkSequence.WorkflowStepsSequenceObject;
GO
CREATE SEQUENCE PkSequence.WorkflowStepsSequenceObject
    AS INT START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE NO CYCLE CACHE 10;
GO

CREATE TABLE DbSecurity.UserAuthorization
(
    UserAuthorizationKey    INT             NOT NULL PRIMARY KEY,
    ClassTime               NCHAR(5)        NULL DEFAULT (N'9:15'),
    IndividualProject       NVARCHAR(60)    NULL DEFAULT (N'PROJECT 2 RECREATE THE BICLASS DATABASE STAR SCHEMA'),
    GroupMemberLastName     NVARCHAR(35)    NOT NULL,
    GroupMemberFirstName    NVARCHAR(25)    NOT NULL,
    GroupName               NVARCHAR(20)    NOT NULL,
    DateAdded               DATETIME2(7)    NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO DbSecurity.UserAuthorization
    (UserAuthorizationKey, GroupMemberLastName, GroupMemberFirstName, GroupName, ClassTime)
VALUES
    (1, 'Laboy',   'Andrew',  'EOS_Group_3', N'9:15'),
    (2, 'Ralph',   'Ralph',   'EOS_Group_3', N'9:15'),
    (3, 'Haroon',  'Haroon',  'EOS_Group_3', N'9:15'),
    (4, 'Azm',     'Azm',     'EOS_Group_3', N'9:15'),
    (5, 'Awad',    'Mohamed', 'EOS_Group_3', N'9:15'),
    (6, 'Kazi',    'Kazi',    'EOS_Group_3', N'9:15'),
    (7, 'Zhenkai', 'Zhenkai', 'EOS_Group_3', N'9:15');
GO

CREATE TABLE Process.WorkflowSteps
(
    WorkFlowStepKey             INT             NOT NULL
        CONSTRAINT [DF_WorkflowSteps_WorkFlowStepKey]
            DEFAULT (NEXT VALUE FOR PkSequence.WorkflowStepsSequenceObject)
        CONSTRAINT [PK_WorkflowSteps] PRIMARY KEY,
    WorkFlowStepDescription     NVARCHAR(100)   NOT NULL,
    WorkFlowStepTableRowCount   INT             NULL DEFAULT (0),
    StartingDateTime            DATETIME2(7)    NULL DEFAULT SYSDATETIME(),
    EndingDateTime              DATETIME2(7)    NULL DEFAULT SYSDATETIME(),
    ClassTime                   CHAR(5)         NULL DEFAULT ('9:15'),
    UserAuthorizationKey        INT             NOT NULL,

    CONSTRAINT [FK_WorkflowSteps_UserAuthorization]
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey)
);
GO

CREATE TABLE [CH01-01-Dimension].[DimProductCategory]
(
    ProductCategoryKey      INT             NOT NULL
        CONSTRAINT [DF_DimProductCategory_ProductCategoryKey]
            DEFAULT (NEXT VALUE FOR PkSequence.DimProductCategorySequenceObject)
        CONSTRAINT [PK_DimProductCategory] PRIMARY KEY,
    ProductCategoryName     NVARCHAR(50)    NOT NULL,
    UserAuthorizationKey    INT             NOT NULL DEFAULT 1,
    DateAdded               DATETIME2(7)    NULL DEFAULT SYSDATETIME(),
    DateOfLastUpdate        DATETIME2(7)    NULL DEFAULT SYSDATETIME(),

    CONSTRAINT [FK_DimProductCategory_UserAuthorization]
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey)
);
GO

CREATE TABLE [CH01-01-Dimension].[DimProductSubcategory]
(
    ProductSubcategoryKey   INT             NOT NULL
        CONSTRAINT [DF_DimProductSubcategory_ProductSubcategoryKey]
            DEFAULT (NEXT VALUE FOR PkSequence.DimProductSubcategorySequenceObject)
        CONSTRAINT [PK_DimProductSubcategory] PRIMARY KEY,
    ProductSubcategoryName  NVARCHAR(50)    NOT NULL,
    ProductCategoryKey      INT             NOT NULL,
    UserAuthorizationKey    INT             NOT NULL DEFAULT 1,
    DateAdded               DATETIME2(7)    NULL DEFAULT SYSDATETIME(),
    DateOfLastUpdate        DATETIME2(7)    NULL DEFAULT SYSDATETIME(),

    CONSTRAINT [FK_DimProductSubcategory_DimProductCategory]
        FOREIGN KEY (ProductCategoryKey)
        REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey),

    CONSTRAINT [FK_DimProductSubcategory_UserAuthorization]
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey)
);
GO


IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimProduct]')
    AND name = 'ProductSubcategoryKey'
)
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD ProductSubcategoryKey INT NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimProduct_DimProductSubcategory'
)
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD CONSTRAINT [FK_DimProduct_DimProductSubcategory]
            FOREIGN KEY (ProductSubcategoryKey)
            REFERENCES [CH01-01-Dimension].[DimProductSubcategory](ProductSubcategoryKey);
GO

-- DimCustomer
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimCustomer]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimCustomer] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimCustomer]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimCustomer] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimCustomer]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimCustomer] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- DimGender
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimGender]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimGender] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimGender]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimGender] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimGender]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimGender] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- DimMaritalStatus
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimMaritalStatus]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimMaritalStatus]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimMaritalStatus]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- DimOccupation
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimOccupation]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimOccupation] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimOccupation]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimOccupation] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimOccupation]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimOccupation] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- DimOrderDate
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimOrderDate]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimOrderDate] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimOrderDate]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimOrderDate] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimOrderDate]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimOrderDate] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- DimProduct
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimProduct]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimProduct] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimProduct]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimProduct] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimProduct]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimProduct] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- DimTerritory
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimTerritory]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[DimTerritory] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimTerritory]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[DimTerritory] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[DimTerritory]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[DimTerritory] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- SalesManagers
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[SalesManagers]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Dimension].[SalesManagers] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[SalesManagers]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Dimension].[SalesManagers] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Dimension].[SalesManagers]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Dimension].[SalesManagers] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO

-- Fact Table
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Fact].[Data]') AND name = 'UserAuthorizationKey')
    ALTER TABLE [CH01-01-Fact].[Data] ADD UserAuthorizationKey INT NOT NULL DEFAULT 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Fact].[Data]') AND name = 'DateAdded')
    ALTER TABLE [CH01-01-Fact].[Data] ADD DateAdded DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[CH01-01-Fact].[Data]') AND name = 'DateOfLastUpdate')
    ALTER TABLE [CH01-01-Fact].[Data] ADD DateOfLastUpdate DATETIME2(7) NULL DEFAULT SYSDATETIME();
GO


CREATE OR ALTER PROCEDURE [Process].[usp_TrackWorkFlows]
    @StartTime                  DATETIME2,
    @WorkFlowDescription        NVARCHAR(100),
    @WorkFlowStepTableRowCount  INT,
    @UserAuthorizationKey       INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Process.WorkflowSteps
    (
        WorkFlowStepDescription,
        WorkFlowStepTableRowCount,
        StartingDateTime,
        EndingDateTime,
        ClassTime,
        UserAuthorizationKey
    )
    VALUES
    (
        @WorkFlowDescription,
        @WorkFlowStepTableRowCount,
        @StartTime,
        SYSDATETIME(),
        '9:15',
        @UserAuthorizationKey
    );
END
GO

CREATE OR ALTER PROCEDURE [Process].[usp_ResetAllSequences]
AS
BEGIN
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
    ALTER SEQUENCE PkSequence.WorkflowStepsSequenceObject         RESTART WITH 1;
END
GO


SELECT 'UserAuthorization rows'       AS Check_Item, COUNT(*) AS Result FROM DbSecurity.UserAuthorization
UNION ALL
SELECT 'WorkflowSteps exists',         COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Process'           AND TABLE_NAME = 'WorkflowSteps'
UNION ALL
SELECT 'Sequences in PkSequence',      COUNT(*) FROM sys.sequences                WHERE schema_id = SCHEMA_ID('PkSequence')
UNION ALL
SELECT 'DimProductCategory exists',    COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'CH01-01-Dimension' AND TABLE_NAME = 'DimProductCategory'
UNION ALL
SELECT 'DimProductSubcategory exists', COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'CH01-01-Dimension' AND TABLE_NAME = 'DimProductSubcategory'
UNION ALL
SELECT 'EOS_Group_3 schema exists',    COUNT(*) FROM sys.schemas                  WHERE name = 'EOS_Group_3';
GO

PRINT '✅ Person 2 - Infrastructure setup complete!';
GO
