CREATE DATABASE phonepe_data;
USE phonepe_data;
CREATE TABLE aggregated_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(50),
    count BIGINT,
    percentage FLOAT,
    registeredUsers BIGINT,
    appOpens BIGINT,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE aggregated_transaction (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    count BIGINT,
    amount DOUBLE,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE aggregated_insurance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    count BIGINT,
    amount DOUBLE,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE map_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(50),
    count BIGINT,
    percentage FLOAT,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE map_map (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),   -- 🔥 replace district/type confusion
    type VARCHAR(50),
    count BIGINT,
    amount DOUBLE,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE map_insurance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(50),
    count BIGINT,
    amount DOUBLE,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE top_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    count BIGINT,
    state VARCHAR(50),
    year INT,
    quarter INT
);
CREATE TABLE top_map (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),   -- state/district/pincode
    type VARCHAR(50),
    count BIGINT,
    amount DOUBLE,
    year INT,
    quarter INT
);
CREATE TABLE top_insurance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    count BIGINT,
    amount DOUBLE,
    state VARCHAR(50),
    year INT,
    quarter INT
);

ALTER TABLE top_map ADD COLUMN level VARCHAR(50);
ALTER TABLE top_insurance ADD COLUMN level VARCHAR(50);
ALTER TABLE top_user ADD COLUMN level VARCHAR(50);

SELECT * FROM aggregated_user;
SELECT * FROM aggregated_transaction;
SELECT * FROM aggregated_insurance;
SELECT * FROM map_user;
SELECT * FROM map_map;
SELECT * FROM map_insurance;
SELECT * FROM top_user;
SELECT * FROM top_map;
SELECT * FROM top_insurance;

/*1. Decoding Transaction Dynamics on PhonePe
Scenario
PhonePe, a leading digital payments platform, has recently identified significant 
variations in transaction behavior across states, quarters, and payment categories. 
While some regions and transaction types demonstrate consistent growth, others show 
stagnation or decline. The leadership team seeks a deeper understanding of these
 patterns to drive targeted business strategies.*/
 
 # State-wise Total Transaction Volume & Amount
 SELECT 
    state,
    SUM(count) AS total_transactions,
    SUM(amount) AS total_amount
FROM aggregated_transaction
GROUP BY state
ORDER BY total_amount DESC;

# Quarter-wise Growth Trend
SELECT year,
    quarter,
    SUM(amount) AS total_amount
FROM aggregated_transaction
GROUP BY year, quarter
ORDER BY year, quarter;

# Transaction Type Contribution
SELECT 
    type,
    SUM(amount) AS total_amount,
    SUM(count) AS total_count
FROM aggregated_transaction
GROUP BY type
ORDER BY total_amount DESC;

# Top States per Transaction Category
SELECT 
    type,
    state,
    SUM(amount) AS total_amount
FROM aggregated_transaction
GROUP BY type, state
ORDER BY type, total_amount DESC;

# Growth Rate (Quarter-over-Quarter)
SELECT 
    state,
    year,
    quarter,
    SUM(amount) AS total_amount,
    LAG(SUM(amount)) OVER (PARTITION BY state ORDER BY year, quarter) AS prev_amount
FROM aggregated_transaction
GROUP BY state, year, quarter;

/*2. Device Dominance and User Engagement Analysis
Scenario
PhonePe aims to enhance user engagement and improve app performance by understanding 
user preferences across different device brands. The data reveals the number of 
registered users and app opens, segmented by device brands, regions, and time periods.
However, trends in device usage vary significantly across regions, and some devices 
are disproportionately underutilized despite high registration numbers.*/

# Brand-wise User Base & Engagement
SELECT 
    brand,
    SUM(registeredUsers) AS total_users,
    SUM(appOpens) AS total_app_opens,
    ROUND(SUM(appOpens) / SUM(registeredUsers), 2) AS engagement_ratio
FROM aggregated_user
GROUP BY brand
ORDER BY engagement_ratio DESC;

# Best State Device Preference
SELECT 
    state,
    brand,
    SUM(registeredUsers) AS users
FROM aggregated_user
WHERE state IS NOT NULL 
GROUP BY state, brand
ORDER BY users DESC, state;

# Detect Low Engagement Devices (High Users, Low Opens)
SELECT 
    brand,
    SUM(registeredUsers) AS users,
    SUM(appOpens) AS opens,
    ROUND(SUM(appOpens)/SUM(registeredUsers), 2) AS engagement_ratio
FROM aggregated_user
GROUP BY brand
HAVING users > 1000000 AND engagement_ratio < 20.5
ORDER BY engagement_ratio;

# Time-based Engagement Trend (Quarter-wise)
SELECT 
    year,
    quarter,
    SUM(registeredUsers) AS users,
    SUM(appOpens) AS opens,
    ROUND(SUM(appOpens)/SUM(registeredUsers), 2) AS engagement_ratio
FROM aggregated_user
GROUP BY year, quarter
ORDER BY year, quarter;

# Device Engagement vs Transaction Activity 
SELECT 
    au.brand,
    SUM(au.registeredUsers) AS users,
    SUM(au.appOpens) AS opens,
    SUM(at.amount) AS total_transaction_amount,
    ROUND(SUM(at.amount)/SUM(au.registeredUsers), 2) AS value_per_user
FROM aggregated_user au
JOIN aggregated_transaction at
    ON au.state = at.state
    AND au.year = at.year
    AND au.quarter = at.quarter
GROUP BY au.brand
ORDER BY value_per_user DESC;

/*3. Insurance Penetration and Growth Potential Analysis
Scenario
PhonePe has ventured into the insurance domain, providing users with options to secure
various policies. With increasing transactions in this segment, the company seeks to 
analyze its growth trajectory and identify untapped opportunities for insurance adoption 
at the state level. This data will help prioritize regions for marketing efforts and 
partnerships with insurers.*/
 
# State-wise Insurance Adoption
SELECT 
    state,
    SUM(count) AS total_policies,
    SUM(amount) AS total_amount
FROM aggregated_insurance
WHERE state IS NOT NULL
GROUP BY state
ORDER BY total_amount DESC;

# Insurance Growth Over Time
SELECT 
    year,
    quarter,
    SUM(amount) AS total_amount,
    SUM(count) AS total_policies
FROM aggregated_insurance
GROUP BY year, quarter
ORDER BY year, quarter;

# State-wise Growth Rate (Quarter-on-Quarter)
SELECT 
    state,
    year,
    quarter,
    SUM(amount) AS total_amount,
    LAG(SUM(amount)) OVER (PARTITION BY state ORDER BY year, quarter) AS prev_amount,
    ROUND(
        (SUM(amount) - LAG(SUM(amount)) OVER (PARTITION BY state ORDER BY year, quarter)) 
        / LAG(SUM(amount)) OVER (PARTITION BY state ORDER BY year, quarter) * 100, 
    2) AS growth_percent
FROM aggregated_insurance
WHERE state IS NOT NULL
GROUP BY state, year, quarter;

# Insurance Penetration vs Transactions
SELECT 
    ai.state,
    SUM(ai.amount) AS insurance_amount,
    SUM(at.amount) AS transaction_amount,
    ROUND(SUM(ai.amount)/SUM(at.amount), 4) AS penetration_ratio
FROM aggregated_insurance ai
JOIN aggregated_transaction at
    ON ai.state = at.state
    AND ai.year = at.year
    AND ai.quarter = at.quarter
WHERE ai.state IS NOT NULL
GROUP BY ai.state
ORDER BY penetration_ratio DESC;

# Identify Untapped High-Potential States
 SELECT 
    ai.state,
    SUM(ai.amount) AS insurance_amount,
    SUM(at.amount) AS transaction_amount,
    ROUND(SUM(ai.amount)/SUM(at.amount), 4) AS penetration_ratio
FROM aggregated_insurance ai
JOIN aggregated_transaction at
    ON ai.state = at.state
    AND ai.year = at.year
    AND ai.quarter = at.quarter
WHERE ai.state IS NOT NULL
GROUP BY ai.state
HAVING penetration_ratio < 0.01
ORDER BY transaction_amount DESC;

SELECT 
    name AS district,
    state,
    SUM(amount) AS insurance_amount
FROM map_insurance
GROUP BY state, district
ORDER BY insurance_amount DESC;

/*4. User Registration Analysis
Scenario
PhonePe aims to conduct an analysis of user registration data to identify 
the top states, districts, and pin codes from which the most users registered 
during a specific year-quarter combination. This analysis will provide insights
 into user engagement patterns and highlight potential growth areas.*/
 
 # Top States by User Registrations
 SELECT 
    name AS state,
    SUM(count) AS total_users
FROM top_user
WHERE level = 'STATES'
GROUP BY name
ORDER BY total_users DESC
LIMIT 10;

# Top Districts by Users
SELECT 
    state,
    brand,
    SUM(count) AS users
FROM map_user
GROUP BY state, brand
ORDER BY users DESC
LIMIT 10;

# State vs District User Distribution
SELECT 
    m.state,
    m.brand AS district,
    SUM(m.count) AS district_users,
    t.total_state_users,
    ROUND(SUM(m.count)/t.total_state_users, 2) AS ratio
FROM map_user m
JOIN (
    SELECT name, SUM(count) AS total_state_users
    FROM top_user
    WHERE level = 'STATES'
    GROUP BY name
) t
ON m.state = t.name
GROUP BY m.state, m.brand
ORDER BY m.state, district_users DESC;

# High User but Low Engagement Regions
SELECT 
    m.state,
    m.users,
    a.opens,
    ROUND(a.opens / m.users, 2) AS engagement_ratio
FROM 
(
    SELECT 
        state,
        SUM(count) AS users
    FROM map_user
    WHERE state IS NOT NULL
    GROUP BY state
) m
JOIN
(
    SELECT 
        state,
        SUM(appOpens) AS opens
    FROM aggregated_user
    WHERE state IS NOT NULL
    GROUP BY state
) a
ON m.state = a.state
ORDER BY engagement_ratio;

# Growth Trend (User Registrations)
SELECT 
    name AS state,
    year,
    quarter,
    SUM(count) AS users,
    LAG(SUM(count)) OVER (
        PARTITION BY name 
        ORDER BY year, quarter
    ) AS prev_users
FROM top_user
WHERE level = 'STATES'
GROUP BY name, year, quarter;

/*5. Transaction Analysis Across States and Districts
Scenario
PhonePe is conducting an analysis of transaction data to identify the top-performing states,
 districts, and pin codes in terms of transaction volume and value. This analysis will help
 understand user engagement patterns and identify key areas for targeted marketing efforts.*/
 
 # Top Performing States (from top_map)
 SELECT 
    name AS state,
    SUM(amount) AS total_amount,
    SUM(count) AS total_transactions
FROM top_map
WHERE level = 'STATES'
GROUP BY name
ORDER BY total_amount DESC
LIMIT 10;

# Top Districts (from map_map)
SELECT 
    state,
    name AS district,
    SUM(amount) AS total_amount
FROM map_map
GROUP BY state, district
ORDER BY total_amount DESC
LIMIT 10;

# State vs District Contribution
 SELECT 
    m.state,
    SUM(m.amount) AS district_total,
    t.total_state_amount,
    ROUND(SUM(m.amount)/t.total_state_amount, 2) AS contribution_ratio
FROM map_map m
JOIN (
    SELECT name, SUM(amount) AS total_state_amount
    FROM top_map
    WHERE level = 'STATES'
    GROUP BY name
) t
ON m.state = t.name
GROUP BY m.state;

# High Value but Low Count Districts
SELECT 
    state,
    name AS district,
    SUM(amount)/SUM(count) AS avg_value
FROM map_map
GROUP BY state, district
ORDER BY avg_value DESC
LIMIT 10;

# Growth Trend at District Level
SELECT 
    state,
    name AS district,
    year,
    quarter,
    SUM(amount) AS total_amount,
    LAG(SUM(amount)) OVER (
        PARTITION BY state, name 
        ORDER BY year, quarter
    ) AS prev_amount
FROM map_map
GROUP BY state, name, year, quarter;
 
