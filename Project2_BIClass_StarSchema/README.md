# Project 2 - Recreate the BIClass Database Star Schema
### CSCI 331 | EOS Group 3 | Class Time: 9:15 AM | Spring 2026

---

## Team Members

| Person | Name | Role |
|---|---|---|
| Person 1 | Andrew Laboy | Project Manager |
| Person 2 | Ralph Cange | Database Architect |
| Person 3 | Haroon Ahmed | ETL Developer 1 |
| Person 4 | Azm Karim | ETL Developer 2 |
| Person 5 | Mohamed Awad | ETL Developer 3 |
| Person 6 | Kazi Islam | Workflow Architect |
| Person 7 | Zhenkai Gao | JDBC Developer |

---

## Project Overview

This project recreates the BIClass Database Star Schema by loading data from `FileUpload.OriginallyLoadedData` into a complete star schema consisting of 10 dimension tables and 1 fact table. The ETL pipeline is built entirely using SQL Server stored procedures and is executed and monitored through a Java JDBC application built on top of the JDBC Class Library from Project 1.

---

## Database Information

| Property | Value |
|---|---|
| Database | BIClass |
| Server | localhost\SQLEXPRESS |
| Authentication | Windows Authentication |
| Source Table | FileUpload.OriginallyLoadedData |
| Total Rows Loaded | 80,095 |
| ETL Execution Time | ~4 seconds |

---

## Star Schema Tables

| Schema | Table | Rows | Loaded By |
|---|---|---|---|
| CH01-01-Dimension | DimCustomer | 18,400 | Person 3 |
| CH01-01-Dimension | DimGender | 2 | Person 3 |
| CH01-01-Dimension | DimMaritalStatus | 2 | Person 3 |
| CH01-01-Dimension | DimOccupation | 5 | Person 3 |
| CH01-01-Dimension | DimOrderDate | 1,124 | Person 3 |
| CH01-01-Dimension | DimProductCategory | 3 | Person 4 |
| CH01-01-Dimension | DimProductSubcategory | 17 | Person 4 |
| CH01-01-Dimension | DimProduct | 130 | Person 4 |
| CH01-01-Dimension | DimTerritory | 10 | Person 5 |
| CH01-01-Dimension | SalesManagers | 4 | Person 5 |
| CH01-01-Fact | Data | 60,398 | Person 5 |

---

## Project Files

### SQL Files (`/sql`)
| File | Description |
|---|---|
| `Person1_PM_AnalysisQueries.sql` | 12 business intelligence analysis queries |
| `Person2_DatabaseSetup_Infrastructure_FIXED.sql` | Schemas, sequences, tables, audit columns, tracking procedures |
| `Person3_DimensionLoaders_Basic.sql` | 5 dimension loader stored procedures |
| `Person4_DimensionLoaders_ProductHierarchy_FIXED.sql` | 3 product hierarchy loader stored procedures |
| `Person5_Territory_SalesManagers_FactTable.sql` | Territory, SalesManagers, and Fact table loaders |
| `Person6_MasterOrchestrator_ETL_FIXED.sql` | Master ETL orchestrator and workflow procedures |

### Java Files (`/src`)
| File | Location | Description |
|---|---|---|
| `ConnectionConfig.java` | connection/ | Database connection configuration |
| `DatabaseConnection.java` | connection/ | Connection pool management |
| `DatabaseException.java` | exception/ | Custom database exception |
| `ConnectionException.java` | exception/ | Custom connection exception |
| `WorkflowStepModel.java` | model/ | Model for workflow step rows |
| `BIClassApp.java` | ui/ | Main Swing UI application |

### Documentation (`/docs`)
| File | Description |
|---|---|
| `9_15 - Group 3 - Group Project 2.pptx` | Team PowerPoint presentation with voice annotations |

### Videos
| Video | Description | Length | Link |
|---|---|---|---|
| SSMS System Lifecycle Demo | Complete system lifecycle demo in VS Code | 12 min | [Watch on YouTube](PASTE_LINK_HERE) |
| JDBC Application Demo | Java JDBC application demonstration | 8 min | [Watch on YouTube](PASTE_LINK_HERE) |

---

## How to Run the SQL Files

Run the SQL files **in this exact order** in SSMS or VS Code connected to BIClass:

1. `Person2_DatabaseSetup_Infrastructure_FIXED.sql` — sets up everything
2. `Person3_DimensionLoaders_Basic.sql` — basic dimension loaders
3. `Person4_DimensionLoaders_ProductHierarchy_FIXED.sql` — product hierarchy loaders
4. `Person5_Territory_SalesManagers_FactTable.sql` — territory, sales managers, fact table
5. `Person6_MasterOrchestrator_ETL_FIXED.sql` — master orchestrator

Then run the ETL:
```sql
EXEC [Project2].[LoadStarSchemaData];
```

Then view the results:
```sql
EXEC [Process].[usp_ShowWorkflowSteps];
```

---

## How to Run the Java Application

### Prerequisites
- Java installed (https://adoptium.net/)
- SQL Server Express running with BIClass database restored
- All files in `lib/` folder

### Step 1 — Navigate to project folder
```
cd path\to\Project2_BIClass_StarSchema
```

### Step 2 — Compile
```
javac -cp "lib\mssql-jdbc-13.4.0.jre11.jar" -d out src\main\java\jdbc\connection\ConnectionConfig.java src\main\java\jdbc\connection\DatabaseConnection.java src\main\java\jdbc\exception\DatabaseException.java src\main\java\jdbc\exception\ConnectionException.java src\main\java\jdbc\model\WorkflowStepModel.java src\main\java\jdbc\ui\BIClassApp.java
```

### Step 3 — Run
```
java -cp "out;lib\mssql-jdbc-13.4.0.jre11.jar" "-Djava.library.path=lib" jdbc.ui.BIClassApp
```

### Step 4 — Use the App
- Click **Load Star Schema** to run the full ETL pipeline
- Click **Show Workflow Steps** to view execution results in the JTable

---

## ETL Pipeline Results

| Step | Procedure | Rows Loaded | Executed By |
|---|---|---|---|
| 1 | Load_DimProductCategory | 3 | Azm Karim |
| 2 | Load_DimProductSubcategory | 17 | Azm Karim |
| 3 | Load_DimProduct | 130 | Azm Karim |
| 4 | Load_DimCustomer | 18,400 | Haroon Ahmed |
| 5 | Load_DimGender | 2 | Haroon Ahmed |
| 6 | Load_DimMaritalStatus | 2 | Haroon Ahmed |
| 7 | Load_DimOccupation | 5 | Haroon Ahmed |
| 8 | Load_DimOrderDate | 1,124 | Haroon Ahmed |
| 9 | Load_DimTerritory | 10 | Mohamed Awad |
| 10 | Load_SalesManagers | 4 | Mohamed Awad |
| 11 | Load_Data (Fact Table) | 60,398 | Mohamed Awad |
| 12 | LoadStarSchemaData (Master) | 0 | Kazi Islam |

**Total: 80,095 rows loaded in ~4 seconds with 0 errors**

