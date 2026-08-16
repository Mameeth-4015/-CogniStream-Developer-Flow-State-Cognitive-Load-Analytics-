<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=220&section=header&text=CogniStream&fontSize=50&fontColor=ffffff&fontAlignY=38&desc=Developer%20Flow-State%20&%20Cognitive%20Load%20Analytics&descSize=18&descAlignY=62" width="100%"/>
</div>

<h3 align="center">
  🚀 <em>Measure Focus, Not Just Commits. Transform Engineering Experience with Telemetry-Driven Analytics.</em>
</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge&logo=git&logoColor=white"/>
  <img src="https://img.shields.io/badge/Database-SQL%20(%20PostgreSQL%20)-blue?style=for-the-badge&logo=postgresql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Visualization-Power%20BI-yellow?style=for-the-badge&logo=powerbi&logoColor=white"/>
  <img src="https://img.shields.io/badge/Telemetry-158k%2B%20Events-orange?style=for-the-badge&logo=databricks&logoColor=white"/>
</p>

---

## ⚡ 1. The Core Problem & Business Use Case

Traditional engineering productivity metrics like **"lines of code written"** or **"tickets closed"** are fundamentally flawed. They measure raw output volume while completely ignoring the **friction of the development workflow**[cite: 1].

> **The CogniStream Scenario:** An Engineering Manager reviews the dashboard. Instead of checking how many commits Team A pushed, they inspect a **"Context-Switching Tax"** analysis[cite: 1]. The telemetry proves that Team A loses **40% of their peak cognitive flow state** due to poorly timed, automated CI/CD Slack alerts interrupting their IDE sessions—empowering leadership to adjust notification policies and reclaim developer focus[cite: 1].

---

## 🏗️ 2. Enterprise Star Schema Architecture

CogniStream relies on an optimized **Star Schema** partitioned into a two-tier fact structure for deep root-cause diagnostic queries and rapid executive rollup reporting[cite: 1]:

```text
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
