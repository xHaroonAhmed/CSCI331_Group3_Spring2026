<div align="center">

# 📊 CSCI 331 — Database and Data Modeling
### Homework 7 · Chapter 8: Data Modification

![Course](https://img.shields.io/badge/Course-CSCI%20331-1F3864?style=for-the-badge)
![Group](https://img.shields.io/badge/Group-EOS_Group_3-2E5496?style=for-the-badge)
![Semester](https://img.shields.io/badge/Semester-Spring%202026-0078D4?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-Northwinds2024Student-107C10?style=for-the-badge)
![Format](https://img.shields.io/badge/Format-.ipynb%20Notebook-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Submitted-success?style=for-the-badge)

> *10 original business propositions solved using T-SQL Data Modification techniques against the Northwinds2024Student database, presented as an Azure Data Studio SQL Notebook.*

</div>


## 🎯 Assignment Overview

This assignment focused on **Chapter 8: Data Modification** from *T-SQL Fundamentals (4th Edition)* by Itzik Ben-Gan. Rather than answering predefined exercise questions, each group member was required to formulate **10 original business propositions** against the Northwinds2024Student database and solve each one using appropriate data modification techniques.

The deliverable is a **SQL Notebook (`.ipynb`)** designed for walkthrough presentation in **Azure Data Studio**. Each cell pair contains a business proposition (Markdown) followed by its query solution (SQL code cell).

---

## 📚 Concepts Learned

### ➕ INSERT Statements

Three forms of INSERT were practiced:

**Single-row INSERT:**
```sql
INSERT INTO dbo.CustomersStaging (CustomerId, CustomerCompanyName, ...)
VALUES (9001, N'Northwinds Test Account', N'USA', N'NY', N'New York');
```

**Multi-row INSERT (single statement):**
```sql
INSERT INTO dbo.CustomersStaging (CustomerId, CustomerCompanyName, ...)
VALUES
  (9002, N'Tokyo Traders Ltd',    N'Japan',  NULL, N'Tokyo'),
  (9003, N'Sao Paulo Supplies',   N'Brazil', NULL, N'Sao Paulo'),
  (9004, N'Berlin Wholesale GmbH',N'Germany',NULL, N'Berlin');
```

**INSERT from SELECT with EXISTS filter:**
```sql
INSERT INTO dbo.CustomersStaging (...)
SELECT C.CustomerId, C.CustomerCompanyName, ...
FROM Sales.Customers AS C
WHERE EXISTS (SELECT 1 FROM [Sales].[Order] AS O WHERE O.CustomerId = C.CustomerId);
```

---

### 📋 SELECT INTO

Creates and populates a new table in a single statement — no `CREATE TABLE` needed first:

```sql
SELECT *
INTO dbo.OrdersArchive
FROM [Sales].[Order]
WHERE OrderDate >= '20210101' AND OrderDate < '20230101';
```

**Key difference from INSERT INTO:** `SELECT INTO` creates the destination table automatically based on the source query's structure.

---

### ❌ DELETE Statements

**DELETE with EXISTS subquery** (avoids hardcoding IDs):
```sql
DELETE FROM dbo.OrdersArchive
WHERE EXISTS (
  SELECT 1 FROM dbo.CustomersStaging AS C
  WHERE dbo.OrdersArchive.CustomerId = C.CustomerId
    AND C.CustomerCountry = N'Germany'
);
```

**DELETE with OUTPUT clause** (audit trail):
```sql
DELETE FROM dbo.OrdersArchive
OUTPUT deleted.OrderId AS DeletedOrderId, deleted.OrderDate AS DeletedOrderDate
WHERE OrderDate < '20220101';
```

The `OUTPUT` clause captures each deleted row's data as it is removed — invaluable for compliance and audit logging.

---

### ✏️ UPDATE Statements

Three UPDATE patterns were applied:

**UPDATE with JOIN (T-SQL extension):**
```sql
UPDATE O
  SET O.ShipCountry = C.CustomerCountry
FROM dbo.OrdersArchive AS O
  INNER JOIN dbo.CustomersStaging AS C ON O.CustomerId = C.CustomerId;
```

**UPDATE through CTE (readable pattern):**
```sql
WITH CTE_SyncCity AS (
  SELECT O.ShipCity AS CurrentShipCity, C.CustomerCity AS CorrectCity
  FROM dbo.OrdersArchive AS O INNER JOIN dbo.CustomersStaging AS C ON O.CustomerId = C.CustomerId
)
UPDATE CTE_SyncCity SET CurrentShipCity = CorrectCity;
```

**UPDATE with OUTPUT (change audit):**
```sql
UPDATE dbo.CustomersStaging
  SET CustomerRegion = N'<None>'
OUTPUT deleted.CustomerId, deleted.CustomerRegion AS OldRegion, inserted.CustomerRegion AS NewRegion
WHERE CustomerRegion IS NULL;
```

The `deleted` and `inserted` virtual tables in OUTPUT allow you to capture both the before and after values of every updated row simultaneously.

---

### 🗑️ TRUNCATE vs DELETE

| Feature | `DELETE` | `TRUNCATE` |
|---------|----------|------------|
| Removes all rows | ✅ | ✅ |
| Can filter with WHERE | ✅ | ❌ |
| Logs each row | ✅ (full logging) | ✅ (minimal logging) |
| Resets identity seed | ❌ | ✅ |
| Works with FK constraints | ✅ | ❌ (must drop FK first) |
| Performance on large tables | Slower | Much faster |

**Pattern for truncating tables with FK constraints:**
```sql
ALTER TABLE dbo.OrdersArchive DROP CONSTRAINT FK_OrdersArchive_CustomersStaging;
TRUNCATE TABLE dbo.OrdersArchive;
TRUNCATE TABLE dbo.CustomersStaging;
-- Re-add constraint if needed
```

---

## 📝 Proposition Summary

| # | Business Proposition | Technique |
|---|---------------------|-----------|
| 1 | Insert a single test customer for QA validation | `INSERT INTO ... VALUES` |
| 2 | Bulk load only active customers into staging table | `INSERT INTO ... SELECT ... WHERE EXISTS` |
| 3 | Create a two-year order archive snapshot | `SELECT INTO` |
| 4 | Purge pre-2022 archive records with audit output | `DELETE ... OUTPUT deleted.*` |
| 5 | Remove all orders tied to Germany customers | `DELETE ... WHERE EXISTS` |
| 6 | Replace NULL regions with placeholder, log changes | `UPDATE ... OUTPUT deleted/inserted` |
| 7 | Sync archive shipping country from customer master | `UPDATE ... FROM ... JOIN` |
| 8 | Sync archive shipping city via CTE | `UPDATE through CTE` |
| 9 | Insert three new international accounts at once | `INSERT ... multi-row VALUES` |
| 10 | Truncate staging/archive tables across FK boundary | `DROP CONSTRAINT → TRUNCATE → ADD CONSTRAINT` |

---

## 🗄️ Working Tables Created

These tables are created as part of the notebook and cleaned up at the end:

```
Northwinds2024Student (dbo schema — working tables)
│
├── dbo.CustomersStaging
│   ├── CustomerId          INT NOT NULL PK
│   ├── CustomerCompanyName NVARCHAR(80)
│   ├── CustomerCountry     NVARCHAR(15)
│   ├── CustomerRegion      NVARCHAR(15) NULL
│   └── CustomerCity        NVARCHAR(15)
│
└── dbo.OrdersArchive
    └── (mirrors structure of Sales.[Order])
```

---

## 🏆 NACE Career Readiness Competencies

| Competency | Application in This Assignment |
|---|---|
| 🧠 **Critical Thinking** | Designed 10 distinct propositions covering every major DML operation; handled FK constraint edge cases and NULL replacement logic |
| 💬 **Communication** | Wrote each proposition in plain business language for non-technical audiences; structured notebook for clear walkthrough |
| 💻 **Technology** | Applied INSERT, UPDATE, DELETE, TRUNCATE, OUTPUT, SELECT INTO, CTE-based updates in Azure Data Studio SQL Notebook format |
| 🤝 **Teamwork** | Cross-trained group members on OUTPUT clause usage and multi-pattern UPDATE approaches |
| 🎯 **Professionalism** | Followed `.ipynb` submission format; disclosed LLM usage transparently per syllabus |
| 🌱 **Career & Self-Development** | Practiced formulating original business propositions — a skill directly applicable to professional database roles |

---

## 🛠️ Environment

| Tool | Details |
|------|---------|
| SQL Server | 2022 Developer Edition |
| Container | Docker |
| IDE | Azure Data Studio |
| Notebook Format | `.ipynb` (SQL Kernel) |
| Database | Northwinds2024Student |
| Textbook | T-SQL Fundamentals, 4th Ed. — Itzik Ben-Gan |

---

## 📌 LLM Disclosure

Claude and ChatGPT was consulted during this assignment to refine proposition wording and ensure that resulting output was as reader friendly as possible. All queries were independently constructed, reviewed, and understood by the author. The LLM's were used merely to enhance UX.


<div align="center">

*Queens College, CUNY · Computer Science Department*
*CSCI 331 — Database and Data Modeling · Prof. Heller · Spring 2026*

</div>
