# 🧹 Layoffs SQL Data Cleaning

A data cleaning project using **SQL Server (T-SQL)** that transforms a raw global layoffs dataset into a clean, analysis-ready table.

---

## 📌 Project Overview

Raw data is rarely ready for analysis. In this project, I cleaned a real-world layoffs dataset by:

* Removing duplicate records
* Standardizing inconsistent values
* Handling missing and NULL values
* Removing rows with no useful layoff information

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

* Removed extra spaces from `company` (11 names)
* Changed `Crypto Currency` and `CryptoCurrency` to `Crypto` in `industry` (3 rows)
* Changed `United States.` to `United States` in `country` (4 rows)

This prevents the same industry or country from being treated as different values during analysis.

---

### 4. Handle Missing Values

* Converted blank (`''`) industry values to NULL
* Filled missing `industry` for **Juul** (Consumer) and **Carvana** (Transportation) using other records of the same company

---

### 5. Remove Unusable Rows

* Removed **361** records where both `total_laid_off` and `percentage_laid_off` were NULL, since they contain no useful layoff information
* Set missing `funds_raised_millions` values to `0` (165 rows)

> **Note:** A missing value does not necessarily mean a company raised zero funds. Keeping NULL would preserve the difference between "zero" and "unknown".

---

## ✅ Results

| Metric | Result |
| --- | ---: |
| Rows before cleaning | 2,361 |
| Duplicate rows removed | 5 |
| Industry labels standardized | 3 |
| Missing industries filled | 2 |
| Unusable rows removed | 361 |
| Rows after cleaning | 1,995 |

---

## 📋 Final Dataset

The cleaned data is stored in the table:

```text
Layoffs_Staging2
```

It is ready for SQL analysis and for visualization in tools such as Power BI or Tableau.

---

## ⚠️ Decisions & Limitations

* **Raw data preserved:** the original `Layoffs` table was never modified.
* **Rows without layoff information were removed:** they could not support layoff analysis.
* **Missing funds set to 0:** this is a simplifying assumption and may not reflect the real amount raised.
* **Manual industry fixes:** industry values were filled by hand for two companies. A self-join would scale better on larger data.
* **Industry still missing for two companies:** Airbnb and Bally's Interactive have no other record to copy the industry from, so they remain NULL.
* **Date column:** the `date` column has not yet been converted to the `DATE` data type.

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
* Converting data types
* Documenting cleaning decisions and their trade-offs

---

## 🚀 Next Steps

* Convert the `date` column to the `DATE` data type
* Add data-quality validation checks
* Perform exploratory analysis (layoffs by year, industry, company and country)
* Build a Power BI or Tableau dashboard
