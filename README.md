<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=220&section=header&text=CogniStream%20Squad&fontSize=42&fontColor=ffffff&fontAlignY=38&desc=Engineering%20Productivity%20Analytics%20Team&descSize=16&descAlignY=62" width="100%"/>
</div>

<h3 align="center">
  ⚡ <em>The Brilliant Minds Powering CogniStream</em>
</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Team-Core%20Contributors-success?style=for-the-badge&logo=git&logoColor=white"/>
  <img src="https://img.shields.io/badge/Project-CogniStream-blue?style=for-the-badge&logo=tableau&logoColor=white"/>
</p>

---

<div align="center">

  ### 👥 Team Members

  | Name | Role / Focus |
  | :---: | :---: |
  | **Mameeth C** | 👑 Project Lead & Data Architecture |
  | **Aparna C** | 💻 ETL Pipeline & SQL Cleansing |
  | **Malavika Nair** | 📊 Calculated Fields & Metric Modeling |
  | **Lucky Aswal** | 🎨 Dashboard UX/UI & Tableau Lead |

</div>

  <p>⭐ Built with precision by Team CogniStream ⭐</p>
</div>

<h3 align="center">
  🚀 <em>End-to-End Project Report: Weeks 1 to 4 Complete Lifecycle</em>
</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Project-Complete-success?style=for-the-badge&logo=git&logoColor=white"/>
  <img src="https://img.shields.io/badge/Status-Green%20(Delivered)-blue?style=for-the-badge&logo=statuspage&logoColor=white"/>
  <img src="https://img.shields.io/badge/Viz-Tableau-orange?style=for-the-badge&logo=tableau&logoColor=white"/>
</p>

---

## 📅 Project Overview & 4-Week Roadmap

**CogniStream** is an engineering telemetry and productivity analytics platform designed to analyze developer workflow patterns, flow states, context-switching taxes, and cognitive recovery times. This document outlines the end-to-end execution across four sequential project phases utilizing SQL data staging, rigorous data cleansing, and Tableau data visualization.

| Phase / Timeline | Focus Area | Status | Key Deliverable |
| :--- | :--- | :---: | :--- |
| **Week 1** | Ingestion & Schema Design | 🟢 Complete | Raw CSV ingestion, unconstrained staging tables, and star schema architecture. |
| **Week 2** | Production SQL Cleansing | 🟢 Complete | Automated data cleansing, constraint enforcement, and clean production tables. |
| **Week 3** | Tableau Metric Modeling | 🟢 Complete | Calculated fields, parameter controls, and advanced analytical calculations. |
| **Week 4** | Dashboard UX & Deployment | 🟢 Complete | Executive UI design, interactive storyboards, UAT, and final handover. |

---

## 🏗️ Phase 1: Ingestion & Star Schema Scaffolding

Raw telemetry logs and developer profile CSVs were ingested into an unconstrained SQL database to prevent import bottlenecks.

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

Data Profiling Audits: Initial exploratory queries detected timeline inversions (timestamp_end < timestamp_start), polling duplicates, and null interruption codes.

Star Schema Design: Structured a dimensional model linking granular fact tables (fact_developer_activity_log) to descriptive dimensions (dim_developer, dim_activity_type, dim_interruption, dim_date).

🧹 Phase 2: Production SQL Cleansing & Transformation
Production-grade SQL scripts were executed to clean anomalies, deduplicate polling entries, and establish strict referential integrity.

SQL

-- Production Clean Table Generation with Constraints
CREATE TABLE fact_developer_activity_log_clean AS
WITH deduplicated_logs AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp_start) AS rn
    FROM stg_developer_activity_log
    WHERE timestamp_start IS NOT NULL 
      AND timestamp_end IS NOT NULL
      AND timestamp_end >= timestamp_start
      AND session_duration_minutes::NUMERIC >= 0
      AND session_duration_minutes::NUMERIC <= 480
)
SELECT 
    log_id,
    developer_id,
    date_key,
    timestamp_start::TIMESTAMP AS timestamp_start,
    timestamp_end::TIMESTAMP AS timestamp_end,
    activity_id,
    COALESCE(NULLIF(TRIM(interruption_id), ''), '0')::INT AS interruption_id,
    session_duration_minutes::NUMERIC AS session_duration_minutes,
    in_flow_state::INT AS in_flow_state,
    context_switch_flag::INT AS context_switch_flag,
    cognitive_recovery_minutes::NUMERIC AS cognitive_recovery_minutes
FROM deduplicated_logs
WHERE rn = 1;

Orphan Pruning: Foreign keys pointing to inactive or deleted developer profiles were removed.

Type Casting: Converted unstructured text metrics into strict numeric and timestamp formats ready for Tableau connection.

// 1. Pure Flow Hours: Total hours spent specifically in an uninterrupted flow state
SUM(IF [In Flow State] = 1 THEN [Session Duration Minutes] END) / 60

// 2. Cognitive Recovery Tax (Hrs): Total hours lost due to post-interruption recovery phases
SUM([Cognitive Recovery Minutes]) / 60

// 3. Context-Switching Tax %: Proportion of work time consumed by context fragmentation
SUM(IF [Context Switch Flag] = 1 THEN [Session Duration Minutes] END) 
/ 
SUM([Session Duration Minutes])

Level of Detail (LOD) Expressions: Fixed LOD calculations were implemented to track individual developer baseline outputs against squad averages independent of filter context.

Parameters & Sets: Built interactive parameters allowing engineering leads to toggle dynamic threshold filtering for excessive session lengths and recovery time limits.

🎨 Phase 4: Executive Tableau Dashboard UX & Deployment
The final reporting interface was structured into a clean, high-impact multi-tab workbook optimized for engineering leadership and team managers:

Executive Summary Dashboard: High-level KPI cards displaying Total Active Devs, Average Flow State Ratio, and Total Cognitive Recovery Tax across squads.

Developer Deep-Dive View: Granular scatter plots mapping primary IDE performance against interruption frequencies and recovery overhead.

Team Comparison Matrix: Comparative bar charts tracking output velocity and context-switching rates week-over-week.

Deployment & Handover: Published data sources and workbooks to Tableau Cloud, establishing automated daily extract refreshes and workbook permissions.




No file chosenNo file chosenNo file chosen

Chat with ChatGPT
Ask ChatGPT




Log in
You said:

Phase / Timeline	Focus Area	Status	Key Deliverable
Week 1	Ingestion & Schema Design	🟢 Complete	Raw CSV ingestion, unconstrained staging tables, and star schema architecture.
Week 2	Production SQL Cleansing	🟢 Complete	Automated data cleansing, constraint enforcement, and clean production tables.
Week 3	Tableau Metric Modeling	🟢 Complete	Calculated fields, parameter controls, and advanced analytical calculations.
Week 4	Dashboard UX & Deployment	🟢 Complete	Executive UI design, interactive storyboards, UAT, and final handover.


Give more point advanced readme file to post github

ChatGPT said:
Absolutely — for GitHub, you can make the README much more professional, technical, and portfolio-ready by adding architecture, data pipeline, SQL transformations, Tableau modeling, KPIs, testing, deployment, and future enhancements.

Here’s a complete advanced README you can use:

📊 End-to-End Data Analytics & Business Intelligence Project
🚀 Project Overview
This project demonstrates an end-to-end data analytics pipeline that transforms raw CSV data into production-ready analytical datasets and an interactive executive dashboard.

The solution covers the complete analytics lifecycle:

Raw Data → Data Ingestion → Staging → SQL Cleansing → Data Modeling → Metric Engineering → Tableau Visualization → UAT → Deployment

The primary objective is to build a scalable and reliable analytics solution that enables business users to monitor KPIs, identify trends, compare performance, and make data-driven decisions.

🏗️ Solution Architecture
                    ┌──────────────────┐
                    │   Raw CSV Files  │
                    └────────┬─────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │   Staging Layer     │
                  │  Raw / Unconstrained│
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │  SQL Data Cleansing │
                  │ • Null Handling     │
                  │ • Deduplication     │
                  │ • Type Conversion   │
                  │ • Validation        │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Production Tables   │
                  │   Star Schema       │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Metric / KPI Layer  │
                  │ Calculated Fields   │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │      Tableau        │
                  │ Dashboards & Stories│
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Executive Insights  │
                  │ & Decision Support  │
                  └─────────────────────┘

🎯 Business Objectives
The project was designed to:

Convert raw operational data into reliable analytical datasets.
Establish a structured and scalable star schema.
Automate data cleansing and validation using SQL.
Enforce data quality and business constraints.
Create reusable business metrics and KPIs.
Develop interactive Tableau dashboards for executive reporting.
Enable dynamic filtering and parameter-driven analysis.
Provide trend, comparison, and performance analysis.
Reduce manual reporting effort.
Establish a repeatable analytics workflow for future datasets.
🗓️ Project Implementation Roadmap
Phase	Timeline	Focus Area	Status	Key Deliverable
Week 1	Week 1	Ingestion & Schema Design	🟢 Complete	Raw CSV ingestion, staging tables, star schema architecture
Week 2	Week 2	Production SQL Cleansing	🟢 Complete	Automated cleansing, validation, constraints, production tables
Week 3	Week 3	Tableau Metric Modeling	🟢 Complete	Calculated fields, parameters, KPIs, analytical calculations
Week 4	Week 4	Dashboard UX & Deployment	🟢 Complete	Executive dashboards, storyboards, UAT, final deployment

📥 Phase 1 — Data Ingestion & Schema Design
Key Activities
Imported raw CSV datasets into the database environment.
Created unconstrained staging tables to preserve source data.
Performed initial data profiling.
Identified:
Missing values
Duplicate records
Invalid data types
Outliers
Inconsistent categorical values
Referential integrity issues
Designed the analytical data model.
Established fact and dimension table relationships.



No file chosenNo file chosenNo file chosen

Chat with ChatGPT
Ask ChatGPT




Log in
You said:

Phase / Timeline	Focus Area	Status	Key Deliverable
Week 1	Ingestion & Schema Design	🟢 Complete	Raw CSV ingestion, unconstrained staging tables, and star schema architecture.
Week 2	Production SQL Cleansing	🟢 Complete	Automated data cleansing, constraint enforcement, and clean production tables.
Week 3	Tableau Metric Modeling	🟢 Complete	Calculated fields, parameter controls, and advanced analytical calculations.
Week 4	Dashboard UX & Deployment	🟢 Complete	Executive UI design, interactive storyboards, UAT, and final handover.


Give more point advanced readme file to post github

ChatGPT said:
Absolutely — for GitHub, you can make the README much more professional, technical, and portfolio-ready by adding architecture, data pipeline, SQL transformations, Tableau modeling, KPIs, testing, deployment, and future enhancements.

Here’s a complete advanced README you can use:

📊 End-to-End Data Analytics & Business Intelligence Project
🚀 Project Overview
This project demonstrates an end-to-end data analytics pipeline that transforms raw CSV data into production-ready analytical datasets and an interactive executive dashboard.

The solution covers the complete analytics lifecycle:

Raw Data → Data Ingestion → Staging → SQL Cleansing → Data Modeling → Metric Engineering → Tableau Visualization → UAT → Deployment

The primary objective is to build a scalable and reliable analytics solution that enables business users to monitor KPIs, identify trends, compare performance, and make data-driven decisions.

🏗️ Solution Architecture
                    ┌──────────────────┐
                    │   Raw CSV Files  │
                    └────────┬─────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │   Staging Layer     │
                  │  Raw / Unconstrained│
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │  SQL Data Cleansing │
                  │ • Null Handling     │
                  │ • Deduplication     │
                  │ • Type Conversion   │
                  │ • Validation        │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Production Tables   │
                  │   Star Schema       │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Metric / KPI Layer  │
                  │ Calculated Fields   │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │      Tableau        │
                  │ Dashboards & Stories│
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Executive Insights  │
                  │ & Decision Support  │
                  └─────────────────────┘

🎯 Business Objectives
The project was designed to:

Convert raw operational data into reliable analytical datasets.
Establish a structured and scalable star schema.
Automate data cleansing and validation using SQL.
Enforce data quality and business constraints.
Create reusable business metrics and KPIs.
Develop interactive Tableau dashboards for executive reporting.
Enable dynamic filtering and parameter-driven analysis.
Provide trend, comparison, and performance analysis.
Reduce manual reporting effort.
Establish a repeatable analytics workflow for future datasets.
🗓️ Project Implementation Roadmap
Phase	Timeline	Focus Area	Status	Key Deliverable
Week 1	Week 1	Ingestion & Schema Design	🟢 Complete	Raw CSV ingestion, staging tables, star schema architecture
Week 2	Week 2	Production SQL Cleansing	🟢 Complete	Automated cleansing, validation, constraints, production tables
Week 3	Week 3	Tableau Metric Modeling	🟢 Complete	Calculated fields, parameters, KPIs, analytical calculations
Week 4	Week 4	Dashboard UX & Deployment	🟢 Complete	Executive dashboards, storyboards, UAT, final deployment

📥 Phase 1 — Data Ingestion & Schema Design
Key Activities
Imported raw CSV datasets into the database environment.
Created unconstrained staging tables to preserve source data.
Performed initial data profiling.
Identified:
Missing values
Duplicate records
Invalid data types
Outliers
Inconsistent categorical values
Referential integrity issues
Designed the analytical data model.
Established fact and dimension table relationships.
Data Architecture
The project follows a Star Schema approach:

                   ┌───────────────┐
                   │ Date Dimension│
                   └───────┬───────┘
                           │
                           │
┌────────────────┐   ┌─────▼──────┐   ┌────────────────┐
│ Customer Dim   ├──►│ Fact Table │◄──┤ Product Dim    │
└────────────────┘   └─────┬──────┘   └────────────────┘
                           │
                           │
                    ┌──────▼───────┐
                    │ Region / Org │
                    │ Dimension    │
                    └──────────────┘

Benefits
Simplified analytical queries.
Improved Tableau performance.
Clear separation between facts and dimensions.
Easier KPI development.
Better scalability for future reporting requirements.
🧹 Phase 2 — Production SQL Cleansing
The staging layer was transformed into validated production datasets using SQL.

Data Quality Operations
Duplicate detection and removal.
NULL and missing-value handling.
Standardization of categorical attributes.
Date and timestamp normalization.
Numeric type conversion.
Invalid record identification.
Business-rule validation.
Referential integrity checks.
Primary-key validation.
Foreign-key validation.
Range and threshold validation.
Creation of derived analytical columns.

Raw Data
   ↓
Profile Data
   ↓
Identify Data Issues
   ↓
Apply Transformation Rules
   ↓
Validate Records
   ↓
Enforce Constraints
   ↓
Production Tables

1Production Layer Principles
The production layer was designed with:

Consistent naming conventions.
Explicit data types.
Primary keys.
Foreign keys.
NOT NULL constraints where applicable.
Business-rule validation.
Reusable transformation logic.
Separation between raw and curated datasets.

Log in
You said:

Phase / Timeline	Focus Area	Status	Key Deliverable
Week 1	Ingestion & Schema Design	🟢 Complete	Raw CSV ingestion, unconstrained staging tables, and star schema architecture.
Week 2	Production SQL Cleansing	🟢 Complete	Automated data cleansing, constraint enforcement, and clean production tables.
Week 3	Tableau Metric Modeling	🟢 Complete	Calculated fields, parameter controls, and advanced analytical calculations.
Week 4	Dashboard UX & Deployment	🟢 Complete	Executive UI design, interactive storyboards, UAT, and final handover.


Give more point advanced readme file to post github

ChatGPT said:
Absolutely — for GitHub, you can make the README much more professional, technical, and portfolio-ready by adding architecture, data pipeline, SQL transformations, Tableau modeling, KPIs, testing, deployment, and future enhancements.

Here’s a complete advanced README you can use:

📊 End-to-End Data Analytics & Business Intelligence Project
🚀 Project Overview
This project demonstrates an end-to-end data analytics pipeline that transforms raw CSV data into production-ready analytical datasets and an interactive executive dashboard.

The solution covers the complete analytics lifecycle:

Raw Data → Data Ingestion → Staging → SQL Cleansing → Data Modeling → Metric Engineering → Tableau Visualization → UAT → Deployment

The primary objective is to build a scalable and reliable analytics solution that enables business users to monitor KPIs, identify trends, compare performance, and make data-driven decisions.

🏗️ Solution Architecture
                    ┌──────────────────┐
                    │   Raw CSV Files  │
                    └────────┬─────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │   Staging Layer     │
                  │  Raw / Unconstrained│
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │  SQL Data Cleansing │
                  │ • Null Handling     │
                  │ • Deduplication     │
                  │ • Type Conversion   │
                  │ • Validation        │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Production Tables   │
                  │   Star Schema       │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Metric / KPI Layer  │
                  │ Calculated Fields   │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │      Tableau        │
                  │ Dashboards & Stories│
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Executive Insights  │
                  │ & Decision Support  │
                  └─────────────────────┘

🎯 Business Objectives
The project was designed to:

Convert raw operational data into reliable analytical datasets.
Establish a structured and scalable star schema.
Automate data cleansing and validation using SQL.
Enforce data quality and business constraints.
Create reusable business metrics and KPIs.
Develop interactive Tableau dashboards for executive reporting.
Enable dynamic filtering and parameter-driven analysis.
Provide trend, comparison, and performance analysis.
Reduce manual reporting effort.
Establish a repeatable analytics workflow for future datasets.
🗓️ Project Implementation Roadmap
Phase	Timeline	Focus Area	Status	Key Deliverable
Week 1	Week 1	Ingestion & Schema Design	🟢 Complete	Raw CSV ingestion, staging tables, star schema architecture
Week 2	Week 2	Production SQL Cleansing	🟢 Complete	Automated cleansing, validation, constraints, production tables
Week 3	Week 3	Tableau Metric Modeling	🟢 Complete	Calculated fields, parameters, KPIs, analytical calculations
Week 4	Week 4	Dashboard UX & Deployment	🟢 Complete	Executive dashboards, storyboards, UAT, final deployment

📥 Phase 1 — Data Ingestion & Schema Design
Key Activities
Imported raw CSV datasets into the database environment.
Created unconstrained staging tables to preserve source data.
Performed initial data profiling.
Identified:
Missing values
Duplicate records
Invalid data types
Outliers
Inconsistent categorical values
Referential integrity issues
Designed the analytical data model.
Established fact and dimension table relationships.
Data Architecture
The project follows a Star Schema approach:

                   ┌───────────────┐
                   │ Date Dimension│
                   └───────┬───────┘
                           │
                           │
┌────────────────┐   ┌─────▼──────┐   ┌────────────────┐
│ Customer Dim   ├──►│ Fact Table │◄──┤ Product Dim    │
└────────────────┘   └─────┬──────┘   └────────────────┘
                           │
                           │
                    ┌──────▼───────┐
                    │ Region / Org │
                    │ Dimension    │
                    └──────────────┘

Benefits
Simplified analytical queries.
Improved Tableau performance.
Clear separation between facts and dimensions.
Easier KPI development.
Better scalability for future reporting requirements.
🧹 Phase 2 — Production SQL Cleansing
The staging layer was transformed into validated production datasets using SQL.

Data Quality Operations
Duplicate detection and removal.
NULL and missing-value handling.
Standardization of categorical attributes.
Date and timestamp normalization.
Numeric type conversion.
Invalid record identification.
Business-rule validation.
Referential integrity checks.
Primary-key validation.
Foreign-key validation.
Range and threshold validation.
Creation of derived analytical columns.
Example Data Quality Flow
Raw Data
   ↓
Profile Data
   ↓
Identify Data Issues
   ↓
Apply Transformation Rules
   ↓
Validate Records
   ↓
Enforce Constraints
   ↓
Production Tables

Production Layer Principles
The production layer was designed with:

Consistent naming conventions.
Explicit data types.
Primary keys.
Foreign keys.
NOT NULL constraints where applicable.
Business-rule validation.
Reusable transformation logic.
Separation between raw and curated datasets.

📐 Phase 3 — Tableau Metric Modeling
The cleansed production data was connected to Tableau for analytical modeling.

Metric Engineering
Developed reusable calculated fields for:

Total Revenue
Total Cost
Profit
Profit Margin
Average Transaction Value
Growth %
Year-over-Year Growth
Month-over-Month Growth
Customer/Entity Counts
Contribution %
Running Totals
Rankings
Variance Analysis
Performance Indicators
Analytical Techniques
The dashboard incorporates advanced Tableau functionality including:

Calculated fields
Parameters
Table calculations
Level of Detail expressions
Conditional logic
Dynamic KPIs
Reference lines
Trend analysis
Ranking logic
Period-over-period comparisons
Interactive filters

🎛️ Dynamic Parameter Controls
Interactive parameters were implemented to allow users to change the analytical perspective without modifying the dashboard.

Metric Selector
      │
      ├── Revenue
      ├── Profit
      ├── Profit Margin
      ├── Transactions
      └── Average Value
