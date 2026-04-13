=====================================================================
T-SQL Fundamentals - Fourth Edition
Chapter 08 - Data Modification
Homework #7
=====================================================================
Student:  Ralph Cange
Group:    EOS_grp_3
Course:   CSCI331 - Database Class
Date:     04/09/2026
File:     Individual_EOS_GRP_3_HW7_RALPH_CANGE.sql
Database: Northwinds2024Student
=====================================================================

=====================================================================
OVERVIEW
=====================================================================
This assignment covers Chapter 8 of T-SQL Fundamentals (4th Edition)
by Itzik Ben-Gan. It focuses on Data Modification techniques in 
T-SQL including INSERT, SELECT INTO, DELETE with OUTPUT, UPDATE with
OUTPUT, MERGE, and TRUNCATE operations.

All queries have been adapted from the TSQLV6 textbook database to
work with the Northwinds2024Student Named Database.

=====================================================================
REQUIREMENTS
=====================================================================
- Microsoft SQL Server
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Northwinds2024Student database
- Access to the following schemas and tables:
    Sales.Customers
    Sales.[Order]
    Sales.OrderDetail
    dbo.Customers2   (created by this script)
    dbo.Orders2      (created by this script)
    dbo.OrderDetails (created by this script)

=====================================================================
FILE STRUCTURE
=====================================================================
Individual_EOS_GRP_3_HW7_RALPH_CANGE.sql
  |
  +-- Exercise 1:   Table Setup (dbo.Customers2)
  |     +-- 1-1:   INSERT single row
  |     +-- 1-2:   INSERT from Sales.Customers using EXISTS
  |     +-- 1-3:   SELECT INTO dbo.Orders2 (2020-2022)
  |
  +-- Exercise 2:   DELETE with OUTPUT clause
  |                 (orders before August 2020)
  |
  +-- Exercise 3:   DELETE using CTE + EXISTS
  |                 (orders from Brazil customers)
  |
  +-- Exercise 4:   UPDATE with OUTPUT clause
  |                 (NULL region -> '<None>')
  |
  +-- Exercise 5:   MERGE statement
  |                 (update UK orders with customer info)
  |
  +-- Exercise 6:   Table Setup (dbo.Orders2 + dbo.OrderDetails)
        +--         INSERT from Sales.[Order] and Sales.OrderDetail
        +--         TRUNCATE both tables
        +--         Cleanup (DROP all tables)

=====================================================================
EXERCISE SUMMARIES
=====================================================================

EXERCISE 1 - Table Creation and INSERT
---------------------------------------
Creates dbo.Customers2 with columns:
  custid, companyname, country, region, city

1-1: Inserts a single customer row:
     custid=100, Coho Winery, USA, WA, Redmond

1-2: Inserts all customers from Sales.Customers
     who have placed at least one order.
     Uses DISTINCT to prevent PRIMARY KEY violations
     from duplicate customer records.

1-3: Uses SELECT INTO to create and populate dbo.Orders2
     with orders placed in years 2020 through 2022.

---------------------------------------------------------------

EXERCISE 2 - DELETE with OUTPUT
---------------------------------------
Deletes orders from dbo.Orders2 placed before 
August 1, 2020 and returns deleted rows using OUTPUT.

Expected: 22 rows affected
Columns returned: orderid, orderdate

---------------------------------------------------------------

EXERCISE 3 - DELETE using CTE + EXISTS
---------------------------------------
Deletes orders from dbo.Orders2 placed by customers
whose country is Brazil.

Uses a CTE with EXISTS subquery against Sales.Customers
to identify matching orders.

NOTE: Country value must match exactly. 
      Sales.Customers stores 'Brazil' not 'BRAZIL'.
      Update the WHERE clause if needed:
      AND C.CustomerCountry = N'Brazil'

---------------------------------------------------------------

EXERCISE 4 - UPDATE with OUTPUT
---------------------------------------
Updates dbo.Customers2 to replace NULL region values
with the string '<None>'.

Uses OUTPUT clause to display:
  custid, old region (deleted.region), new region (inserted.region)

Expected: 58 rows affected

---------------------------------------------------------------

EXERCISE 5 - MERGE
---------------------------------------
Updates dbo.Orders2 for all orders placed by UK customers.
Sets ShipToCountry, ShipToRegion, ShipToCity values to
match the corresponding customer's country, region, city
from dbo.Customers2.

Uses MERGE with WHEN MATCHED THEN UPDATE.

---------------------------------------------------------------

EXERCISE 6 - Orders2 + OrderDetails Setup and TRUNCATE
---------------------------------------
Recreates dbo.Orders2 and dbo.OrderDetails with full
schema including constraints and foreign keys.

Populates tables:
  dbo.Orders2      <- Sales.[Order]
  dbo.OrderDetails <- Sales.OrderDetail
                      (OrderId, ProductId, UnitPrice,
                       Quantity, DiscountPercentage)

TRUNCATE sequence (handles foreign key constraint):
  1. DROP FK_OrderDetails_Orders constraint
  2. TRUNCATE dbo.OrderDetails
  3. TRUNCATE dbo.Orders2

Cleanup:
  DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders2, dbo.Customers2

=====================================================================
DATABASE ADJUSTMENTS FROM TEXTBOOK
=====================================================================
The textbook uses TSQLV6. This homework uses Northwinds2024Student.
The following column name mappings were applied:

TSQLV6 Column          Northwinds2024Student Column
--------------------   --------------------------------
CustomerId             CustomerId
CompanyName            CustomerCompanyName
Country                CustomerCountry
Region                 CustomerRegion
City                   CustomerCity
ShipCountry            ShipToCountry
ShipRegion             ShipToRegion
ShipCity               ShipToCity
OrderDate              OrderDate
UnitPrice              UnitPrice
Qty                    Quantity
Discount               DiscountPercentage

=====================================================================
KNOWN ISSUES AND FIXES APPLIED
=====================================================================

Issue 1: PRIMARY KEY violation on INSERT (Exercise 1-2)
  Fix:    Added DISTINCT to SELECT statement to remove
          duplicate customer records before insert.

Issue 2: Column mismatch on INSERT INTO dbo.Orders2
  Fix:    Explicitly mapped source columns from Sales.[Order]
          instead of using SELECT *.

Issue 3: String truncation on UPDATE (Exercise 4)
  Fix:    Confirmed correct column name is EmployeeCountry
          and used appropriate column in SET clause.

Issue 4: Brazil DELETE not matching rows (Exercise 3)
  Fix:    Ensure country string case matches exactly:
          N'Brazil' (not N'BRAZIL')

Issue 5: TRUNCATE fails due to foreign key constraint
  Fix:    DROP FK_OrderDetails_Orders before TRUNCATE,
          then TRUNCATE child table before parent table.

=====================================================================
HOW TO RUN
=====================================================================
1. Open SSMS or Azure Data Studio
2. Connect to your SQL Server instance
3. Open Individual_EOS_GRP_3_HW7_RALPH_CANGE.sql
4. Ensure Northwinds2024Student database is available
5. Run the script section by section (highlight + F5)
   or run the full script at once

NOTE: Run exercises in order. Later exercises depend on
      tables created in earlier exercises.

=====================================================================
EXPECTED RESULTS SUMMARY
=====================================================================

Exercise 1-1:  1 row inserted  (custid = 100)
Exercise 1-2:  varies          (customers with orders, no dupes)
Exercise 1-3:  varies          (orders from 2020-2022)
Exercise 2:    22 rows deleted (orders before Aug 2020)
Exercise 3:    varies          (Brazil customer orders deleted)
Exercise 4:    58 rows updated (NULL region -> '<None>')
Exercise 5:    varies          (UK orders shipto updated)
Exercise 6:    Tables truncated successfully after FK drop

=====================================================================
REFERENCES
=====================================================================
- T-SQL Fundamentals, Fourth Edition
  Author:    Itzik Ben-Gan
  Publisher: Pearson / Microsoft Press
  ISBN:      9780138102029
  Chapter:   08 - Data Modification

- Northwinds2024Student Database (Named Database)
  Course:    CSCI331 - Database Class

- Supplemental SQL Videos:
  http://bit.ly/CSCI331SupplementalSqlVideos

- Course Homework Examples:
  http://bit.ly/CSCI331-Homework

=====================================================================
SUBMISSION FORMAT
=====================================================================
File submitted as:
Individual_EOS_GRP_3_HW#7_RALPH_CANGE.sql

Submitted by: Ralph Cange
On behalf of: EOS_grp_3
=====================================================================
