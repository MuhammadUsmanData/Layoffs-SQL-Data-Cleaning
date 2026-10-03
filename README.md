# 🧹 Layoffs SQL Data Cleaning

A data cleaning project using **SQL Server (T-SQL)** that transforms a raw global layoffs dataset into a cleaner, analysis-ready table.

---

## 📌 Project Overview

Raw data is rarely ready for analysis. In this project, I cleaned a real-world layoffs dataset by:

* Removing duplicate records
* Standardizing inconsistent values
* Reviewing missing and NULL values
* Removing rows with missing layoff data

All cleaning was performed on **staging tables**, keeping the original `Layoffs` table untouched.

---

## 📂 Repository Structure

```text
Layoffs-SQL-Data-Cleaning/
│
├── README.md
├── data_cleaning.sql
└── layoffs.csv
```

| File | Description |
| --- | --- |
| `data_cleaning.sql` | Complete T-SQL script containing the data cleaning process |
| `layoffs.csv` | Raw layoffs dataset |
| `README.md` | Project documentation |

---

## 📊 Dataset

* **Source:** layoffs.fyi dataset, available on Kaggle
* **Raw rows:** 2,361
* **Columns:** 9

| Column | Description |
| --- | --- |
| `company` | Company that conducted layoffs |
| `location` | City or region of the company |
| `industry` | Industry of the company |
| `total_laid_off` | Number of employees laid off |
| `percentage_laid_off` | Percentage of workforce laid off |
| `date` | Date of the layoff announcement |
| `stage` | Funding stage of the company |
| `country` | Country of the company |
| `funds_raised_millions` | Funds raised by the company in USD millions |

---

## 🛠️ Tools & Skills

* SQL Server and T-SQL
* SQL Server Management Studio (SSMS)
* Staging tables using `SELECT INTO`
* CTEs
* Window functions (`ROW_NUMBER() OVER (PARTITION BY ...)`)
* `UPDATE`, `DELETE` and `ALTER TABLE`
* String cleaning with `TRIM()`
* NULL handling and data type conversion
* Data quality checks

---

## 🔄 Cleaning Workflow

### 1. Staging

Created a staging copy of the raw `Layoffs` table (`Layoffs_Staging`) so the original data remains unchanged.

This step also:

* Converted the text value `'NULL'` in `funds_raised_millions` into a real SQL `NULL`
* Changed `funds_raised_millions` to `DECIMAL(18,2)`

---

### 2. Remove Duplicates

* Used `ROW_NUMBER()` with `PARTITION BY` across all columns on `Layoffs_Staging` to identify duplicate records
* Created a second staging table, `Layoffs_Staging2`, with a `ROW_NUM` column
* Deleted the **5** rows where `ROW_NUM > 1`
* Dropped the helper column

---

### 3. Standardize Values

* Removed extra spaces from `company`
* Changed `United States.` to `United States` in `country`

This prevents the same company or country from being treated as different values during analysis.

---

### 4. Review Missing Values

Checked rows with missing `industry` values and compared **Juul** and **Carvana** against their other records to find the correct industry.

---

### 5. Remove Rows With Missing Layoff Data

* Removed rows with missing layoff information (**1,162** rows after duplicates were removed)
* Set missing `funds_raised_millions` values to `0`

> **Note:** A missing value does not necessarily mean a company raised zero funds. Keeping NULL would preserve the difference between "zero" and "unknown".

---

## ✅ Results

| Metric | Result |
| --- | ---: |
| Rows before cleaning | 2,361 |
| Duplicate rows removed | 5 |
| Rows removed for missing layoff data | 1,162 |
| Rows after cleaning | 1,194 |

---

## 📋 Final Dataset

The cleaned data is stored in the table:

```text
Layoffs_Staging2
```

---
## ⚠️ Decisions & Limitations

* **Raw data preserved:** The original `Layoffs` table was never modified. All cleaning operations were performed on staging tables.

* **Rows with missing layoff data were removed:** Rows where both `total_laid_off` and `percentage_laid_off` were NULL were removed because they could not support meaningful layoff analysis.

* **Missing funds set to 0:** Missing values in `funds_raised_millions` were set to `0`. This is a simplifying assumption and may not represent the actual amount raised. Keeping these values as NULL would be more appropriate when distinguishing between "zero" and "unknown" is important.

* **`percentage_laid_off` data type:** The column was imported as an integer, causing decimal values such as `0.15` to be stored as `0`. This is a data-import issue that should be corrected by importing the column with an appropriate decimal data type, such as `FLOAT` or `DECIMAL`.

* **Industry standardization:** Inconsistent industry labels such as `CRYPTO` and `Cryptocurrency` were standardized to `Crypto`.

* **Date column:** The `date` column has not yet been converted to the `DATE` data type and is planned as a future improvement.

---

## ▶️ How to Run

1. **Import the dataset:** import `layoffs.csv` into SQL Server as a table named `Layoffs` (SSMS: right-click the database → Tasks → Import Flat File).
2. **Open the script:** open `data_cleaning.sql` in SSMS.
3. **Run it:** execute the script section by section to follow each cleaning stage.
4. **Check the result:** the cleaned data is in `Layoffs_Staging2`.

---

## 💡 What I Learned

* Using staging tables to protect raw data
* Finding and removing duplicates with window functions
* Standardizing inconsistent text values
* Handling NULL and blank values
* Checking data types during import, since a wrong type can silently change values
* Documenting cleaning decisions and their trade-offs

---

## 🚀 Next Steps

* Re-import the data with `percentage_laid_off` as `FLOAT`
* Merge inconsistent industry labels (for example, all `Crypto%` values into `Crypto`)
* Convert the `date` column to the `DATE` data type
* Add data-quality validation checks
* Perform exploratory analysis (layoffs by year, industry, company and country)
* Build a Power BI or Tableau dashboard
