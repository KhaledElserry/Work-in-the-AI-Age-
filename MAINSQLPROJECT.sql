-- 
CREATE DATABASE IF NOT EXISTS MAINSQLPROJECT ;
USE MAINSQLPROJECT  ;

CREATE TABLE IF NOT EXISTS Dim_Country (
    Country_key INT PRIMARY KEY,
    country VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS Dim_Education (
    Education_key INT PRIMARY KEY,
    education_requirement_level INT,
    education_requirement_label VARCHAR(150)
);

-- ربط جدول عائلات الوظائف
CREATE TABLE IF NOT EXISTS Dim_Family (
    Job_Family_key INT PRIMARY KEY,
    job_family VARCHAR(150)
);


CREATE TABLE IF NOT EXISTS Dim_Industry (
    Industry_key INT PRIMARY KEY,
    industry VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS Dim_Job (
    ` Job key` INT PRIMARY KEY,
    job_role VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS Dim_Automation_Category (
    automation_risk_category INT PRIMARY KEY,
    automation_risk_category2 VARCHAR(50)
);

-- ربط جدول فئات مخاطر الذكاء الاصطناعي
CREATE TABLE IF NOT EXISTS Dim_Risk_Category (
    current_ai_risk_category_key INT PRIMARY KEY,
    current_ai_risk_category VARCHAR(50)
);


CREATE TABLE IF NOT EXISTS Fact10 (
    job_id INT PRIMARY KEY,
    job_role VARCHAR(150),
    job_family VARCHAR(150),
    industry VARCHAR(150),
    country VARCHAR(100),
    year INT,
    automation_risk_percent DECIMAL(5,2),
    ai_replacement_score DECIMAL(5,2),
    skill_gap_index DECIMAL(5,2),
    salary_before_usd VARCHAR(50), 
    salary_after_usd VARCHAR(50),  
    salary_change_percent DECIMAL(5,2),
    skill_demand_growth_percent DECIMAL(5,2),
    remote_feasibility_score DECIMAL(5,2),
    ai_adoption_level DECIMAL(5,2),
    education_requirement_label VARCHAR(150),
    education_requirement_level INT,
    skill_transition_pressure DECIMAL(5,2),
    wage_volatility_index DECIMAL(5,2),
    reskilling_urgency_score DECIMAL(5,2),
    ai_disruption_intensity DECIMAL(5,2),
    

    industry_key INT,
    country_key INT,
    education_key INT,
    job_family_key INT,
    Automation_Risk_key INT,
    Current_AI_Risk_key INT,
    
    automation_risk_category VARCHAR(50),
    current_ai_risk_category VARCHAR(50),
    

    CONSTRAINT FK_Fact_Industry FOREIGN KEY (industry_key) 
        REFERENCES Dim_Industry(Industry_key) 
        ON DELETE SET NULL ON UPDATE CASCADE,
        
    CONSTRAINT FK_Fact_Country FOREIGN KEY (country_key) 
        REFERENCES Dim_Country(Country_key) 
        ON DELETE SET NULL ON UPDATE CASCADE,
        
    CONSTRAINT FK_Fact_Education FOREIGN KEY (education_key) 
        REFERENCES Dim_Education(Education_key) 
        ON DELETE SET NULL ON UPDATE CASCADE,
        
    CONSTRAINT FK_Fact_Family FOREIGN KEY (job_family_key) 
        REFERENCES Dim_Family(Job_Family_key) 
        ON DELETE SET NULL ON UPDATE CASCADE,
        
    CONSTRAINT FK_Fact_Automation FOREIGN KEY (Automation_Risk_key) 
        REFERENCES Dim_Automation_Category(automation_risk_category) 
        ON DELETE SET NULL ON UPDATE CASCADE,
        
    CONSTRAINT FK_Fact_Risk FOREIGN KEY (Current_AI_Risk_key) 
        REFERENCES Dim_Risk_Category(current_ai_risk_category_key) 
        ON DELETE SET NULL ON UPDATE CASCADE
);
-- نسبة الخوف من احتلال ال
-- AI
-- للوظايف خلال السنين
SELECT 
    year,
    ROUND(AVG(automation_risk_percent), 2) AS avg_automation_risk_percent
FROM Fact10
GROUP BY year
ORDER BY year;
-- بنشوف المجال والبلد ال 
-- AI
-- بيستبدل ال الوظايف بنسبة قد ايه
SELECT 
    industry,
    country,
    year,
    ROUND(AVG(ai_replacement_score), 2) AS avg_ai_replacement_score
FROM Fact10
GROUP BY industry, country, year
ORDER BY industry, country, year;
-- مهم نرجعله هيتقفش
SELECT 
    year,
    ROUND(AVG(CAST(REPLACE(REPLACE(salary_before_usd, '$', ''), ',', '') AS DECIMAL(10,2))), 2) AS avg_salary_before,
    ROUND(AVG(CAST(REPLACE(REPLACE(salary_after_usd, '$', ''), ',', '') AS DECIMAL(10,2))), 2) AS avg_salary_after,
    ROUND(
        AVG(CAST(REPLACE(REPLACE(salary_before_usd, '$', ''), ',', '') AS DECIMAL(10,2))) - 
        AVG(CAST(REPLACE(REPLACE(salary_after_usd, '$', ''), ',', '') AS DECIMAL(10,2)))
    , 2) AS salary_gap
FROM Fact10
GROUP BY year
ORDER BY year;
-- نفس 2 بس شكله احلى ومنظم اكتر
SELECT 
    industry,
    country,
    -- بنحسب المتوسط فقط لو السنة 2021
    ROUND(AVG(CASE WHEN year = 2021 THEN ai_replacement_score END), 2) AS score_2021,
    -- بنحسب المتوسط فقط لو السنة 2024
    ROUND(AVG(CASE WHEN year = 2024 THEN ai_replacement_score END), 2) AS score_2024,
    -- بنطرحهم من بعض في نفس السطر عشان نجيب الصافي
    ROUND(
        AVG(CASE WHEN year = 2024 THEN ai_replacement_score END) - 
        AVG(CASE WHEN year = 2021 THEN ai_replacement_score END)
    , 2) AS total_jump
FROM Fact10
GROUP BY industry, country
ORDER BY total_jump DESC; 
-- هيرتبلك الصناعات والدول الأسرع نمواً في المخاطر فوق خالص
-- 🎯 الكويري دي بتقيس مفعول الزمن المتأخر (Lag Effect):
-- بتعرفنا هل زيادة تبني الشركات للذكاء الاصطناعي في سنة (مثلاً 2021) 
-- بتؤدي لزيادة مخاطر أتمتة الوظائف في السنة اللي بعدها علطول (2022)؟

SELECT 
    f1.year AS previous_year,
    ROUND(AVG(f1.ai_adoption_level), 2) AS prev_ai_adoption,
    f2.year AS current_year,
    ROUND(AVG(f2.automation_risk_percent), 2) AS current_automation_risk
FROM Fact10 f1
JOIN Fact10 f2 
    ON f1.job_role = f2.job_role 
   AND f1.country = f2.country 
   AND f1.year = f2.year - 1
GROUP BY f1.year, f2.year
ORDER BY f1.year;
-- ما هو التغير السنوي في الرواتب قبل وبعد الذكاء الاصطناعي؟ وهل فجوة الأجور تتسع مع مرور الوقت
SELECT 
    year,
    ROUND(AVG(CAST(REPLACE(REPLACE(salary_before_usd, '$', ''), ',', '') AS DECIMAL(10,2))), 2) AS avg_salary_before,
    ROUND(AVG(CAST(REPLACE(REPLACE(salary_after_usd, '$', ''), ',', '') AS DECIMAL(10,2))), 2) AS avg_salary_after,
    ROUND(
        AVG(CAST(REPLACE(REPLACE(salary_before_usd, '$', ''), ',', '') AS DECIMAL(10,2))) - 
        AVG(CAST(REPLACE(REPLACE(salary_after_usd, '$', ''), ',', '') AS DECIMAL(10,2)))
    , 2) AS salary_gap
FROM Fact10
GROUP BY year
ORDER BY year;

-- 🎯 الكويري دي بتجيب متوسط شدة اضطراب الذكاء الاصطناعي لكل وظيفة محددة 
-- وترتبهم تنازلياً عشان تطلع الوظائف الأعلى خطورة فوق خالص
SELECT 
    job_role,
    ROUND(AVG(ai_disruption_intensity), 2) AS cumulative_disruption
FROM Fact10
GROUP BY job_role
ORDER BY cumulative_disruption DESC;
 
-- 🎯 الكويري دي بتجيب متوسط شدة اضطراب الذكاء الاصطناعي لكل صناعة على مدار كل السنين
-- وبترتبهم من الأعلى للأسفل عشان نعرف أول 3 صناعات اتبهدلت تراكمياً
SELECT 
    industry,
    ROUND(AVG(ai_disruption_intensity), 2) AS cumulative_disruption
FROM Fact10
GROUP BY industry
ORDER BY cumulative_disruption DESC;
-- 🎯 الكويري دي بتحدد أول سنة وأخر سنة في الداتا، وبتحسب متوسط المخاطر لكل وظيفة في السنتين دول،
-- وفي الآخر بتطرحهم عشان تطلع الوظائف اللي خيط الخطر عندها نط فجأة لأعلى درجة.

WITH MinMaxYears AS (
    -- الخطوة 1: بنعرف أوتوماتيك أول سنة وأخر سنة في الجدول ونخزنهم
    SELECT MIN(year) AS start_yr, MAX(year) AS end_yr FROM Fact10
),
RiskStart AS (
    -- الخطوة 2: بنحسب متوسط مخاطر كل وظيفة في أول سنة بس
    SELECT job_role, AVG(automation_risk_percent) AS start_risk
    FROM Fact10 
    WHERE year = (SELECT start_yr FROM MinMaxYears) 
    GROUP BY job_role
),
RiskEnd AS (
    -- الخطوة 3: بنحسب متوسط مخاطر كل وظيفة في أخر سنة بس
    SELECT job_role, AVG(automation_risk_percent) AS end_risk
    FROM Fact10 
    WHERE year = (SELECT end_yr FROM MinMaxYears) 
    GROUP BY job_role
)
-- الخطوة الأخيرة: بنربط الخطوتين ببعض ونطرح عشان نجيب القفزة الصافية (Jump)
SELECT 
    s.job_role,
    ROUND(s.start_risk, 2) AS risk_in_first_year,
    ROUND(e.end_risk, 2) AS risk_in_latest_year,
    ROUND(e.end_risk - s.start_risk, 2) AS risk_jump
FROM RiskStart s
JOIN RiskEnd e ON s.job_role = e.job_role
ORDER BY risk_jump DESC; -- الترتيب من صاحب أكبر قفزة لأقل قفزة يلا ده كمان اشرحه حلو بقى اوى وقولى كل فلانكشن ليه وامتى بستخدمها

-- 🎯 الكويري دي بتحسب متوسط تقلب الأجور لكل وظيفة وصناعة في كل سنة،
-- وفي نفس الوقت بتحسب (الانحراف المعياري) عبر السنين عشان تكشف هل الرقم ثابت ولا متغير!

SELECT 
    job_role,
    industry,
    year,
    ROUND(AVG(wage_volatility_index), 2) AS avg_wage_volatility,
    
    -- دالة الانحراف المعياري (STDDEV) عبر السنين للوظيفة الواحدة
    ROUND(STDDEV(wage_volatility_index) OVER(PARTITION BY job_role, industry), 2) AS volatility_variation_over_years
FROM Fact10
GROUP BY job_role, industry, year, wage_volatility_index
ORDER BY job_role, year;

-- 🎯 كود الخلاصة: بيجيبلك كل وظيفة في سطر واحد، ويحسب أقصى تقلب وأقل تقلب،
-- ويقولكِ بكلمة واضحة (ثابتة أم متغيرة) عشان التقرير بتاعكِ.

WITH VolatilityCheck AS (
    SELECT 
        job_role,
        industry,
        MIN(wage_volatility_index) AS min_vol,
        MAX(wage_volatility_index) AS max_vol,
        STDDEV(wage_volatility_index) AS std_dev
    FROM Fact10
    GROUP BY job_role, industry
)
SELECT 
    job_role,
    industry,
    ROUND(std_dev, 2) AS deviation_score,
    -- لو الانحراف صفر يبقى ثابتة، غير كده تبقى متغيرة
    CASE 
        WHEN std_dev = 0 THEN 'Static (ثابت عبر السنين)'
        ELSE 'Variable (متغير ويتأثر بالوقت)'
    END AS behavior_status
FROM VolatilityCheck
ORDER BY deviation_score DESC; -- هيجيبلكِ الوظائف الأكثر تقلباً وتغيراً فوق خالص

-- 🎯 التحسين المظبوط: بنحسب متوسط التقلب السنوي الأول، 
-- وبعدين بنقيس الانحراف المعياري للمتوسطات دي عشان نعرف هل المؤشر ثابت عبر السنين أم متغير.

WITH YearlyVolatility AS (
    -- خطوة 1: بنجيب صافي المتوسط لكل وظيفة في كل سنة
    SELECT 
        job_role,
        industry,
        year,
        AVG(wage_volatility_index) AS avg_volatility
    FROM Fact10
    GROUP BY job_role, industry, year
)
-- خطوة 2: بنحسب التباين والانحراف عبر السنين
SELECT 
    job_role,
    industry,
    year,
    ROUND(avg_volatility, 2) AS avg_wage_volatility,
    ROUND(STDDEV(avg_volatility) OVER(PARTITION BY job_role, industry), 2) AS volatility_variation_over_years
FROM YearlyVolatility
ORDER BY job_role, year;

-- الكويري السابقة	الكويري الحالية
-- بتحسب متوسط كل سنة أولًا	بتحسب مباشرة على كل البيانات
-- تستخدم OVER(PARTITION BY)	تستخدم GROUP BY
-- تعرض كل سنة في صف مستقل	تعرض صفًا واحدًا لكل وظيفة
-- مناسبة لتحليل الاتجاهات عبر الزمن (Trend Analysis)	مناسبة لعمل ملخص نهائي أو Dashboard
-- الناتج يحتوي على السنة	الناتج لا يحتوي على السنة
-- 🎯 الكويري دي بتجيب أعلى 10 وظائف مهددة بالأتمتة
-- وبترتبهم من الأكبر للأصغر بناءً على متوسط نسبة المخاطر
SELECT 
    job_role,
    job_family,
    ROUND(AVG(automation_risk_percent), 2) AS avg_automation_risk
FROM Fact10
GROUP BY job_role, job_family
ORDER BY avg_automation_risk DESC
LIMIT 10; -- عشان نجيب التوب 10 بس وم نغرقش في السطور

-- 🎯 الكويري دي بتركّز على القطاعات (Industries) اللي فيها أعلى سكور لاستبدال الوظائف بالـ AI
SELECT 
    industry,
    ROUND(AVG(ai_replacement_score), 2) AS avg_ai_replacement
FROM Fact10
GROUP BY industry
ORDER BY avg_ai_replacement DESC;
-- 🎯 كويري مقارنة الدول: بتعرض متوسط خطر الأتمتة ومتوسط تبني الذكاء الاصطناعي لكل دولة
SELECT 
    country,
    ROUND(AVG(automation_risk_percent), 2) AS avg_automation_risk,
    ROUND(AVG(ai_adoption_level), 2) AS avg_tech_adoption
FROM Fact10
GROUP BY country
ORDER BY avg_automation_risk DESC;
--  بتجيب متوسط الخطر لكل سنة متاح فيها داتا
SELECT 
    year,
    ROUND(AVG(automation_risk_percent), 2) AS avg_automation_risk_over_time
FROM Fact10
GROUP BY year
ORDER BY year; -- الترتيب بالسنين من الأقدم للأحدث عشان السهم يترسم صح