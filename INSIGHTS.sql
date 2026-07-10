CREATE DATABASE IF NOT EXISTS FINAL_IMPACT;
USE FINAL_IMPACT;
-- انشاء  جدول السنه
CREATE TABLE IF NOT EXISTS  Dim_Year (
    year_key INT PRIMARY KEY,
    _year INT,
    is_forecast VARCHAR(10)
);

--  انشا ءجدول بُعد الم  خاطر 
CREATE TABLE IF NOT EXISTS  Dim_Risk (
    risk_category VARCHAR(50),
    risk_key INT PRIMARY KEY,
    risk_score INT
);

-- انشاء جدول الوظائف
CREATE TABLE IF NOT EXISTS  Dim_Job (
    job_key INT PRIMARY KEY,
    job_role VARCHAR(100),
    job_category VARCHAR(100),
    job_survival_class INT,
    job_survival_label VARCHAR(50)
);

-- انشاء جدول ال مجالات
CREATE TABLE IF NOT EXISTS Dim_Industry (
    industry_key INT PRIMARY KEY,
    industry VARCHAR(100),
    sector VARCHAR(100),
    ai_adoption_stage VARCHAR(50)
);

-- انشاء جدول التعليم
CREATE TABLE IF NOT EXISTS  Dim_Education (
    education_key INT PRIMARY KEY,
    education_level INT,
    education_label VARCHAR(100)
);

-- انشاء جدول الدول
CREATE TABLE IF NOT EXISTS  Dim_Country (
    country_key INT PRIMARY KEY,
    country VARCHAR(100),
    region VARCHAR(100),
    development_status VARCHAR(100)
);
-- انشاء جدول التوظيف
CREATE TABLE IF NOT EXISTS Fact_Employment (
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
    fear_of_ai_label VARCHAR(50),
-- ============================================================
    -- عمل الربط بين الجداول
    FOREIGN KEY (year_key) REFERENCES Dim_Year(year_key),
    FOREIGN KEY (risk_key) REFERENCES Dim_Risk(risk_key),
    FOREIGN KEY (job_key) REFERENCES Dim_Job(job_key),
    FOREIGN KEY (industry_key) REFERENCES Dim_Industry(industry_key),
    FOREIGN KEY (education_key) REFERENCES Dim_Education(education_key),
    FOREIGN KEY (country_key) REFERENCES Dim_Country(country_key)
);

-- عايزين نلغى ال dim_year
-- SET SQL_SAFE_UPDATES = 0;
-- SET FOREIGN_KEY_CHECKS = 0; 
-- ALTER TABLE Fact_Employment 
--     ADD COLUMN _year INT,
--     ADD COLUMN is_forecast VARCHAR(10);
-- UPDATE Fact_Employment f
-- INNER JOIN Dim_Year d ON f.year_key = d.year_key
-- SET f._year = d._year,
--     f.is_forecast = d.is_forecast
-- WHERE f.job_id IS NOT NULL; 
-- ALTER TABLE Fact_Employment DROP FOREIGN KEY fact_employment_ibfk_1;
-- ALTER TABLE Fact_Employment DROP COLUMN year_key;
-- DROP TABLE IF EXISTS Dim_Year;
-- SET FOREIGN_KEY_CHECKS = 1;
-- SET SQL_SAFE_UPDATES = 1;

-- بنتاكد ان كل حاجه تمام بعد ما نقلنا
-- SELECT job_id, _year, is_forecast 
-- FROM Fact_Employment 
-- LIMIT 10;

-- SELECT 
--     COUNT(*) AS Total_Rows,
--     
--     -- فحص أعمدة المفاتيح (Keys) والـ IDs
--     SUM(CASE WHEN job_id IS NULL THEN 1 ELSE 0 END) AS Null_job_id,
--     SUM(CASE WHEN country_key IS NULL THEN 1 ELSE 0 END) AS Null_country_key,
--     SUM(CASE WHEN industry_key IS NULL THEN 1 ELSE 0 END) AS Null_industry_key,
--     SUM(CASE WHEN education_key IS NULL THEN 1 ELSE 0 END) AS Null_education_key,
--     SUM(CASE WHEN job_key IS NULL THEN 1 ELSE 0 END) AS Null_job_key,
--     SUM(CASE WHEN risk_key IS NULL THEN 1 ELSE 0 END) AS Null_risk_key,
--     
--     -- فحص الأعمدة الجديدة اللي نقلناها
--     SUM(CASE WHEN _year IS NULL THEN 1 ELSE 0 END) AS Null_year,
--     SUM(CASE WHEN is_forecast IS NULL THEN 1 ELSE 0 END) AS Null_is_forecast,
--     
--     -- فحص أعمدة الرواتب والمؤشرات الحسابية
--     SUM(CASE WHEN salary_usd IS NULL THEN 1 ELSE 0 END) AS Null_salary_usd,
--     SUM(CASE WHEN salary_after_usd IS NULL THEN 1 ELSE 0 END) AS Null_salary_after_usd,
--     SUM(CASE WHEN salary_change_pct IS NULL THEN 1 ELSE 0 END) AS Null_salary_change_pct,
--     SUM(CASE WHEN ai_adoption_pct IS NULL THEN 1 ELSE 0 END) AS Null_ai_adoption_pct,
--     SUM(CASE WHEN ai_adoption_stage IS NULL THEN 1 ELSE 0 END) AS Null_ai_adoption_stage,
--     SUM(CASE WHEN ai_disruption_score IS NULL THEN 1 ELSE 0 END) AS Null_ai_disruption_score,
--     SUM(CASE WHEN automation_risk IS NULL THEN 1 ELSE 0 END) AS Null_automation_risk,
--     SUM(CASE WHEN ai_replacement_score IS NULL THEN 1 ELSE 0 END) AS Null_ai_replacement_score,
--     
--     -- فحص باقي أعمدة السلوك والاستبيان
--     SUM(CASE WHEN skill_gap IS NULL THEN 1 ELSE 0 END) AS Null_skill_gap,
--     SUM(CASE WHEN reskilling_score IS NULL THEN 1 ELSE 0 END) AS Null_reskilling_score,
--     SUM(CASE WHEN remote_feasibility IS NULL THEN 1 ELSE 0 END) AS Null_remote_feasibility,
--     SUM(CASE WHEN wage_volatility IS NULL THEN 1 ELSE 0 END) AS Null_wage_volatility,
--     SUM(CASE WHEN seniority_level IS NULL THEN 1 ELSE 0 END) AS Null_seniority_level,
--     SUM(CASE WHEN country_employment_rate IS NULL THEN 1 ELSE 0 END) AS Null_country_employment_rate,
--     SUM(CASE WHEN ai_tools_used_count IS NULL THEN 1 ELSE 0 END) AS Null_ai_tools_used_count,
--     SUM(CASE WHEN time_saved_per_day_min IS NULL THEN 1 ELSE 0 END) AS Null_time_saved_per_day,
--     SUM(CASE WHEN fear_of_ai_label IS NULL THEN 1 ELSE 0 END) AS Null_fear_of_ai
--     
-- FROM Fact_Employment;


-- ===============================================================================================================================
-- ================================================================================================================================
-- ================================================================================================================================
-- ================================================================================================================================
-- ===============================================================================================================================
-- ================================================================================================================================
-- ================================================================================================================================
-- ================================================================================================================================


-- ========================================================
-- FOR Executive Insights ::::::>>>>>>
-- ========================================================

-- AVG AI ADOPTION
SELECT ROUND(AVG(ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM fact_employment;

-- ========================================================

-- AVG AUTOMATION RISK
-- مين اقدر استغنى عنه ومين لاء
SELECT ROUND(AVG(automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment;

-- =========================================================

-- نسبة التغير فى المرتبات كانت قد ايه بالنسبه لكل حاجه 
-- AVG SALARY CHANGE
SELECT ROUND(AVG(salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment;

-- ===========================================================

-- اكتر المجالات استخداما
-- لما اجى اعين هعين مين 
SELECT 
    i.industry,
    ROUND(AVG(f.ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry
ORDER BY Avg_AI_Adoption_Pct DESC;

-- =================================================================

-- اكتر المجالات فى خطر الاستبدال
-- الناس اللى بستغنى عنهم دول فى انهى مجال
SELECT 
    i.industry,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry
ORDER BY Avg_Automation_Risk DESC;

-- ================================================================

-- المرتبات بتتغير بنسبة قد ايه
-- قبل وبعد ساعدنى اقلل التكلفه ولا لاء 
SELECT 
    f._year, -- تعديل: السحب مباشر من الـ Fact
    ROUND(AVG(f.salary_usd), 2) AS Avg_Salary_Before,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment f
GROUP BY f._year
ORDER BY f._year ASC;

-- ================================================================

-- نسب التوظيف بتزيد ولا بتقل 
SELECT 
    f._year, 
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
GROUP BY f._year
ORDER BY f._year ASC;

-- ==========================================================================
-- 
-- اكتر حاجه مهمه>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 
-- 
-- اعدد الوظايف اللى معرضه لكل درجه من الخطر
SELECT 
    r.risk_category,
    COUNT(f.job_id) AS Total_Jobs_Count,
    ROUND(COUNT(f.job_id) * 100.0 / (SELECT COUNT(*) FROM Fact_Employment), 2) AS Percentage_Of_Total
FROM Fact_Employment f
JOIN Dim_Risk r ON f.risk_key = r.risk_key
GROUP BY r.risk_category
ORDER BY Total_Jobs_Count DESC;

-- ======================================================================================================

-- اكتر دوله بتخدم ذكاء اصطناعى
SELECT 
    c.country,
    ROUND(AVG(f.ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment f
JOIN Dim_Country c ON f.country_key = c.country_key
GROUP BY c.country
ORDER BY Avg_AI_Adoption_Pct DESC;

-- =========================================================================================

-- اكتر دوله بتوظف اكتر 
SELECT 
    c.country,
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
JOIN Dim_Country c ON f.country_key = c.country_key
GROUP BY c.country
ORDER BY Avg_Employment_Rate DESC;

-- ==============================================================================================================================
-- ========================================================
-- FOR EMPLOYMENTS AND HR Insights ::::::>>>>>>
-- ========================================================
-- ========================================== FOR EMPLOYMENT and HR =================================================
--  مستوى الخطر لكل وظيفه
-- اهم واحده هنا >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    j.job_role,
    j.job_survival_label AS Job_Security_Status,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role, j.job_survival_label;

--  =================================================================================================

-- اعلى 5 وظايف فى الاستبدال 
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Max_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Max_Automation_Risk DESC
LIMIT 5;

-- ======================================================================================================

-- اقل 5 وظائف يمكن استبدالهم 

SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Min_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Min_Automation_Risk ASC
LIMIT 5;

-- ========================================================================================================

-- نسبة تغير المرتبات 
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Percent
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- =================================================================================================================

-- الوقت اللى الذكاء وفره بالدقايق
SELECT 
    j.job_role,
    ROUND(AVG(f.time_saved_per_day_min), 0) AS Avg_Minutes_Saved_Per_Day
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ==============================================================================================

-- متوسط عدد الادوات المستخدمه

SELECT 
    j.job_role,
    ROUND(AVG(f.ai_tools_used_count), 0) AS Avg_AI_Tools_Used
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ==================================================================================

-- هل ممكن نشتغل عن بعد
-- مش منطقيه الداتا هنا غلط 
-- ال HR
-- مينفعش يتعامل بيها او يعتمد عليها فى قرار
SELECT 
    j.job_role,
    ROUND(AVG(f.remote_feasibility), 2) AS Remote_Feasibility_Pct
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;
-- ==================================================================================
-- الخبره والخطر
-- مشكله فى الداتا
SELECT 
    f.seniority_level,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
GROUP BY f.seniority_level
ORDER BY Avg_AI_Replacement_Score DESC;
-- ====================================================================================
-- محتاجين نتاهل قد ايه لكل مجال
SELECT 
    j.job_role,
    ROUND(AVG(f.reskilling_score), 2) AS Reskilling_Urgency_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ========================================================================================================
-- ====================== FOR Student Career  ======================================

-- الوظايف من ناحية اعلى المرتبات واقل خطر فى الاستبدال  فى وجود الذكاء الاصطناعى

-- مهم>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_after_usd), 2) AS Expected_Salary_After_AI,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Expected_Salary_After_AI DESC, Avg_Automation_Risk ASC;

-- =======================================================================================

-- اعلى وظايف فى المرتبات بعد دخول الذكاء الاصطناعى
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_after_usd), 2) AS Max_Expected_Salary
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Max_Expected_Salary DESC
LIMIT 5;

-- =======================================================================================

-- اقل وظايف معرضه للاستبدال
--  مهم لازم تذاكر AI>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Min_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Min_Automation_Risk ASC
LIMIT 5;

-- ====================================================================================

-- اكتر دول مرتباتها عاليه والتوظيف فيها عالى
SELECT 
    c.country,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After_AI,
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
JOIN Dim_Country c ON f.country_key = c.country_key
GROUP BY c.country
ORDER BY Avg_Salary_After_AI DESC
LIMIT 5;

-- =====================================================
-- المجالات الاعلى مرتبات واقل خطر فى الاستبدال
SELECT 
    i.industry,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Industry_Salary,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Industry_Risk
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry
ORDER BY Avg_Industry_Salary DESC;

-- ==========================================================

-- هل درجة التعليم بتفرق اصلا فىالمرتبات بعد استخدام الذكاء الاصطناعى
SELECT 
    e.education_label AS Education_Level,
    ROUND(AVG(f.salary_usd), 2) AS Avg_Salary_Before,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After
FROM Fact_Employment f
JOIN Dim_Education e ON f.education_key = e.education_key
GROUP BY e.education_label, e.education_level
ORDER BY e.education_level ASC;

-- ========================================================================

-- طب هل مستوى التعليم فارق مع الاستبدال ولا كله رايح والف الف مبروك
SELECT 
    e.education_label AS Education_Level,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
JOIN Dim_Education e ON f.education_key = e.education_key
GROUP BY e.education_label, e.education_level
ORDER BY e.education_level ASC;

-- ==================================================================================================================================
-- ==================================================================================================================================

--  ========================================== FOR HR Managers ====================================



-- ===============================================================

-- الاجور بتتغير بشكل ثابت ولا لاء

SELECT 
    j.job_role,
    ROUND(AVG(f.wage_volatility), 2) AS Avg_Wage_Volatility
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Avg_Wage_Volatility DESC;

-- ===========================================================================

-- اكتر وظايف محتاجه تدريب
-- محتاجين يدخلوا الاتمته هتوفر وقت معاهم
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    j.job_role,
    ROUND(AVG(f.reskilling_score), 2) AS Max_Reskilling_Urgency
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Max_Reskilling_Urgency DESC
LIMIT 5;

-- ==========================================================

-- اكترفئه اتاثرت بالذكاء الاصطناعى
-- كلهم قرييبين من بعض الذكاء كاسح وماسح
SELECT 
    j.job_category,
    ROUND(AVG(f.ai_disruption_score), 2) AS Avg_Category_Disruption
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_category
ORDER BY Avg_Category_Disruption DESC;

-- ==========================================================================================================================
-- ===========================================================================================================================
-- ===================================================================================================================
-- ================================================  FOR Behavioral & Fear الجانب النفسى==============================================

-- عدد الناس اللى خايفه بالنسبه لتقسيمة الخوف
SELECT 
    f.fear_of_ai_label AS Fear_Level,
    COUNT(f.job_id) AS Total_Employees,
    ROUND(COUNT(f.job_id) * 100.0 / (SELECT COUNT(*) FROM Fact_Employment), 2) AS Percentage_Of_Total
FROM Fact_Employment f
GROUP BY f.fear_of_ai_label
ORDER BY Total_Employees DESC;

-- ==========================================================================================================

-- الخوف فى كل مجال موجود موجود فى كام فرد
SELECT 
    i.industry,
    f.fear_of_ai_label AS Fear_Level,
    COUNT(f.job_id) AS Employee_Count
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry, f.fear_of_ai_label
ORDER BY i.industry, Employee_Count DESC;

-- ==============================================================================
-- مستوى التعليم اثر على درجة الخوف 
SELECT 
    e.education_label AS Education_Level,
    f.fear_of_ai_label AS Fear_Level,
    COUNT(f.job_id) AS Employee_Count
FROM Fact_Employment f
JOIN Dim_Education e ON f.education_key = e.education_key
GROUP BY e.education_label, e.education_level, f.fear_of_ai_label
ORDER BY e.education_level ASC, Employee_Count DESC;

-- ================================================================
-- هل درجة الخوف  مناسبه مع الخطر الفهلى
SELECT 
    f.fear_of_ai_label AS Fear_Level,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Actual_Automation_Risk,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM
    Fact_Employment f
GROUP BY f.fear_of_ai_label;

-- ===================================================================
-- هل كتر الادوات اللى بتساعدقلل الخوف
SELECT 
    f.fear_of_ai_label AS Fear_Level,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Actual_Automation_Risk,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
GROUP BY f.fear_of_ai_label;

-- ==================================================================
-- الخوف يستاهل ولا لاء
SELECT 
    f.fear_of_ai_label AS Fear_Level,
    ROUND(AVG(f.skill_gap), 2) AS Avg_Skill_Gap,
    ROUND(AVG(f.reskilling_score), 2) AS Avg_Reskilling_Urgency
FROM Fact_Employment f
GROUP BY f.fear_of_ai_label;


-- ===========================================================================================================================


--  IS_FORCAST
SELECT 
    f.is_forecast AS Data_Type, -- لمعرفة هل دي داتا حقيقية أم توقعات
    COUNT(f.job_id) AS Total_Records,
    ROUND(AVG(f.salary_usd), 2) AS Avg_Base_Salary,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Expected_Salary_After_AI,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk,
    ROUND(AVG(f.time_saved_per_day_min), 1) AS Avg_Minutes_Saved_Daily
FROM Fact_Employment f
GROUP BY f.is_forecast;



































































































-- ========================================================================
-- VIEWS
-- ========================================================================

-- FIRST KPI AVG AI ADOPTION
CREATE OR REPLACE VIEW v_Executive_KPI_AI_Adoption AS
SELECT ROUND(AVG(ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment;

-- ============================================================================
-- SECOND KPI AVG AUTOMATION RISK
CREATE OR REPLACE VIEW v_Executive_KPI_Automation_Risk AS
SELECT ROUND(AVG(automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment;

-- ==============================================================================
-- THIRD KPI AVG SALARY CHANGE
CREATE OR REPLACE VIEW v_Executive_KPI_Salary_Change AS
SELECT ROUND(AVG(salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment;

-- =================================================================================
-- اكتر المجالات المستخدمه ذكاء اصطناعى
CREATE OR REPLACE VIEW v_Executive_Industry_AI_Adoption AS
SELECT 
    i.industry,
    ROUND(AVG(f.ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry;

-- ==================================================================================
-- الاكثر تعرض للاستبدال
CREATE OR REPLACE VIEW v_Executive_Industry_Automation_Risk AS
SELECT 
    i.industry,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry;

-- =====================================================================================
-- الرواتب بتتغير بنسبة قد ايه 
CREATE OR REPLACE VIEW v_Executive_Salary_Trends AS
SELECT 
    f._year, -- تعديل هنا
    ROUND(AVG(f.salary_usd), 2) AS Avg_Salary_Before,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment f
GROUP BY f._year;

-- التوظيف بيزيد ولا يقل
CREATE OR REPLACE VIEW v_Executive_Employment_Rate_Trends AS
SELECT 
    f._year, -- تعديل هنا
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
GROUP BY f._year;

-- ====================================================================================
-- اعدد الوظايف اللى معرضه لكل درجه من الخطر
CREATE OR REPLACE VIEW v_Executive_Job_Risk_Distribution AS
SELECT 
    r.risk_category,
    COUNT(f.job_id) AS Total_Jobs_Count,
    ROUND(COUNT(f.job_id) * 100.0 / (SELECT COUNT(*) FROM Fact_Employment), 2) AS Percentage_Of_Total
FROM Fact_Employment f
JOIN Dim_Risk r ON f.risk_key = r.risk_key
GROUP BY r.risk_category;

-- =========================================================================================================
-- اعلى دول فى الاستخدام
CREATE OR REPLACE VIEW v_Executive_Country_AI_Adoption AS
SELECT 
    c.country,
    ROUND(AVG(f.ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment f
JOIN Dim_Country c ON f.country_key = c.country_key
GROUP BY c.country;

-- ================================================================================================
-- اكتر دول بتوظف
CREATE OR REPLACE VIEW v_Executive_Country_Employment_Rates AS
SELECT 
    c.country,
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
JOIN Dim_Country c ON f.country_key = c.country_key
GROUP BY c.country;

-- ================================================================================================
-- مستوى الخطر لكل وظيفه
SELECT 
    j.job_role,
    j.job_survival_label AS Job_Security_Status,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role, j.job_survival_label;

-- =================================================================================================

-- اعلى 5 وظايف فى الاستبدال 
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Max_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Max_Automation_Risk DESC
LIMIT 5;

-- ======================================================================================================

-- اقل 5 وظائف يمكن استبدالهم 
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Min_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Min_Automation_Risk ASC
LIMIT 5;

-- ========================================================================================================

-- نسبة تغير المرتبات لكل وظيفه
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Percent
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

--  ============================================================================================================================
-- ====================================================================================================
-- ==================================== VIEWS =========================================================

-- مستوى الخطر لكل وظيفه
CREATE OR REPLACE VIEW v_Employee_Job_Risk_Status AS
SELECT 
    j.job_role,
    j.job_survival_label AS Job_Security_Status,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role, j.job_survival_label;

-- =================================================================================================

-- اعلى 5 وظايف فى الاستبدال 
CREATE OR REPLACE VIEW v_Employee_Top5_High_Risk_Jobs AS
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Max_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Max_Automation_Risk DESC
LIMIT 5;

-- ======================================================================================================

-- اقل 5 وظائف يمكن استبدالهم 
CREATE OR REPLACE VIEW v_Employee_Top5_Low_Risk_Jobs AS
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Min_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Min_Automation_Risk ASC
LIMIT 5;

-- ========================================================================================================

-- نسبة تغير المرتبات 
CREATE OR REPLACE VIEW v_Employee_Salary_Change_Pct AS
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Percent
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- =================================================================================================================

-- الوقت اللى الذكاء وفره بالدقايق
CREATE OR REPLACE VIEW v_Employee_Time_Saved_Minutes AS
SELECT 
    j.job_role,
    ROUND(AVG(f.time_saved_per_day_min), 0) AS Avg_Minutes_Saved_Per_Day
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ==============================================================================================

-- متوسط عدد الادوات المستخدمه
CREATE OR REPLACE VIEW v_Employee_Avg_AI_Tools_Used AS
SELECT 
    j.job_role,
    ROUND(AVG(f.ai_tools_used_count), 1) AS Avg_AI_Tools_Used
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ==================================================================================

-- هل ممكن نشتغل عن بعد
CREATE OR REPLACE VIEW v_Employee_Remote_Feasibility AS
SELECT 
    j.job_role,
    ROUND(AVG(f.remote_feasibility), 2) AS Remote_Feasibility_Pct
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- =====================================================================
-- الخبره والخطر
CREATE OR REPLACE VIEW v_Employee_Experience_And_Risk AS
SELECT 
    f.seniority_level,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
GROUP BY f.seniority_level
ORDER BY Avg_AI_Replacement_Score DESC;

-- ====================================================================================
-- محتاجين نتاهل قد ايه لكل مجال
CREATE OR REPLACE VIEW v_Employee_Reskilling_Urgency AS
SELECT 
    j.job_role,
    ROUND(AVG(f.reskilling_score), 2) AS Reskilling_Urgency_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ===================================================================================================================================
-- الوظايف من ناحية اعلى المرتبات واقل خطر فى الاستبدال  فى وجود الذكاء الاصطناعى
CREATE OR REPLACE VIEW v_Student_Career_Value_Matrix AS
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_after_usd), 2) AS Expected_Salary_After_AI,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Expected_Salary_After_AI DESC, Avg_Automation_Risk ASC;

-- =======================================================================================

-- اعلى وظايف فى المرتبات بعد دخول الذكاء الاصطناعى
CREATE OR REPLACE VIEW v_Student_Top_Salaries_After_AI AS
SELECT 
    j.job_role,
    ROUND(AVG(f.salary_after_usd), 2) AS Max_Expected_Salary
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Max_Expected_Salary DESC
LIMIT 5;

-- =======================================================================================

-- اقل وظايف معرضه للاستبدال
CREATE OR REPLACE VIEW v_Student_Safest_Jobs_From_AI AS
SELECT 
    j.job_role,
    ROUND(AVG(f.automation_risk), 2) AS Min_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Min_Automation_Risk ASC
LIMIT 5;

-- ====================================================================================

-- اكتر دول مرتباتها عاليه والتوظيف فيها عالى
CREATE OR REPLACE VIEW v_Student_Best_Countries_Salary_Employment AS
SELECT 
    c.country,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After_AI,
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
JOIN Dim_Country c ON f.country_key = c.country_key
GROUP BY c.country
ORDER BY Avg_Salary_After_AI DESC
LIMIT 5;

-- =====================================================
-- المجالات الاعلى مرتبات واقل خطر فى الاستبدال
CREATE OR REPLACE VIEW v_Student_Best_Industries_Salary_Risk AS
SELECT 
    i.industry,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Industry_Salary,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Industry_Risk
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry
ORDER BY Avg_Industry_Salary DESC;

-- ==========================================================

-- هل درجة التعليم بتفرق اصلا فىالمرتبات بعد استخدام الذكاء الاصطناعى
CREATE OR REPLACE VIEW v_Student_Education_Impact_On_Salary AS
SELECT 
    e.education_label AS Education_Level,
    ROUND(AVG(f.salary_usd), 2) AS Avg_Salary_Before,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After
FROM Fact_Employment f
JOIN Dim_Education e ON f.education_key = e.education_key
GROUP BY e.education_label, e.education_level
ORDER BY e.education_level ASC;

-- ========================================================================
-- 
--
--  مووووهم
--
--
--
-- طب هل مستوى التعليم فارق مع الاستبدال ولا كله رايح والف الف مبروك
CREATE OR REPLACE VIEW v_Student_Education_vs_AI_Replacement AS
SELECT 
    e.education_label AS Education_Level,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk,
    ROUND(AVG(f.ai_replacement_score), 2) AS Avg_AI_Replacement_Score
FROM Fact_Employment f
JOIN Dim_Education e ON f.education_key = e.education_key
GROUP BY e.education_label, e.education_level
ORDER BY e.education_level ASC;
-- ==========================================================================================
-- ==========================================================================================
-- ==========================================================================================
-- ==========================================================================================
-- =====================================VIEWS ==========================================

-- فجوةالمهاراتبتزيدولابتقل بعداستخدامالذكاءالاصطناعى 
CREATE OR REPLACE VIEW v_Market_Skill_Gap_And_Disruption AS
SELECT 
    j.job_role,
    ROUND(AVG(f.skill_gap), 2) AS Avg_Skill_Gap,
    ROUND(AVG(f.ai_disruption_score), 2) AS Avg_AI_Disruption_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- =====================================================================

-- الاجور بتتغير بشكل ثابت ولا لاء
CREATE OR REPLACE VIEW v_Market_Wage_Volatility AS
SELECT 
    j.job_role,
    ROUND(AVG(f.wage_volatility), 2) AS Avg_Wage_Volatility
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role
ORDER BY Avg_Wage_Volatility DESC;

-- ===========================================================================

