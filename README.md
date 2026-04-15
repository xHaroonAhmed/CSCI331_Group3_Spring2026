<div align="center">

<img src="https://img.shields.io/badge/Queens%20College-CUNY-003087?style=for-the-badge&logoColor=white"/>
<img src="https://img.shields.io/badge/Computer%20Science-Department-CC0000?style=for-the-badge"/>

# CSCI 331 — Database and Data Modeling
### EOS_Group_3 · Spring 2026

![Professor](https://img.shields.io/badge/Professor-Peter%20Heller-1F3864?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-Northwinds2024Student-107C10?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-T--SQL-CC2927?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-SQL%20Server%202022-0078D4?style=for-the-badge)

> *A collaborative repository containing all group homework assignments, SQL notebooks, query solutions, and documentation for CSCI 331 — Database and Data Modeling at Queens College, CUNY.*

</div>

---

## 🏫 About the Course

**CSCI 331 — Database and Data Modeling** is a graduate-level computer science course at Queens College, City University of New York. The course provides a practical, hands-on approach to understanding relational database theory using ANSI SQL and Entity Relationship Modeling, implemented in a Windows 11 environment with Microsoft SQL Server 2022.

### Topics Covered
- SQL Server Architecture and T-SQL Querying
- Single and Multi-table Queries, Joins, and Set Theory
- Subqueries and Table Expressions
- Set Operators
- Data Modification (INSERT, UPDATE, DELETE, MERGE)
- Indexing, Foreign Keys, and Physical Database Design
- User-Defined Datatypes, Temporal Tables, and Triggers
- Database Normalization and Data Modeling
- Conceptual, Logical, and Physical Data Models
- Entity Relationship Diagrams (ERD)

### Tools & Environment

| Tool | Purpose |
|------|---------|
| SQL Server 2022 Developer Edition | Primary database engine |
| Docker | Container for SQL Server instance |
| Azure Data Studio | SQL Notebook authoring and query execution |
| SSMS (SQL Server Management Studio) | Database management and query testing |
| VS Code | Code editing and documentation |
| Excel + PowerQuery | Data reporting and transformation |
| Erwin DM | Entity Relationship Diagram modeling |

---

## 👥 Group Members — EOS_Group_3

| Name | GitHub |
|------|--------|
| **Mohamed Awad** | [@Mosmoove](https://github.com/Mosmoove) |
| **Zhenkai Gao** | [@hgzmw](https://github.com/hgzmw) |
| **Kazi Islam** | [@kaziislam11](https://github.com/kaziislam11) |
| **Azm Karim** | [@Azmk1](https://github.com/Azmk1) |
| **Nicholas Roberts** | — |
| **Haroon Ahmed** | [@xHaroonAhmed](https://github.com/xHaroonAhmed) |
| **Ralph Cange** | [@rcange-14](https://github.com/rcange-14) |

---

## 📚 Homework Overview

| HW | Chapter | Topic | Format | Database |
|----|---------|-------|--------|---------|
| [HW 7](./HW%207/) | Ch. 8 | Data Modification | `.ipynb` | Northwinds2024Student |

---

## 🗄️ Database

All assignments are implemented against the **Northwinds2024Student** database — a custom academic version of the classic Microsoft Northwind database, adapted by Prof. Heller for the course. The database models a fictional international trading company and includes tables for customers, orders, employees, products, and suppliers.

### Key Schema Areas

```
Northwinds2024Student
│
├── Sales
│   ├── [Order]          — Customer orders
│   ├── OrderDetail      — Line items per order
│   └── Customers        — Customer master data
│
├── HumanResources
│   └── Employee         — Employee records
│
└── Production
    ├── Product          — Product catalog
    └── Supplier         — Supplier master data
```

---

## 🏆 NACE Career Readiness Competencies

This course develops all eight NACE Career Readiness Competencies recognized by the National Association of Colleges and Employers:

| Competency | How It's Developed |
|---|---|
| 🧠 **Critical Thinking** | Formulating propositions, debugging queries, choosing optimal SQL approaches |
| 💬 **Communication** | Presenting walkthroughs, writing non-technical documentation, team coordination |
| 💻 **Technology** | Hands-on SQL Server, Docker, Azure Data Studio, Excel PowerQuery |
| 🤝 **Teamwork** | Group homework, peer code review, cross-training on new concepts |
| 🎯 **Professionalism** | Meeting deadlines, following submission standards, ethical use of AI tools |
| 🌱 **Career & Self-Development** | Building a public GitHub portfolio, writing propositions, self-directed learning |
| 🏅 **Leadership** | Homework leader role, consolidating group contributions, presenting solutions |
| 🌍 **Equity & Inclusion** | Collaborating across diverse backgrounds, valuing each member's contribution |

---

## 📌 Academic Integrity & LLM Disclosure

This group uses AI language model tools (including Claude, Copilot, Gemini, ChatGPT, Grok, DeepSeek, etc.) as **learning aids** — to validate query logic, refine documentation, and troubleshoot edge cases. All SQL code is independently constructed, tested, and understood by each member. AI tools are never used as a substitute for independent work.

All LLM usage is disclosed in individual assignment READMEs in accordance with the course syllabus.

---

## 📬 Contact

For questions about this repository, reach out via Queens College QMAIL.

**Course:** CSCI 331 — Database and Data Modeling
**Institution:** Queens College, City University of New York
**Semester:** Spring 2026
**Instructor:** Prof. Peter Heller

---

<div align="center">

*Built with 🛢️ T-SQL, ☕ late nights, and a lot of Docker restarts.*

*Queens College, CUNY · Computer Science Department · Spring 2026*

</div>
