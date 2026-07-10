-- CREATING DATABASE

 CREATE DATABASE IF NOT EXISTS AI_IMPACT_DIRITY;
 USE AI_IMPACT_DIRITY;
-- ================================================================================================================

-- CREATING TABLES

 CREATE TABLE IF NOT EXISTS  DIM_COUNTRY (
   country_key INT PRIMARY KEY,
   country VARCHAR(100),
   region VARCHAR(100),
   development_status VARCHAR(50)
 );
-- =================================================================================================================


CREATE TABLE IF NOT EXISTS  DIM_EDUCATION (
    education_key INT PRIMARY KEY,
    education_level INT,
    education_label VARCHAR(50)
);
-- =================================================================================================================

CREATE TABLE IF NOT EXISTS  DIM_INDUSTRY (
    industry_key INT PRIMARY KEY,
    industry VARCHAR(100),
    sector VARCHAR(100),
    ai_adoption_stage VARCHAR(50)
);
-- ================================================================================================================


CREATE TABLE IF NOT EXISTS  DIM_JOB (
    job_key INT PRIMARY KEY,
    job_role VARCHAR(150),
    job_category VARCHAR(100),
    job_survival_class INT,
    job_survival_label VARCHAR(50)
);
-- ===================================================================================================

CREATE TABLE IF NOT EXISTS  DIM_RISK (
   risk_category VARCHAR(50),
	risk_key INT PRIMARY KEY,
    risk_score INT
);
-- ===========================================================================

CREATE TABLE IF NOT EXISTS  DIM_YEAR (
    year_key INT PRIMARY KEY,
    _year INT,
    is_forecast VARCHAR(10)
);
-- ==========================================================================================================

CREATE TABLE IF NOT EXISTS FACT_EMPLOYMENT (
    job_id INT PRIMARY KEY,
    country_key INT,
    industry_key INT,
    year_key INT,
    education_key INT,
    salary_usd DECIMAL(12,2),
    salary_after_usd DECIMAL(12,2),
    salary_change_pct DECIMAL(5,2),
    ai_adoption_pct DECIMAL(5,2),
    ai_adoption_stage VARCHAR(50),
    ai_disruption_score DECIMAL(5,2),
    automation_risk DECIMAL(5,2),
    ai_replacement_score DECIMAL(5,2),
    skill_gap DECIMAL(5,2),
    reskilling_score DECIMAL(5,2),
    remote_feasibility DECIMAL(5,2),
    wage_volatility DECIMAL(5,2),
    seniority_level VARCHAR(50),
    country_employment_rate DECIMAL(5,2),
    job_key INT,
    risk_key INT,
    ai_tools_used_count INT,
    time_saved_per_day_min INT,
    fear_of_ai_label VARCHAR(50)
);
-- =======================================================================================


-- بعمل تشيك على الاعمده 
SELECT 
    COUNT(*) AS total_rows,
-- هل فيه NULL
-- ولوفيه ايه عوعددهم لكلواحد
    SUM(CASE WHEN job_id IS NULL THEN 1 ELSE 0 END) AS null_job_id,
    SUM(CASE WHEN country_key IS NULL THEN 1 ELSE 0 END) AS null_country_key,
    SUM(CASE WHEN industry_key IS NULL THEN 1 ELSE 0 END) AS null_industry_key,
    SUM(CASE WHEN year_key IS NULL THEN 1 ELSE 0 END) AS null_year_key,
    SUM(CASE WHEN education_key IS NULL THEN 1 ELSE 0 END) AS null_education_key,
    SUM(CASE WHEN job_key IS NULL THEN 1 ELSE 0 END) AS null_job_key,
    SUM(CASE WHEN risk_key IS NULL THEN 1 ELSE 0 END) AS null_risk_key,
    SUM(CASE WHEN salary_usd IS NULL THEN 1 ELSE 0 END) AS null_salary,
    SUM(CASE WHEN salary_after_usd IS NULL THEN 1 ELSE 0 END) AS null_salary_after,
    SUM(CASE WHEN salary_change_pct IS NULL THEN 1 ELSE 0 END) AS null_salary_change,
    SUM(CASE WHEN skill_gap IS NULL THEN 1 ELSE 0 END) AS null_skill_gap,
    SUM(CASE WHEN remote_feasibility IS NULL THEN 1 ELSE 0 END) AS null_remote_feasibility,
    SUM(CASE WHEN seniority_level IS NULL THEN 1 ELSE 0 END) AS null_seniority,
    SUM(CASE WHEN fear_of_ai_label IS NULL THEN 1 ELSE 0 END) AS null_fear_label
FROM FACT_EMPLOYMENT;

-- =================================================================================================================================

-- هل فى تكرار فى  المفاتيح
SELECT 
    job_id, 
    COUNT(*) AS row_count
FROM FACT_EMPLOYMENT
GROUP BY job_id
HAVING COUNT(*) > 1;

 -- ===================================================================================================================================
    
    -- هل فى مسافات زايده قبل او بعد او نفس الكلمه مكتوبه بطرق مختلفه
    SELECT
    seniority_level, 
    LENGTH(seniority_level) AS actual_length, 
    COUNT(*) AS total_occurrences
FROM FACT_EMPLOYMENT
GROUP BY seniority_level
ORDER BY seniority_level;

-- =====================================================================================================================================
-- نفس اللى قبلها
SELECT 
    fear_of_ai_label, 
    LENGTH(fear_of_ai_label) AS actual_length,
    COUNT(*) AS total_occurrences
FROM FACT_EMPLOYMENT
GROUP BY fear_of_ai_label
ORDER BY fear_of_ai_label;

-- ==============================================================================================================================

SELECT 
    ai_adoption_stage, 
    LENGTH(ai_adoption_stage) AS actual_length, 
    COUNT(*) AS total_occurrences
FROM FACT_EMPLOYMENT
GROUP BY ai_adoption_stage;

--  ===================================================================================================================================
-- حل المشاكل


-- ال AI_ADOPTION_STAGE 
-- محتاج يتظبط نفس الكلمه مكتوبه بطرق مختلفه ومتكرره بمسافه بعد غير اللوجيك اللى بايظ ومش منطقى
-- شقلب واقلب
SET SQL_SAFE_UPDATES = 0;
UPDATE FACT_EMPLOYMENT
SET ai_adoption_stage = CASE 

    WHEN ai_adoption_pct < 33 THEN 'Emerging'
    WHEN ai_adoption_pct >= 33 AND ai_adoption_pct <= 66 THEN 'Growing'
    WHEN ai_adoption_pct > 66 THEN 'Mature'
    END;
    SET SQL_SAFE_UPDATES = 1;
-- ================================================================================================================================

-- المرتبات فيها فرغااات
SET SQL_SAFE_UPDATES = 0;
UPDATE FACT_EMPLOYMENT f
LEFT JOIN (
    SELECT job_key, ROUND(AVG(salary_usd), 2) AS JobAvgSalary
    FROM FACT_EMPLOYMENT
    WHERE salary_usd IS NOT NULL
    GROUP BY job_key
) m ON f.job_key = m.job_key
SET f.salary_usd = CASE 
    
    WHEN f.salary_after_usd IS NOT NULL AND f.salary_change_pct IS NOT NULL THEN 
        ROUND(f.salary_after_usd / (1 + (f.salary_change_pct / 100)), 2)
    
    ELSE m.JobAvgSalary
END
WHERE f.salary_usd IS NULL;
SET SQL_SAFE_UPDATES = 1;
-- =====================================================================================================

-- الوقت اللى اتوفر من استخدام الذكاء الاصطناعى فيه فرغات
SET SQL_SAFE_UPDATES = 0;
UPDATE fact_employment t1  
LEFT JOIN (
    SELECT job_key, ai_adoption_stage, ROUND(AVG(time_saved_per_day_min), 0) AS avg_time_saved
    FROM fact_employment 
    WHERE time_saved_per_day_min IS NOT NULL AND time_saved_per_day_min NOT IN (-999, 0) AND ai_tools_used_count > 0
    GROUP BY job_key, ai_adoption_stage
) t2 ON t1.job_key = t2.job_key AND t1.ai_adoption_stage = t2.ai_adoption_stage
LEFT JOIN (
    SELECT job_key, ROUND(AVG(time_saved_per_day_min), 0) AS avg_job_time_saved
    FROM fact_employment 
    WHERE time_saved_per_day_min IS NOT NULL AND time_saved_per_day_min NOT IN (-999, 0) AND ai_tools_used_count > 0
    GROUP BY job_key
) t3 ON t1.job_key = t3.job_key
SET t1.time_saved_per_day_min = CASE 
    WHEN t1.ai_tools_used_count = 0 THEN 0
    WHEN t1.ai_tools_used_count > 0 AND t2.avg_time_saved IS NOT NULL THEN t2.avg_time_saved
    WHEN t1.ai_tools_used_count > 0 AND t3.avg_job_time_saved IS NOT NULL THEN t3.avg_job_time_saved
    ELSE 90 
END
WHERE (t1.time_saved_per_day_min IS NULL OR t1.time_saved_per_day_min = -999)
  AND t1.job_id IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

-- ======================================================================================================================================

-- حل مشكلة التكرار فى المفتاح
SET SQL_SAFE_UPDATES = 0;
DELETE t1 FROM fact_employment t1
INNER JOIN fact_employment t2 
WHERE t1.job_id = t2.job_id 
  AND t1.ai_disruption_score = t2.ai_disruption_score 
  AND t1.job_id IN (
      SELECT job_id 
      FROM (
          SELECT job_id, ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY job_id) as row_num 
          FROM fact_employment
      ) as temp 
      WHERE row_num > 1
  );

SET SQL_SAFE_UPDATES = 1;

-- ==============================================================================================================================

-- نرجع نتاكد ان كله بقى تمام

SELECT 
    COUNT(*) AS Final_Total_Rows, 
    SUM(CASE WHEN salary_usd IS NULL THEN 1 ELSE 0 END) AS Remaining_Null_Salary,
    SUM(CASE WHEN time_saved_per_day_min IS NULL THEN 1 ELSE 0 END) AS Remaining_Null_Time_Saved,
    SUM(CASE WHEN time_saved_per_day_min = -999 THEN 1 ELSE 0 END) AS Remaining_Minus_999,
    SUM(CASE WHEN ai_adoption_stage IS NULL THEN 1 ELSE 0 END) AS Remaining_Null_Stage
FROM FACT_EMPLOYMENT ;

-- ==============================================================================================================================




-- =======================================================================================================================================================
  -- التربيط بين الجداول
ALTER TABLE dim_country   ADD PRIMARY KEY (country_key);
ALTER TABLE dim_education ADD PRIMARY KEY (education_key);
ALTER TABLE dim_industry  ADD PRIMARY KEY (industry_key);
ALTER TABLE dim_job       ADD PRIMARY KEY (job_key);
ALTER TABLE dim_risk      ADD PRIMARY KEY (risk_key);
ALTER TABLE dim_year      ADD PRIMARY KEY (year_key);

ALTER TABLE FACT_EMPLOYMENT 
    MODIFY COLUMN country_key INT,
    MODIFY COLUMN education_key INT,
    MODIFY COLUMN industry_key INT,
    MODIFY COLUMN job_key INT,
    MODIFY COLUMN risk_key INT,
    MODIFY COLUMN year_key INT;

SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE FACT_EMPLOYMENT
    ADD CONSTRAINT fk_fact_country   FOREIGN KEY (country_key)   REFERENCES dim_country(country_key),
    ADD CONSTRAINT fk_fact_education FOREIGN KEY (education_key) REFERENCES dim_education(education_key),
    ADD CONSTRAINT fk_fact_industry  FOREIGN KEY (industry_key)  REFERENCES dim_industry(industry_key),
    ADD CONSTRAINT fk_fact_job       FOREIGN KEY (job_key)       REFERENCES dim_job(job_key),
    ADD CONSTRAINT fk_fact_risk      FOREIGN KEY (risk_key)      REFERENCES dim_risk(risk_key),
    ADD CONSTRAINT fk_fact_year      FOREIGN KEY (year_key)      REFERENCES dim_year(year_key);

SET FOREIGN_KEY_CHECKS = 1;

-- ===============================================================================================================================