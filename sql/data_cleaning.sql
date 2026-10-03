-- =====================================================
-- DATA CLEANING PROJECT: LAYOFFS (SQL SERVER)
-- =====================================================
-- 1. CREATE STAGING TABLE
-- 2. REMOVE DUPLICATES
-- 3. STANDARDIZE THE DATA
-- 4. NULL VALUES OR BLANK VALUES
-- 5. REMOVE ANY ROWS / COLUMNS
-- =====================================================


-- =====================================================
-- 1. CREATE STAGING TABLE (keep raw data safe)
-- =====================================================

SELECT * INTO Layoffs_Staging
FROM Layoffs
WHERE 1 = 0

INSERT Layoffs_Staging
SELECT *
FROM Layoffs

SELECT * FROM Layoffs_Staging

-- Convert text 'NULL' into real NULL, then fix the data type
UPDATE Layoffs_Staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL'

ALTER TABLE Layoffs_Staging
ALTER COLUMN funds_raised_millions DECIMAL(18,2)


-- =====================================================
-- 2. REMOVE DUPLICATES
-- =====================================================

-- Step 1: Check duplicates
WITH DUPLICATE AS (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY COMPANY, LOCATION, INDUSTRY, TOTAL_LAID_OFF,
						 PERCENTAGE_LAID_OFF, [DATE], STAGE, COUNTRY,
						 FUNDS_RAISED_MILLIONS
			ORDER BY (SELECT NULL)
		) AS DUPLICATE_ROWS
	FROM Layoffs_Staging
)
SELECT *
FROM DUPLICATE
WHERE DUPLICATE_ROWS > 1

-- Step 2: Create second staging table with ROW_NUM column
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY COMPANY, LOCATION, INDUSTRY, TOTAL_LAID_OFF,
					 PERCENTAGE_LAID_OFF, [DATE], STAGE, COUNTRY,
					 FUNDS_RAISED_MILLIONS
		ORDER BY (SELECT NULL)
	) AS ROW_NUM
INTO Layoffs_Staging2
FROM Layoffs_Staging

-- Step 3: Delete duplicates
SELECT * FROM Layoffs_Staging2
WHERE ROW_NUM > 1

DELETE FROM Layoffs_Staging2
WHERE ROW_NUM > 1

-- Step 4: Drop helper column
ALTER TABLE Layoffs_Staging2
DROP COLUMN ROW_NUM


-- =====================================================
-- 3. STANDARDIZE THE DATA
-- =====================================================

-- Remove extra spaces from company names
UPDATE Layoffs_Staging2
SET COMPANY = TRIM(COMPANY)

-- Industry: check values, then fix 'CRYPTO' -> 'Crypto'
SELECT DISTINCT INDUSTRY
FROM Layoffs_Staging2
ORDER BY 1

UPDATE Layoffs_Staging2
SET INDUSTRY = 'Crypto'
WHERE INDUSTRY = 'CRYPTO'

-- Country: check values, then fix 'United States.' -> 'United States'
SELECT DISTINCT COUNTRY
FROM Layoffs_Staging2
ORDER BY 1

UPDATE Layoffs_Staging2
SET COUNTRY = 'United States'
WHERE COUNTRY = 'United States.'


-- =====================================================
-- 4. NULL VALUES OR BLANK VALUES
-- =====================================================

-- Check rows with missing industry
SELECT *
FROM Layoffs_Staging2
WHERE INDUSTRY IS NULL

-- Juul and Carvana have other rows with the industry filled in
SELECT * FROM Layoffs_Staging2 WHERE COMPANY = 'Juul'
SELECT * FROM Layoffs_Staging2 WHERE COMPANY = 'Carvana'

UPDATE Layoffs_Staging2
SET INDUSTRY = 'Consumer'
WHERE COMPANY = 'Juul' AND INDUSTRY IS NULL

UPDATE Layoffs_Staging2
SET INDUSTRY = 'Transportation'
WHERE COMPANY = 'Carvana' AND INDUSTRY IS NULL

-- =====================================================
-- 5. REMOVE UNUSABLE ROWS
-- =====================================================

-- Rows where BOTH layoff columns are NULL have no useful information
SELECT *
FROM Layoffs_Staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL

DELETE FROM Layoffs_Staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL

-- Funds raised: set missing values to 0
UPDATE Layoffs_Staging2
SET funds_raised_millions = 0
WHERE funds_raised_millions IS NULL


-- =====================================================
-- FINAL CLEAN DATA
-- =====================================================
SELECT * FROM Layoffs_Staging2
