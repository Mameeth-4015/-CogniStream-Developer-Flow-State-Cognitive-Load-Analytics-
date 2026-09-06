CREATE DATABASE IF NOT EXISTS dev_flow_analytics;
USE dev_flow_analytics;

DROP TABLE IF EXISTS raw_dim_activity_type;
DROP TABLE IF EXISTS raw_dim_date;
DROP TABLE IF EXISTS raw_dim_developer;
DROP TABLE IF EXISTS raw_dim_interruption;
DROP TABLE IF EXISTS raw_fact_developer_activity_log;
DROP TABLE IF EXISTS raw_fact_flow_daily;

CREATE TABLE raw_dim_activity_type (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    activity_id VARCHAR(50),
    activity_name VARCHAR(255),
    cognitive_category VARCHAR(255),
    is_deep_work VARCHAR(50)
);
 
CREATE TABLE raw_dim_date (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    date_key VARCHAR(50),
    date VARCHAR(50),
    day_of_week  VARCHAR(50),
    day_number_in_week  VARCHAR(50),
    is_weekend VARCHAR(50),
    week_number VARCHAR(50),
    month_name VARCHAR(50),
    quarter VARCHAR(50),
    year VARCHAR(50),
    sprint_name VARCHAR(50)
);
CREATE TABLE raw_dim_developer (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    developer_id  VARCHAR(50),
    developer_name VARCHAR(255),
    team_name VARCHAR(255),
    seniority_level VARCHAR(50),
    primary_ide  VARCHAR(50),
    timezone VARCHAR(50)
);
 
CREATE TABLE raw_dim_interruption (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    interruption_id VARCHAR(50),
    source_channel  VARCHAR(255),
    interruption_category VARCHAR(255),
    urgency_tier VARCHAR(50),
    requires_action VARCHAR(50),
    avg_recovery_latency_min VARCHAR(50)
);
 
CREATE TABLE raw_fact_developer_activity_log (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    log_id  VARCHAR(50),
    developer_id VARCHAR(50),
    date_key  VARCHAR(50),
    timestamp_start VARCHAR(50),
    timestamp_end  VARCHAR(50),
    activity_id  VARCHAR(50),
    interruption_id  VARCHAR(50),
    session_duration_minutes VARCHAR(50),
    in_flow_state  VARCHAR(50),
    context_switch_flag VARCHAR(50),
    cognitive_recovery_minutes VARCHAR(50)
);
	
CREATE TABLE raw_fact_flow_daily (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    developer_id  VARCHAR(50),
    date_key VARCHAR(50),
    total_tracked_minutes VARCHAR(50),
    deep_work_minutes VARCHAR(50),
    pure_flow_minutes VARCHAR(50),
    total_interruptions VARCHAR(50),
    ci_cd_interruptions  VARCHAR(50),
    total_cognitive_tax_minutes VARCHAR(50),
    flow_efficiency_pct VARCHAR(50),
    cognitive_friction_score VARCHAR(50)
);
SELECT COUNT(*) FROM raw_dim_activity_type;
SELECT COUNT(*) FROM raw_dim_date;
SELECT COUNT(*) FROM raw_dim_developer;
SELECT COUNT(*) FROM raw_dim_interruption;
SELECT COUNT(*) FROM raw_fact_developer_activity_log;
SELECT COUNT(*) FROM raw_fact_flow_daily;

SELECT 'raw_dim_activity_type' AS table_name, COUNT(*) AS row_count FROM raw_dim_activity_type
UNION ALL SELECT 'raw_dim_date', COUNT(*) FROM raw_dim_date
UNION ALL SELECT 'raw_dim_developer', COUNT(*) FROM raw_dim_developer
UNION ALL SELECT 'raw_dim_interruption', COUNT(*) FROM raw_dim_interruption
UNION ALL SELECT 'raw_fact_developer_activity_log', COUNT(*) FROM raw_fact_developer_activity_log
UNION ALL SELECT 'raw_fact_flow_daily', COUNT(*) FROM raw_fact_flow_daily;

-- NULL / blank check (example: dim_developer — repeat pattern for other tables)
SELECT
    SUM(developer_id   IS NULL OR TRIM(developer_id)   = '') AS null_developer_id,
    SUM(developer_name IS NULL OR TRIM(developer_name) = '') AS null_developer_name,
    SUM(team_name      IS NULL OR TRIM(team_name)      = '') AS null_team_name,
    SUM(seniority_level IS NULL OR TRIM(seniority_level) = '') AS null_seniority,
    SUM(primary_ide    IS NULL OR TRIM(primary_ide)    = '') AS null_ide,
    SUM(timezone       IS NULL OR TRIM(timezone)       = '') AS null_timezone
FROM raw_dim_developer;

-- Duplicate business key
SELECT developer_id, COUNT(*) AS times_seen
FROM raw_dim_developer
GROUP BY developer_id
HAVING COUNT(*) > 1;

-- Hidden whitespace
SELECT developer_id, developer_name
FROM raw_dim_developer
WHERE developer_name <> TRIM(developer_name);

-- Orphan foreign keys (fact rows pointing to a developer that doesn't exist)
SELECT COUNT(*) AS orphan_developer_rows
FROM raw_fact_developer_activity_log f
LEFT JOIN raw_dim_developer d ON f.developer_id = d.developer_id
WHERE d.developer_id IS NULL;

-- Business-rule violations
SELECT COUNT(*) AS bad_timestamp_order
FROM raw_fact_developer_activity_log
WHERE STR_TO_DATE(timestamp_end, '%Y-%m-%d %H:%i:%s') <= STR_TO_DATE(timestamp_start, '%Y-%m-%d %H:%i:%s');

SELECT COUNT(*) AS pct_out_of_range
FROM raw_fact_flow_daily
WHERE CAST(flow_efficiency_pct AS DECIMAL(6,2)) < 0
   OR CAST(flow_efficiency_pct AS DECIMAL(6,2)) > 100;
   
   -- 2a. dim_activity_type
DROP TABLE IF EXISTS clean_dim_activity_type;
CREATE TABLE clean_dim_activity_type AS
SELECT activity_id, activity_name, cognitive_category, is_deep_work
FROM (
    SELECT
        CAST(activity_id AS UNSIGNED) AS activity_id,
        TRIM(activity_name) AS activity_name,
        TRIM(cognitive_category) AS cognitive_category,
        IF(LOWER(TRIM(is_deep_work)) IN ('true','1','yes'), 1, 0) AS is_deep_work,
        ROW_NUMBER() OVER (PARTITION BY activity_id ORDER BY row_id) AS rn
    FROM raw_dim_activity_type
) t
WHERE rn = 1;
ALTER TABLE clean_dim_activity_type ADD PRIMARY KEY (activity_id);
 -- 2b. dim_date
 DROP TABLE IF EXISTS clean_dim_date;
CREATE TABLE clean_dim_date AS
SELECT date_key, date, day_of_week, day_number_in_week, is_weekend,
       week_number, month_name, quarter, year, sprint_name
FROM (
    SELECT
        CAST(date_key AS UNSIGNED) AS date_key,
        STR_TO_DATE(date, '%Y-%m-%d')  AS date,
        TRIM(day_of_week) AS day_of_week,
        CAST(day_number_in_week AS UNSIGNED)  AS day_number_in_week,
        IF(LOWER(TRIM(is_weekend)) IN ('true','1','yes'), 1, 0) AS is_weekend,
        CAST(week_number AS UNSIGNED) AS week_number,
        TRIM(month_name) AS month_name,
        TRIM(quarter)  AS quarter,
        CAST(year AS UNSIGNED)  AS year,
        TRIM(sprint_name) AS sprint_name,
        ROW_NUMBER() OVER (PARTITION BY date_key ORDER BY row_id) AS rn
    FROM raw_dim_date
) t
WHERE rn = 1;
ALTER TABLE clean_dim_date ADD PRIMARY KEY (date_key);

-- 2c. dim_developer
DROP TABLE IF EXISTS clean_dim_developer;
CREATE TABLE clean_dim_developer AS
SELECT developer_id, developer_name, team_name, seniority_level, primary_ide, timezone
FROM (
    SELECT
        CAST(developer_id AS UNSIGNED) AS developer_id,
        TRIM(developer_name) AS developer_name,
        TRIM(team_name) AS team_name,
        TRIM(seniority_level) AS seniority_level,
        TRIM(primary_ide) AS primary_ide,
        TRIM(timezone)  AS timezone,
        ROW_NUMBER() OVER (PARTITION BY developer_id ORDER BY row_id) AS rn
    FROM raw_dim_developer
) t
WHERE rn = 1;
ALTER TABLE clean_dim_developer ADD PRIMARY KEY (developer_id);

-- 2d. dim_interruption
-- Note: interruption_id = 0 ("None") legitimately has NULL category/urgency —
-- that's real data (no interruption happened), so we keep the NULL as-is.
DROP TABLE IF EXISTS clean_dim_interruption;
CREATE TABLE clean_dim_interruption AS
SELECT interruption_id, source_channel, interruption_category, urgency_tier,
       requires_action, avg_recovery_latency_min
FROM (
    SELECT
        CAST(interruption_id AS UNSIGNED)  AS interruption_id,
        TRIM(source_channel) AS source_channel,
        NULLIF(TRIM(interruption_category), '') AS interruption_category,
        NULLIF(TRIM(urgency_tier), '')  AS urgency_tier,
        IF(LOWER(TRIM(requires_action)) IN ('true','1','yes'), 1, 0) AS requires_action,
        CAST(avg_recovery_latency_min AS DECIMAL(6,2))  AS avg_recovery_latency_min,
        ROW_NUMBER() OVER (PARTITION BY interruption_id ORDER BY row_id) AS rn
    FROM raw_dim_interruption
) t
WHERE rn = 1;
ALTER TABLE clean_dim_interruption ADD PRIMARY KEY (interruption_id);

-- 2e. fact_developer_activity_log (largest table — dedupe, cast, then
-- drop rows with orphan FKs or impossible timestamps into a rejects table)
DROP TABLE IF EXISTS stg_fact_activity_log;
CREATE TABLE stg_fact_activity_log AS
SELECT log_id, developer_id, date_key, timestamp_start, timestamp_end, activity_id,
       interruption_id, session_duration_minutes, in_flow_state, context_switch_flag,
       cognitive_recovery_minutes
FROM (
    SELECT
        CAST(log_id AS UNSIGNED) AS log_id,
        CAST(developer_id AS UNSIGNED) AS developer_id,
        CAST(date_key AS UNSIGNED) AS date_key,
        STR_TO_DATE(timestamp_start, '%Y-%m-%d %H:%i:%s') AS timestamp_start,
        STR_TO_DATE(timestamp_end, '%Y-%m-%d %H:%i:%s') AS timestamp_end,
        CAST(activity_id AS UNSIGNED) AS activity_id,
        CAST(interruption_id AS UNSIGNED) AS interruption_id,
        CAST(session_duration_minutes AS SIGNED) AS session_duration_minutes,
        IF(LOWER(TRIM(in_flow_state)) IN ('true','1','yes'), 1, 0)                       AS in_flow_state,
        CAST(context_switch_flag AS UNSIGNED)                                             AS context_switch_flag,
        CAST(cognitive_recovery_minutes AS DECIMAL(8,2))                                    AS cognitive_recovery_minutes,
        ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY row_id)                              AS rn
    FROM raw_fact_developer_activity_log
) t
WHERE rn = 1;
DROP TABLE IF EXISTS clean_fact_developer_activity_log;
CREATE TABLE clean_fact_developer_activity_log AS
SELECT s.*
FROM stg_fact_activity_log s
INNER JOIN clean_dim_developer      d  ON s.developer_id    = d.developer_id
INNER JOIN clean_dim_date           dt ON s.date_key        = dt.date_key
INNER JOIN clean_dim_activity_type  a  ON s.activity_id      = a.activity_id
INNER JOIN clean_dim_interruption   i  ON s.interruption_id  = i.interruption_id
WHERE s.timestamp_end > s.timestamp_start
  AND s.session_duration_minutes > 0;
ALTER TABLE clean_fact_developer_activity_log ADD PRIMARY KEY (log_id);
 
DROP TABLE IF EXISTS rejected_fact_developer_activity_log;
CREATE TABLE rejected_fact_developer_activity_log AS
SELECT s.*, 'orphan_fk_or_bad_business_rule' AS reject_reason
FROM stg_fact_activity_log s
WHERE s.log_id NOT IN (SELECT log_id FROM clean_fact_developer_activity_log);

-- 2f. fact_flow_daily
DROP TABLE IF EXISTS stg_fact_flow_daily;
CREATE TABLE stg_fact_flow_daily AS
SELECT developer_id, date_key, total_tracked_minutes, deep_work_minutes, pure_flow_minutes,
       total_interruptions, ci_cd_interruptions, total_cognitive_tax_minutes,
       flow_efficiency_pct, cognitive_friction_score
FROM (
    SELECT
        CAST(developer_id AS UNSIGNED) AS developer_id,
        CAST(date_key AS UNSIGNED) AS date_key,
        CAST(total_tracked_minutes AS UNSIGNED) AS total_tracked_minutes,
        CAST(deep_work_minutes AS UNSIGNED) AS deep_work_minutes,
        CAST(pure_flow_minutes AS UNSIGNED) AS pure_flow_minutes,
        CAST(total_interruptions AS UNSIGNED)  AS total_interruptions,
        CAST(ci_cd_interruptions AS UNSIGNED)                                            AS ci_cd_interruptions,
        ROUND(CAST(total_cognitive_tax_minutes AS DECIMAL(8,2)), 2)                       AS total_cognitive_tax_minutes,
        ROUND(CAST(flow_efficiency_pct AS DECIMAL(6,2)), 2)                                 AS flow_efficiency_pct,
        ROUND(CAST(cognitive_friction_score AS DECIMAL(6,2)), 2)                             AS cognitive_friction_score,
        ROW_NUMBER() OVER (PARTITION BY developer_id, date_key ORDER BY row_id)               AS rn
    FROM raw_fact_flow_daily
) t
WHERE rn = 1;
 
DROP TABLE IF EXISTS clean_fact_flow_daily;
CREATE TABLE clean_fact_flow_daily AS
SELECT s.*
FROM stg_fact_flow_daily s
INNER JOIN clean_dim_developer d  ON s.developer_id = d.developer_id
INNER JOIN clean_dim_date      dt ON s.date_key      = dt.date_key
WHERE s.flow_efficiency_pct BETWEEN 0 AND 100
  AND s.deep_work_minutes  <= s.total_tracked_minutes
  AND s.pure_flow_minutes  <= s.total_tracked_minutes;
ALTER TABLE clean_fact_flow_daily ADD PRIMARY KEY (developer_id, date_key);
 
DROP TABLE IF EXISTS rejected_fact_flow_daily;
CREATE TABLE rejected_fact_flow_daily AS
SELECT s.*, 'orphan_fk_or_bad_business_rule' AS reject_reason
FROM stg_fact_flow_daily s
LEFT JOIN clean_fact_flow_daily c
  ON s.developer_id = c.developer_id AND s.date_key = c.date_key
WHERE c.developer_id IS NULL;
 
DROP TABLE IF EXISTS stg_fact_activity_log;
DROP TABLE IF EXISTS stg_fact_flow_daily;
-- DATA VALIDATE
SELECT 'dim_activity_type' AS table_name,
       (SELECT COUNT(*) FROM raw_dim_activity_type)   AS raw_rows,
       (SELECT COUNT(*) FROM clean_dim_activity_type) AS clean_rows
UNION ALL
SELECT 'dim_date', (SELECT COUNT(*) FROM raw_dim_date), (SELECT COUNT(*) FROM clean_dim_date)
UNION ALL
SELECT 'dim_developer', (SELECT COUNT(*) FROM raw_dim_developer), (SELECT COUNT(*) FROM clean_dim_developer)
UNION ALL
SELECT 'dim_interruption', (SELECT COUNT(*) FROM raw_dim_interruption), (SELECT COUNT(*) FROM clean_dim_interruption)
UNION ALL
SELECT 'fact_developer_activity_log',
       (SELECT COUNT(*) FROM raw_fact_developer_activity_log),
       (SELECT COUNT(*) FROM clean_fact_developer_activity_log)
UNION ALL
SELECT 'fact_flow_daily', (SELECT COUNT(*) FROM raw_fact_flow_daily), (SELECT COUNT(*) FROM clean_fact_flow_daily);
 
 -- Should return 0 rows each:
SELECT developer_id, COUNT(*) FROM clean_dim_developer GROUP BY developer_id HAVING COUNT(*) > 1;
SELECT log_id, COUNT(*) FROM clean_fact_developer_activity_log GROUP BY log_id HAVING COUNT(*) > 1;
 
SELECT COUNT(*) AS remaining_orphan_rows
FROM clean_fact_developer_activity_log f
LEFT JOIN clean_dim_developer d ON f.developer_id = d.developer_id
WHERE d.developer_id IS NULL;
 
SELECT COUNT(*) AS remaining_bad_timestamps
FROM clean_fact_developer_activity_log
WHERE timestamp_end <= timestamp_start;
 
SELECT COUNT(*) AS remaining_pct_out_of_range
FROM clean_fact_flow_daily
WHERE flow_efficiency_pct < 0 OR flow_efficiency_pct > 100;
 
SELECT reject_reason, COUNT(*) FROM rejected_fact_developer_activity_log GROUP BY reject_reason;
SELECT reject_reason, COUNT(*) FROM rejected_fact_flow_daily GROUP BY reject_reason;
