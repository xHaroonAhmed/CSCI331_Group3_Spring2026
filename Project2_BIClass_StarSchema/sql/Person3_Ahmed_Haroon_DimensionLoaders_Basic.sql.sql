USE [BIClass]
GO

CREATE OR ALTER VIEW [EOS_Group_3].[vw_SrcDimCustomer] AS
SELECT DISTINCT CustomerName
FROM FileUpload.OriginallyLoadedData
WHERE CustomerName IS NOT NULL;
GO

CREATE OR ALTER VIEW [EOS_Group_3].[vw_SrcDimGender] AS
SELECT DISTINCT Gender
FROM FileUpload.OriginallyLoadedData
WHERE Gender IS NOT NULL;
GO

CREATE OR ALTER VIEW [EOS_Group_3].[vw_SrcDimMaritalStatus] AS
SELECT DISTINCT MaritalStatus
FROM FileUpload.OriginallyLoadedData
WHERE MaritalStatus IS NOT NULL;
GO

CREATE OR ALTER VIEW [EOS_Group_3].[vw_SrcDimOccupation] AS
SELECT DISTINCT Occupation
FROM FileUpload.OriginallyLoadedData
WHERE Occupation IS NOT NULL;
GO

CREATE OR ALTER VIEW [EOS_Group_3].[vw_SrcDimOrderDate] AS
SELECT DISTINCT 
    OrderDate,
    DATENAME(MONTH, OrderDate) AS MonthName,
    MONTH(OrderDate) AS MonthNumber,
    YEAR(OrderDate) AS [Year]
FROM FileUpload.OriginallyLoadedData
WHERE OrderDate IS NOT NULL;
GO

CREATE OR ALTER PROCEDURE [Project2].[Load_DimCustomer]
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimCustomer]
        (CustomerName, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT
        src.CustomerName,
        @GroupMemberUserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM [EOS_Group_3].[vw_SrcDimCustomer] AS src
    WHERE NOT EXISTS (
        SELECT 1
        FROM [CH01-01-Dimension].[DimCustomer] dc
        WHERE dc.CustomerName = src.CustomerName
    );

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Project2].[Load_DimCustomer]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @GroupMemberUserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Project2].[Load_DimGender]
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimGender]
        (Gender, GenderDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT
        src.Gender,
        src.Gender, 
        @GroupMemberUserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM [EOS_Group_3].[vw_SrcDimGender] AS src
    WHERE NOT EXISTS (
        SELECT 1
        FROM [CH01-01-Dimension].[DimGender] dg
        WHERE dg.Gender = src.Gender
    );

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Project2].[Load_DimGender]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @GroupMemberUserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Project2].[Load_DimMaritalStatus]
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimMaritalStatus]
        (MaritalStatus, MaritalStatusDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT
        src.MaritalStatus,
        src.MaritalStatus,  -- Use same value for description
        @GroupMemberUserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM [EOS_Group_3].[vw_SrcDimMaritalStatus] AS src
    WHERE NOT EXISTS (
        SELECT 1
        FROM [CH01-01-Dimension].[DimMaritalStatus] dms
        WHERE dms.MaritalStatus = src.MaritalStatus
    );

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Project2].[Load_DimMaritalStatus]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @GroupMemberUserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Project2].[Load_DimOccupation]
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimOccupation]
        (OccupationKey, Occupation, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT
        NEXT VALUE FOR PkSequence.DimOccupationSequenceObject,
        src.Occupation,
        @GroupMemberUserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM [EOS_Group_3].[vw_SrcDimOccupation] AS src
    WHERE NOT EXISTS (
        SELECT 1
        FROM [CH01-01-Dimension].[DimOccupation] doc
        WHERE doc.Occupation = src.Occupation
    );

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Project2].[Load_DimOccupation]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @GroupMemberUserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Project2].[Load_DimOrderDate]
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime  DATETIME2 = SYSDATETIME();
    DECLARE @RowCount   INT;

    INSERT INTO [CH01-01-Dimension].[DimOrderDate]
        (OrderDate, MonthName, MonthNumber, [Year],
         UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT
        src.OrderDate,
        src.MonthName,
        src.MonthNumber,
        src.[Year],
        @GroupMemberUserAuthorizationKey,
        SYSDATETIME(),
        SYSDATETIME()
    FROM [EOS_Group_3].[vw_SrcDimOrderDate] AS src
    WHERE NOT EXISTS (
        SELECT 1
        FROM [CH01-01-Dimension].[DimOrderDate] dod
        WHERE dod.OrderDate = src.OrderDate
    );

    SET @RowCount = @@ROWCOUNT;

    EXEC [Process].[usp_TrackWorkFlows]
        @StartTime                 = @StartTime,
        @WorkFlowDescription       = N'[Project2].[Load_DimOrderDate]',
        @WorkFlowStepTableRowCount = @RowCount,
        @UserAuthorizationKey      = @GroupMemberUserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimCustomer]
    @UserAuthorizationKey INT
AS
BEGIN
    EXEC [Project2].[Load_DimCustomer] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimGender]
    @UserAuthorizationKey INT
AS
BEGIN
    EXEC [Project2].[Load_DimGender] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimMaritalStatus]
    @UserAuthorizationKey INT
AS
BEGIN
    EXEC [Project2].[Load_DimMaritalStatus] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimOccupation]
    @UserAuthorizationKey INT
AS
BEGIN
    EXEC [Project2].[Load_DimOccupation] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey;
END;
GO

CREATE OR ALTER PROCEDURE [Process].[usp_LoadDimOrderDate]
    @UserAuthorizationKey INT
AS
BEGIN
    EXEC [Project2].[Load_DimOrderDate] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey;
END;
GO

PRINT '✅ Person 3 - All 5 procedures + alias wrappers created successfully!';
GO
