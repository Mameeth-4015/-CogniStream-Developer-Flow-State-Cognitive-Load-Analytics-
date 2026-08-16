<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=220&section=header&text=CogniStream%20Squad&fontSize=42&fontColor=ffffff&fontAlignY=38&desc=Engineering%20Productivity%20Analytics%20Team&descSize=16&descAlignY=62" width="100%"/>
</div>

<h3 align="center">
  ⚡ <em>The Brilliant Minds Powering CogniStream</em>
</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Team-Core%20Contributors-success?style=for-the-badge&logo=git&logoColor=white"/>
  <img src="https://img.shields.io/badge/Project-CogniStream-blue?style=for-the-badge&logo=powerbi&logoColor=white"/>
</p>

---

<div align="center">

  ### 👥 Team Members

  | Name | Role / Focus |
  | :---: | :---: |
  | **Mameeth C** | 👑 Project Lead & Data Architecture |
  | **Aparna C** | 💻 ETL Pipeline & SQL Cleansing |
  | **Malavika Nair** | 📊 DAX Analytics & Metric Modeling |
  | **Lucky Aswal** | 🎨 Dashboard UX/UI & BI Lead |

</div>

  <p>⭐ Built with precision by Team CogniStream ⭐</p>
</div>

<h3 align="center">
  🚀 <em>Phase 1 Status Report: Foundation, SQL Staging & Star Schema Scaffolding</em>
</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Week-1%20Complete-success?style=for-the-badge&logo=git&logoColor=white"/>
  <img src="https://img.shields.io/badge/Status-Green%20(On%20Schedule)-blue?style=for-the-badge&logo=statuspage&logoColor=white"/>
  <img src="https://img.shields.io/badge/Records%20Staged-168k%2B%20Rows-orange?style=for-the-badge&logo=databricks&logoColor=white"/>
</p>

---

## 📅 Week 1 Overview & Objectives

During **Week 1**, the foundation for the **CogniStream** developer telemetry pipeline was established. We successfully ingested raw event logs, created unconstrained staging tables, completed exploratory profiling to identify data anomalies, and initialized our dimensional modeling and Power BI scaffolding.

| Milestone / Focus Area | Status | Key Artifact / Action |
| :--- | :---: | :--- |
| **Raw Data Ingestion** | 🟢 Complete | Created unconstrained `stg_` tables for 158k+ activity logs & 150 developer profiles. |
| **Data Profiling & Audit** | 🟢 Complete | Identified timeline inversions, duration outliers, and missing interruption foreign keys. |
| **Star Schema Architecture** | 🟢 Complete | Designed a two-tier fact model linking 2 facts to 4 dimensions. |
| **Power BI Initialization** | 🟢 Complete | Configured workspace theme, report structure, and single-direction $1:*$ relationships. |

---

## 🏗️ 1. SQL Staging & Data Ingestion Setup

To prevent schema lockouts and import crashes during ingestion, raw CSV telemetry files were loaded into unconstrained staging tables:

```sql
-- 1. Staging Table: Granular Activity Logs (158,152 raw rows)
CREATE TABLE stg_developer_activity_log (
    log_id TEXT,
    developer_id TEXT,
    date_key TEXT,
    timestamp_start TEXT,
    timestamp_end TEXT,
    activity_id TEXT,
    interruption_id TEXT,
    session_duration_minutes TEXT,
    in_flow_state TEXT,
    context_switch_flag TEXT,
    cognitive_recovery_minutes TEXT
);

-- 2. Staging Table: Developer Profiles (150 developer records)
CREATE TABLE stg_developer (
    developer_id TEXT,
    developer_name TEXT,
    team_name TEXT,
    seniority_level TEXT,
    primary_ide TEXT,
    timezone TEXT
);
🔍 2. Data Profiling & Audit Insights
We executed exploratory audit queries to uncover data hygiene issues before production transformation:

SQL
-- Auditing missing IDs, invalid timestamps, and duration extremes
SELECT 
    COUNT(*) AS total_raw_rows,
    SUM(CASE WHEN developer_id IS NULL OR TRIM(developer_id) = '' THEN 1 ELSE 0 END) AS missing_dev_ids,
    SUM(CASE WHEN timestamp_start IS NULL OR TRIM(timestamp_start) = '' THEN 1 ELSE 0 END) AS missing_timestamps,
    SUM(CASE WHEN session_duration_minutes::NUMERIC < 0 THEN 1 ELSE 0 END) AS negative_durations,
    SUM(CASE WHEN session_duration_minutes::NUMERIC > 480 THEN 1 ELSE 0 END) AS excessive_durations
FROM stg_developer_activity_log;
🚨 Key Audit Findings & Remediation Plan:
Timestamp Sequence Inversion: Found records where timestamp_end < timestamp_start.

Remediation: Added SQL filter WHERE timestamp_end >= timestamp_start.

Overlapping Telemetry Duplicates: Polling overlaps caused duplicate session rows.

Remediation: Enforced deduplication using ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp_start).

Missing Interruption Codes: Null/empty interruption_id fields.

Remediation: Used COALESCE(NULLIF(TRIM(interruption_id), ''), '0')::INT to map all nulls to key 0 (Continuous Focus / No Interruption).

📐 3. Star Schema Architecture Design
+-------------------+
                  |   dim_developer   |
                  +---------+---------+
                            |
  +------------------+      | 1:N     +-------------------+
  |     dim_date     +------|-------->+   fact_flow_daily  |
  +--------+---------+      |         +-------------------+
           |                |                   ^
           | 1:N            | 1:N               | 1:N
           v                v                   |
  +--------+----------------+---------+         |
  |     fact_developer_activity_log    +---------+
  +--------+----------------+---------+
           ^                ^
           | 1:N            | 1:N
  +--------+---------+   +--+-----------------+
  | dim_activity_type|   |   dim_interruption  |
  +------------------+   +--------------------+

🎯Week 2 Action PlanExecute Production Cleansing:
# Run final SQL transformation scripts to generate fact_developer_activity_log_clean and dim_developer_clean.
# Referential Integrity Enforcement: Prune orphan foreign keys and create primary/foreign key constraints.
# DAX Implementation: Build core business measures (Pure Flow Hours, Cognitive Recovery Tax, Context-Switching Tax %).
# Visual Prototyping: Build top-level Executive KPI cards and preliminary team comparison charts in Power BI[cite: 2].
