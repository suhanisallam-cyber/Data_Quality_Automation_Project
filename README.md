# Data Quality Automation Project

##  Project Overview

This project is an automated data quality monitoring system built using **PostgreSQL and Python**.
The project identifies common data quality issues such as missing values, duplicate records, and orphan records.
Python automatically runs the quality checks, generates Pass/Fail results, counts failed records, and creates CSV reports and a data quality scorecard.

##  Project Objectives
- Identify missing and invalid data
- Detect duplicate records
- Detect orphan records using table relationships
- Automate data quality checks using Python
- Generate Pass/Fail results
- Calculate failed record counts
- Generate automated CSV reports
- Create a data quality scorecard with health scores

##  Technologies Used

- PostgreSQL
- Python
- Pandas
- Psycopg2
- SQL
- CSV
- vs code editor 

##  Database Tables

The project contains four main tables:
- `candidates`
- `employers`
- `postings`
- `applications`

These tables represent a simplified recruitment/job platform database.

## 🔍 Data Quality Checks

### 1. Missing Value Check

The project checks for missing values in important fields such as candidate city.

### 2. Duplicate Record Check

Duplicate employer records are identified using company names.

### 3. Orphan Record Check

Applications are checked against the `postings` table to identify applications that reference a posting that does not exist.

## 🐍 Python Automation

The Python script:

1. Connects to PostgreSQL
2. Reads database tables
3. Runs data quality checks
4. Generates Pass/Fail status
5. Counts failed records
6. Creates a data quality report
7. Generates a data quality scorecard
8. Calculates health scores

   ##  Key Insights
During the data quality analysis, the following issues were identified:

- **Missing Data:** 2 candidate records had missing city values.
- **Duplicate Data:** 2 employer records had the same company name.
- **Orphan Records:** 1 application record referenced a non-existent posting.
- **Data Validation:** SQL queries were used to identify and validate the data quality issues.
- **Data Correction:** The identified data quality issues were resolved by updating missing values,
- removing the unused duplicate employer record, and correcting the invalid posting reference.
- **Automation Result:** After fixing the identified issues, all implemented data quality checks passed successfully.
- **Final Data Quality Score:** All three monitored tables — `candidates`, `employers`, and `applications` — achieved a **100% health score** after correction.

