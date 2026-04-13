---------------------------------------------------------------------
-- T-SQL Fundamentals Fourth Edition
-- Chapter 08 - Data Modification
-- Exercises
-- Ralph Cange
-- 4/09/26
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- The database assumed in the exercise is TSQLV6

-- 1
-- Run the following code to create the dbo.Customers table
-- in the TSQLV6 database
USE Northwinds2024Student;

DROP TABLE IF EXISTS dbo.Customers2;

CREATE TABLE dbo.Customers2
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);

-- 1-1
-- Insert into the dbo.Customers table a row with:
-- custid:  100
-- companyname: Coho Winery
-- country:     USA
-- region:      WA
-- city:        Redmond

INSERT INTO dbo.Customers2(custid, companyname, country, region, city)
VALUES                   
    ('100', 'Coho Winery', 'USA', 'WA', 'Redmond')

SELECT * FROM dbo.Customers2;

-- 1-2
-- Insert into the dbo.Customers table 
-- all customers from Sales.Customers
-- who placed orders

INSERT INTO dbo.Customers2(custid, companyname, country, region, city)
SELECT DISTINCT CustomerId, CustomerCompanyName, CustomerCountry, CustomerRegion, CustomerCity
FROM Sales.Customers AS C
WHERE EXISTS(
    SELECT *
    FROM Sales.[Order] AS O
    WHERE O.CustomerId = C.CustomerId
);

-- 1-3
-- Use a SELECT INTO statement to create and populate the dbo.Orders table
-- with orders from the Sales.Orders table
-- that were placed in the years 2020 through 2022

DROP TABLE IF EXISTS dbo.Orders2;

--CREATE TABLE dbo.Orders2(
--    orderid INT NOT NULL,
--    custid INT NOT NULL,
--    empid INT NOT NULL,
 --   orderdate DATE NOT NULL
 --   CONSTRAINT PK_ORDERS PRIMARY KEY(orderid)
 --   );

    SELECT *
    INTO dbo.Orders2
    FROM Sales.[Order]
    WHERE YEAR(OrderDate) = '2020'
    OR YEAR(OrderDate) = '2022';
    



-- 2
-- Delete from the dbo.Orders table
-- orders that were placed before August 2020
-- Use the OUTPUT clause to return the orderid and orderdate
-- of the deleted orders
DELETE FROM dbo.Orders2
OUTPUT 
deleted.orderid,
deleted.orderdate

WHERE orderdate < '20200801';







-- Desired output:
orderid     orderdate
----------- -----------
10248       2020-07-04 
10249       2020-07-05 
10250       2020-07-08 
10251       2020-07-08 
10252       2020-07-09 
10253       2020-07-10 
10254       2020-07-11 
10255       2020-07-12 
10256       2020-07-15 
10257       2020-07-16 
10258       2020-07-17 
10259       2020-07-18 
10260       2020-07-19 
10261       2020-07-19 
10262       2020-07-22 
10263       2020-07-23 
10264       2020-07-24 
10265       2020-07-25 
10266       2020-07-26 
10267       2020-07-29 
10268       2020-07-30 
10269       2020-07-31 

(22 rows affected)

-- 3
--- Delete from the dbo.Orders table orders placed by customers from Brazil

WITH O AS(
SELECT * 
FROM dbo.Orders2 as O2 
WHERE EXISTS(
SELECT * 
FROM Sales.Customers as C
WHERE C.CustomerId = O2.CustomerId
AND C.CustomerCountry = N'BRAZIL'
)
) 
DELETE O;


-- 4
-- Run the following query against dbo.Customers,
-- and notice that some rows have a NULL in the region column
SELECT * FROM dbo.Customers;

-- Output:
custid      companyname    country         region     city
----------- -------------- --------------- ---------- --------------- 
1           Customer NRZBB Germany         NULL       Berlin
2           Customer MLTDN Mexico          NULL       México D.F.
3           Customer KBUDE Mexico          NULL       México D.F.
4           Customer HFBZG UK              NULL       London
5           Customer HGVLZ Sweden          NULL       Luleå
6           Customer XHXJV Germany         NULL       Mannheim
7           Customer QXVLA France          NULL       Strasbourg
8           Customer QUHWH Spain           NULL       Madrid
9           Customer RTXGC France          NULL       Marseille
10          Customer EEALV Canada          BC         Tsawassen
...

(90 rows affected)

-- Update the dbo.Customers table and change all NULL region values to '<None>'
-- Use the OUTPUT clause to show the custid, old region and new region

UPDATE dbo.Customers2
SET region = '<None>'
OUTPUT
inserted.custid,
deleted.region as oldregion,
inserted.region as newregion
WHERE
region IS NULL;



-- Desired output:
custid      oldregion       newregion
----------- --------------- ---------------
1           NULL            <None>
2           NULL            <None>
3           NULL            <None>
4           NULL            <None>
5           NULL            <None>
6           NULL            <None>
7           NULL            <None>
8           NULL            <None>
9           NULL            <None>
11          NULL            <None>
12          NULL            <None>
13          NULL            <None>
14          NULL            <None>
16          NULL            <None>
17          NULL            <None>
18          NULL            <None>
19          NULL            <None>
20          NULL            <None>
23          NULL            <None>
24          NULL            <None>
25          NULL            <None>
26          NULL            <None>
27          NULL            <None>
28          NULL            <None>
29          NULL            <None>
30          NULL            <None>
39          NULL            <None>
40          NULL            <None>
41          NULL            <None>
44          NULL            <None>
49          NULL            <None>
50          NULL            <None>
52          NULL            <None>
53          NULL            <None>
54          NULL            <None>
56          NULL            <None>
58          NULL            <None>
59          NULL            <None>
60          NULL            <None>
63          NULL            <None>
64          NULL            <None>
66          NULL            <None>
68          NULL            <None>
69          NULL            <None>
70          NULL            <None>
72          NULL            <None>
73          NULL            <None>
74          NULL            <None>
76          NULL            <None>
79          NULL            <None>
80          NULL            <None>
83          NULL            <None>
84          NULL            <None>
85          NULL            <None>
86          NULL            <None>
87          NULL            <None>
90          NULL            <None>
91          NULL            <None>

(58 rows affected)

-- 5
-- Update in the dbo.Orders table all orders placed by UK customers
-- and set their shipcountry, shipregion, shipcity values
-- to the country, region, city values of the corresponding customers from dbo.Customers

MERGE INTO dbo.Orders2 
USING 
(SELECT * 
FROM dbo.Customers2 
WHERE country = N'UK'
) as C
ON CustomerId = C.custid
WHEN MATCHED THEN
UPDATE SET
ShipToCountry = C.country,
ShipToRegion = C.region,
ShipToCity = C.city
;



    

-- 6
-- Run  the following code to create the tables dbo.Orders and dbo.OrderDetails and populate them with data

USE NorthWinds2024Student;

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders2;

CREATE TABLE dbo.Orders2
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  shipperid      INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders2(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders2 SELECT * FROM Sales.[Order];
INSERT INTO dbo.OrderDetails SELECT OrderId, ProductId, UnitPrice, Quantity,
DiscountPercentage FROM Sales.OrderDetail;



-- Write and test the T-SQL code that is required to truncate both tables,
-- and make sure that your code runs successfully

ALTER TABLE dbo.OrderDetails DROP CONSTRAINT FK_OrderDetails_Orders;

TRUNCATE TABLE dbo.OrderDetails;
TRUNCATE TABLE dbo.Orders2;

-- When you're done, run the following code for cleanup
DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders2, dbo.Customers2;
