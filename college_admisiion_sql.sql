CREATE DATABASE college_admission;
SHOW DATABASES;
USE college_admission;

CREATE TABLE admissions (
    student_id BIGINT,
    age INT,
    gender VARCHAR(20),
    state VARCHAR(100),
    family_income DECIMAL(12,2),
    high_school_gpa DECIMAL(3,2),
    sat_score INT,
    act_score INT,
    attendance_rate DECIMAL(5,2),
    ap_courses INT,
    extracurricular_count INT,
    volunteer_hours INT,
    leadership_positions INT,
    coding_projects INT,
    social_media_hours DECIMAL(4,2),
    online_certifications INT,
    essay_score DECIMAL(5,2),
    recommendation_score DECIMAL(5,2),
    interview_score DECIMAL(5,2),
    admission_status VARCHAR(20)
);

-- DATA CLEANING 
-- Duplicate Records 
select 
student_id,count(*)
 from admissions
 group by student_id
having count(*)>1;

-- Missing Values
select 
count(*) -count(high_school_gpa) AS Missing_Gpa
from admissions;

-- invalid Values
SELECT *
FROM admissions
WHERE high_school_gpa < 0 or attendance_rate > 100;

-- SAT outside expected range
SELECT *
FROM admissions
WHERE sat_score < 400
OR sat_score > 1600;

-- Categorical Validation
SELECT DISTINCT gender
FROM admissions;

SELECT DISTINCT admission_status
FROM admissions;

SELECT DISTINCT state
FROM admissions;

-- Business_Quesries


-- Section A - Overall Performance 
 -- 1 How many students applied
 SELECT COUNT(*) AS total_applicants
FROM admissions;

-- 2 What percentage of applicants were admitted
SELECT
    admission_status,
    COUNT(*) AS students,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM admissions), 2) AS percentage
FROM admissions
GROUP BY admission_status;

-- What is the average academic profile of applicants
SELECT
    ROUND(AVG(high_school_gpa),2) AS avg_gpa,
    ROUND(AVG(sat_score),0) AS avg_sat,
    ROUND(AVG(act_score),0) AS avg_act
    from admissions;
    
-- Average Interview & Essay Scores
SELECT
    ROUND(AVG(interview_score),2) AS avg_interview,
    ROUND(AVG(essay_score),2) AS avg_essay,
    ROUND(AVG(recommendation_score),2) AS avg_recommendation
FROM admissions;

-- Applicant Distribution by State
SELECT
    state,
    COUNT(*) AS applicants
FROM admissions
GROUP BY state
ORDER BY applicants DESC;

-- Section B — Academic Performance 
-- GPA by Admission Status
SELECT
    admission_status,
    ROUND(AVG(high_school_gpa),2) AS avg_gpa
FROM admissions
GROUP BY admission_status;

-- SAT by Admission Status
SELECT
    admission_status,
    ROUND(AVG(sat_score),0) AS avg_sat
FROM admissions
GROUP BY admission_status;

-- ACT by Admission Status
SELECT
    admission_status,
    ROUND(AVG(act_score),0) AS avg_act
FROM admissions
GROUP BY admission_status;

-- Attendance by Admission Status
SELECT
    admission_status,
    ROUND(AVG(attendance_rate),2) AS avg_attendance
FROM admissions
GROUP BY admission_status;

-- Section C — Demographics
-- Gender-wise Admission Rate

SELECT
    gender,
    admission_status,
    COUNT(*) AS students
FROM admissions
GROUP BY gender, admission_status
ORDER BY gender;

-- Average GPA by State
SELECT
    state,
    ROUND(AVG(high_school_gpa),2) AS average_gpa
FROM admissions
GROUP BY state
ORDER BY average_gpa DESC;

-- Average SAT by State
SELECT
    state,
    ROUND(AVG(sat_score),0) AS average_sat
FROM admissions
GROUP BY state
ORDER BY average_sat DESC;

-- Average Family Income by State
SELECT
    state,
    ROUND(AVG(family_income),2) AS average_income
FROM admissions
GROUP BY state
ORDER BY average_income DESC;

-- Average Age by Admission Status
SELECT
    admission_status,
    ROUND(AVG(age),1) AS average_age
FROM admissions
GROUP BY admission_status;

-- SECTION D — Advanced Business Analysis
-- GPA Categories (CASE)
SELECT
CASE
WHEN high_school_gpa >= 3.8 THEN 'Excellent'
WHEN high_school_gpa >= 3.5 THEN 'Very Good'
WHEN high_school_gpa >= 3.0 THEN 'Good'
ELSE 'Average'
END AS gpa_category,
COUNT(*) AS students
FROM admissions
GROUP BY gpa_category
ORDER BY students DESC;

-- Admission Rate by GPA Category
SELECT
CASE
WHEN high_school_gpa >=3.8 THEN 'Excellent'
WHEN high_school_gpa >=3.5 THEN 'Very Good'
WHEN high_school_gpa >=3.0 THEN 'Good'
ELSE 'Average'
END AS gpa_category,
admission_status,
COUNT(*) AS students
FROM admissions
GROUP BY gpa_category, admission_status
ORDER BY gpa_category;

-- Top States by Admission Rate (CTE)

WITH state_summary AS
(
    SELECT
        state,
        COUNT(*) AS total_students,
        SUM(CASE
                WHEN admission_status = 1 THEN 1
                ELSE 0
            END) AS admitted_students
    FROM admissions
    GROUP BY state
)
SELECT
    state,
    admitted_students,
    total_students,
    ROUND((admitted_students * 100.0) / total_students, 2) AS admission_rate
FROM state_summary
ORDER BY admission_rate DESC;

-- Which states have the highest average GPA
SELECT
    state,
    ROUND(AVG(high_school_gpa),2) AS average_gpa,
    RANK() OVER(
        ORDER BY AVG(high_school_gpa) DESC
    ) AS state_rank
FROM admissions
GROUP BY state;

-- Who are the top 10 students based on GPA
SELECT
    student_id,
    high_school_gpa,
    RANK() OVER(
        ORDER BY high_school_gpa DESC
    ) AS gpa_rank
FROM admissions
LIMIT 10;

-- Which performance tier does each student belong to
SELECT
    student_id,
    high_school_gpa,
    NTILE(10) OVER(
        ORDER BY high_school_gpa DESC
    ) AS performance_tier
FROM admissions;

-- Who are the top-performing candidates in interviews
SELECT
    student_id,
    interview_score,
    DENSE_RANK() OVER(
        ORDER BY interview_score DESC
    ) AS interview_rank
FROM admissions
LIMIT 10;
-- What percentage of total applicants comes from each state
SELECT
    state,
    COUNT(*) AS applicants,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM admissions),
        2
    ) AS applicant_percentage
FROM admissions
GROUP BY state
ORDER BY applicants DESC;
-- Can we create a reusable summary for dashboards
CREATE VIEW vw_admission_summary AS
SELECT
    state,
    COUNT(*) AS total_students,
    ROUND(AVG(high_school_gpa),2) AS average_gpa,
    ROUND(AVG(sat_score),0) AS average_sat,
    ROUND(AVG(interview_score),2) AS average_interview_score
FROM admissions
GROUP BY state;
-- Which states have the strongest academic profile
SELECT *
FROM vw_admission_summary
ORDER BY average_gpa DESC;
-- Does GPA category influence admission rate
SELECT
    CASE
        WHEN high_school_gpa >= 3.8 THEN 'Excellent'
        WHEN high_school_gpa >= 3.5 THEN 'Very Good'
        WHEN high_school_gpa >= 3.0 THEN 'Good'
        ELSE 'Average'
    END AS gpa_category,
    COUNT(*) AS applicants,
    SUM(admission_status) AS admitted_students,
    ROUND(SUM(admission_status) * 100.0 / COUNT(*), 2) AS admission_rate
FROM admissions
GROUP BY gpa_category
ORDER BY admission_rate DESC;

select * from admissions limit 350000;



SELECT
    state,
    COUNT(student_id) AS total_students
FROM admissions
GROUP BY state
ORDER BY total_students DESC;