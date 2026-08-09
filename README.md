# 🧠 CogniStream

> **Developer Flow-State & Cognitive Load Analytics**  
> *Real-time telemetry, context-switch tracking, and mental bandwidth optimization for modern engineering teams.*

---

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![Node.js 18+](https://img.shields.io/badge/node-18+-green.svg)](https://nodejs.org/)

---

## 📌 Overview

**CogniStream** is an open-source Developer Experience (DevEx) telemetry engine that measures, visualizes, and protects developer flow-state. 

Rather than relying on vanity productivity metrics (like line counts or commit frequency), CogniStream tracks **cognitive friction, context-switching frequency, and deep-work duration** across IDEs, communication tools (Slack/Teams), git workflows, and system events.

By combining passive IDE telemetry with light friction modeling, CogniStream gives engineers actionable insights to defend focus time and helps team leads eliminate structural productivity bottlenecks.

---

## ✨ Key Features

* **⚡ Real-Time Flow-State Detection**
  * Tracks uninterrupted active coding intervals, focus density, and typing cadences to calculate live Flow Scores (0–100%).
* **🔄 Context-Switch & Friction Analytics**
  * Pinpoints high-friction events like rapid tab-swapping, notification fatigue, sudden meetings, and frequent AI-agent re-prompting/review cycles.
* **🛡️ Privacy-First Architecture**
  * All granular keystrokes, diffs, and window titles are processed locally via on-device differential privacy. Only aggregated, anonymized metrics leave your local machine.
* **💬 Slack & MS Teams Integration**
  * Automatically sets "In Flow" status on Slack/Teams and pauses non-urgent notifications when deep work thresholds are achieved.
* **📊 DevEx Dashboard & CLI**
  * Rich web dashboard built with Next.js/Tailwind for team trends, plus a fast Terminal UI (TUI) for individual developers.
* **🔌 IDE Plugins (VS Code & JetBrains)**
  * Lightweight extensions to track editor focus, debugging loops, and terminal usage without slowing down your workflow.

---

## 🏗️ Architecture
