CREATE DATABASE IF NOT EXISTS AI_IMPACT;
USE AI_IMPACT;
-- انشاء  جدول السنه
CREATE TABLE IF NOT EXISTS  Dim_Year (
    year_key INT PRIMARY KEY,
    year INT,
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
-- ===================================================================================================================================
-- ===================================================================================================================================
-- ===================================================================================================================================

-- FOR Executive Insights ::::::>>>>>>

-- AVG AI ADOPTION
SELECT ROUND(AVG(ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment;

-- ========================================================

-- AVG AUTOMATION RISK
SELECT ROUND(AVG(automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment;

-- =========================================================

-- AVG SALARY CHANGE
SELECT ROUND(AVG(salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment;

-- ===========================================================

-- اكتر المجالات استخداما
 SELECT 
    i.industry,
    ROUND(AVG(f.ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry
ORDER BY Avg_AI_Adoption_Pct DESC;

-- =================================================================

-- اكتر المجالات فى خطر الاستبدال
SELECT 
    i.industry,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry
ORDER BY Avg_Automation_Risk DESC;

-- ================================================================

-- المرتبات بتتغير بنسبة قد ايه
SELECT 
    y.year,
    ROUND(AVG(f.salary_usd), 2) AS Avg_Salary_Before,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment f
JOIN Dim_Year y ON f.year_key = y.year_key
GROUP BY y.year
ORDER BY y.year ASC;

-- ================================================================

-- نسب التوظيف بتزيد ولا بتقل 
SELECT 
    y.year,
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
JOIN Dim_Year y ON f.year_key = y.year_key
GROUP BY y.year
ORDER BY y.year ASC;

-- ==========================================================================

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

-- اكتر دوله بتستخدم ذكاء اصطناعى
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

-- ========================================================================
-- VIEWS
-- FIRST KPI AVG AI ADOPTION
CREATE OR REPLACE  VIEW v_Executive_KPI_AI_Adoption AS
SELECT ROUND(AVG(ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM fact_employment;
-- ============================================================================
-- SECOND KPI AVG AUTOMATION RISK
CREATE OR REPLACE  VIEW v_Executive_KPI_Automation_Risk AS
SELECT ROUND(AVG(automation_risk), 2) AS Avg_Automation_Risk
FROM fact_employment;
-- ==============================================================================
-- THIRD KPI AVG SALARY CHANGE
CREATE  OR REPLACE VIEW v_Executive_KPI_Salary_Change AS
SELECT ROUND(AVG(salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM fact_employment;
-- =================================================================================
-- اكتر المجالات المستخدمه ذكاء اصطناعى
CREATE OR REPLACE  VIEW v_Executive_Industry_AI_Adoption AS
SELECT 
    i.industry,
    ROUND(AVG(f.ai_adoption_pct), 2) AS Avg_AI_Adoption_Pct
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry;

-- ==================================================================================
-- الاكثر تعرض للاستبدال
CREATE OR REPLACE  VIEW v_Executive_Industry_Automation_Risk AS
SELECT 
    i.industry,
    ROUND(AVG(f.automation_risk), 2) AS Avg_Automation_Risk
FROM Fact_Employment f
JOIN Dim_Industry i ON f.industry_key = i.industry_key
GROUP BY i.industry;

-- =====================================================================================
-- الرواتب بتتغير بنسبة قد ايه 

CREATE OR REPLACE  VIEW v_Executive_Salary_Trends AS
SELECT 
    y.year,
    ROUND(AVG(f.salary_usd), 2) AS Avg_Salary_Before,
    ROUND(AVG(f.salary_after_usd), 2) AS Avg_Salary_After,
    ROUND(AVG(f.salary_change_pct), 2) AS Avg_Salary_Change_Pct
FROM Fact_Employment f
JOIN Dim_Year y ON f.year_key = y.year_key
GROUP BY y.year;

-- التوظيف بيزيد ولا يقل
CREATE OR REPLACE  VIEW v_Executive_Employment_Rate_Trends AS
SELECT 
    y.year,
    ROUND(AVG(f.country_employment_rate), 2) AS Avg_Employment_Rate
FROM Fact_Employment f
JOIN Dim_Year y ON f.year_key = y.year_key
GROUP BY y.year;
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
-- 
--  مستوى الخطر لكل وظيفه
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
--     ========================================== FOR EMPLOYMENT =================================================
--  مستوى الخطر لكل وظيفه
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

-- الوقت اللى الذكاء وفره بالدقايقalterSELECT 
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
    ROUND(AVG(f.ai_tools_used_count), 1) AS Avg_AI_Tools_Used
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- ==================================================================================

-- هل ممكن نشتغل عن بعد
SELECT 
    j.job_role,
    ROUND(AVG(f.remote_feasibility), 2) AS Remote_Feasibility_Pct
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- =====================================================================
-- الخبره والخطر
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

-- ====================================================================================================
-- =====================================================================================================
-- =====================================================================================================
-- =====================================================================================================
-- =====================================================================================================
-- ======================================================================================================


-- ====================== FOR Student Career  ======================================

-- الوظايف من ناحية اعلى المرتبات واقل خطر فى الاستبدال  فى وجود الذكاء الاصطناعى
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

-- ====================================================================
-- ====================================================================
-- ==================  VIEWS ==========================================
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

--  ========================================== FOR HR Managers ====================================

-- فجوةالمهاراتبتزيدولابتقل بعداستخدامالذكاءالاصطناعى 

SELECT 
    j.job_role,
    ROUND(AVG(f.skill_gap), 2) AS Avg_Skill_Gap,
    ROUND(AVG(f.ai_disruption_score), 2) AS Avg_AI_Disruption_Score
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_role;

-- =====================================================================

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
SELECT 
    j.job_category,
    ROUND(AVG(f.ai_disruption_score), 2) AS Avg_Category_Disruption
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_category
ORDER BY Avg_Category_Disruption DESC;

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

-- اكتر وظايف محتاجه تدريب
CREATE OR REPLACE VIEW v_Market_Top5_Reskilling_Urgency AS
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
CREATE OR REPLACE VIEW v_Market_Top_Disrupted_Categories AS
SELECT 
    j.job_category,
    ROUND(AVG(f.ai_disruption_score), 2) AS Avg_Category_Disruption
FROM Fact_Employment f
JOIN Dim_Job j ON f.job_key = j.job_key
GROUP BY j.job_category
ORDER BY Avg_Category_Disruption DESC;
