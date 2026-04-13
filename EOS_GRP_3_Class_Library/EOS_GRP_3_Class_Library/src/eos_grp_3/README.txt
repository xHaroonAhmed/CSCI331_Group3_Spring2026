EOS_GRP_3_Class_Library
========================
Java Database Connectivity (JDBC) Class Library
Group: EOS_grp_3
Course: CSCI331 - Database Class

========================================================
OVERVIEW
========================================================
EOS_GRP_3_Class_Library is a JDBC class 
library built using Microsoft SQL Server JDBC Driver.
It connects to the NorthWinds2024Student database and 
provides a  interface for performing 
database operations using the Abstract Factory design 
pattern.

This library is integrated into all class projects for 
the remainder of the semester.

========================================================
DESIGN PATTERN
========================================================

In this library:
- IDataSource         = Abstract factory interface
- DBConnection        = Concrete factory implementation
- DataSourceFactory   = Factory provider
- IDataRepository<T>  = Generic CRUD interface
- Repositories        = Concrete implementations

========================================================
PROJECT STRUCTURE
========================================================
EOS_GRP_3_Class_Library/
|
+-- lib/
|   +-- mssql-jdbc-12.x.x.jar        (MSSQL JDBC Driver)
|
+-- src/
    +-- eos_grp_3/
        |
        +-- module-info.java
        +-- Driver.java               (Main demo class)
        |
        +-- interfaces/
        |   +-- IDataSource.java      (Connection interface)
        |   +-- IDataRepository.java  (CRUD interface)
        |
        +-- connection/
        |   +-- DBConnection.java     (SQL Server connection)
        |
        +-- factory/
        |   +-- DataSourceFactory.java (Factory provider)
        |
        +-- repositories/
            +-- CustomerRepository.java
            +-- EmployeeRepository.java
            +-- OrderRepository.java

========================================================
REQUIREMENTS
========================================================
- Java 17 (JavaSE-17)
- Eclipse IDE
- Microsoft SQL Server (running on port 14001)
- NorthWinds2024Student database
- mssql-jdbc-13.4.0.jre11.jar (included in lib/ folder)

========================================================
DATABASE CONNECTION
========================================================
Server:   localhost
Port:     14001
Database: NorthWinds2024Student
User:     sa

Connection URL format:
jdbc:sqlserver://localhost:14001;
databaseName=NorthWinds2024Student;
encrypt=false;
trustServerCertificate=true

========================================================
STORED PROCEDURES
========================================================
The stored procedures must be created in the
NorthWinds2024Student database before running the 
library. Run these scripts:

-- Employee by ID
CREATE OR ALTER PROCEDURE 
    HumanResources.usp_GetEmployeeById
    @EmployeeId INT
AS
BEGIN
    SELECT EmployeeId, EmployeeLastName, EmployeeFirstName
    FROM HumanResources.Employee
    WHERE EmployeeId = @EmployeeId;
END;

-- Customer by ID
CREATE OR ALTER PROCEDURE 
    Sales.usp_GetCustomerById
    @CustomerId INT
AS
BEGIN
    SELECT CustomerId, CustomerCompanyName, CustomerCountry
    FROM Sales.Customers
    WHERE CustomerId = @CustomerId;
END;

-- Order by ID
CREATE OR ALTER PROCEDURE 
    Sales.usp_GetOrderById
    @OrderId INT
AS
BEGIN
    SELECT OrderId, CustomerId, OrderDate
    FROM Sales.[Order]
    WHERE OrderId = @OrderId;
END;

========================================================
REPOSITORY OPERATIONS
========================================================

EmployeeRepository
------------------
- getAll()        : Returns all employees
- getById(int id) : Returns employee by ID
                    (uses usp_GetEmployeeById)
- update(String)  : Updates EmployeeCountry by ID

CustomerRepository
------------------
- getAll()        : Returns all customers
- getById(int id) : Returns customer by ID
                    (uses usp_GetCustomerById)

OrderRepository
---------------
- getAll()        : Returns all orders
- getById(int id) : Returns order by ID
                    (uses usp_GetOrderById)

========================================================
ECLIPSE SETUP INSTRUCTIONS
========================================================
1. Clone the repository:
   https://github.com/xHaroonAhmed/CSCI331_Group3_Spring2026/tree/main/EOS_GRP_3_Class_Library

2. In Eclipse:
   File -> Import -> Git -> Projects from Git
   Select Clone URI -> paste repository URL -> Finish

3. Add the MSSQL JDBC Driver:
   Right-click project -> Build Path -> Add External JARs
   Select mssql-jdbc-13.4.0.jre11.jar from the lib/ folder

4. Update module-info.java if needed:
   module EOS_GRP_3_Class_Library {
       requires java.sql;
       requires com.microsoft.sqlserver.jdbc;
   }

5. Run the stored procedure scripts in SSMS
   (see STORED PROCEDURES section above)

6. Run Driver.java to test all connections

========================================================
EXPECTED OUTPUT
========================================================
[EOS_GRP_3] MSSQL Driver loaded successfully.
[EOS_GRP_3] Connection established successfully.

========== All Employees ==========
1 - Davolio, Nancy
2 - Fuller, Andrew
...

========== Employee ID 9 ==========
9 - Dodsworth, Anne

========== Update Employee 9 Country ==========
Rows affected: 1

========== All Customers ==========
1 - Alfreds Futterkiste | Germany
2 - Ana Trujillo | Mexico
...

========== Customer ID 5 ==========
5 - Berglunds snabbkop | Sweden

========== All Orders ==========
Order#: 10248 | CustId: 85 | Date: 2020-07-04
...

========== Order ID 10248 ==========
Order#: 10248 | CustId: 85 | Date: 2020-07-04



========================================================
GROUP MEMBERS
========================================================
Group: EOS_grp_3

- [Member 1 Ahmed Haroon] - Role
- [Member 2 Alhubaishi Ameen] - Role
- [Member 3 Awad Mohamed] - Role
- [Member 4 Cange Ralph] - Role
- [Member 5 Gao, Zhenkai] - Role
- [Member 6 Islam, Kazi] - Role
- [Member 7 Karim, Azm] - Role
- [Member 8 Roberts, Nicholas] - Role


Project Manager: [Ralph Cange] (submits on behalf of group)

========================================================
RESOURCES
========================================================
- Microsoft JDBC Driver Download:
  https://learn.microsoft.com/en-us/sql/connect/jdbc/
  download-microsoft-jdbc-driver-for-sql-server

- JDBC Documentation:
  https://en.wikipedia.org/wiki/Java_Database_Connectivity

- Abstract Factory Pattern:
  https://en.wikipedia.org/wiki/Abstract_factory_pattern

- Design Patterns (Gang of Four):
  https://en.wikipedia.org/wiki/Design_Patterns


