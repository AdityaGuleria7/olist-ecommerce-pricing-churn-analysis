# Olist E-Commerce: Pricing & Churn Intelligence

![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)
![BigQuery](https://img.shields.io/badge/BigQuery-SQL-orange?logo=google-cloud)
![Tableau](https://img.shields.io/badge/Tableau-Public-lightblue?logo=tableau)
![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-green?logo=scikit-learn)
![Prophet](https://img.shields.io/badge/Prophet-Forecasting-purple)
![LLM API](https://img.shields.io/badge/Groq_API-LLaMA_3.3-red)

## Business Question

> **Why are customers churning, and are we pricing our top categories correctly?**

End-to-end analytics project analysing **96,478 delivered orders** from the [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Sept 2016 – Aug 2018) across the full modern data stack: SQL → Python → AI API → Tableau → Google Sheets.

---

## Key Findings

| Finding | Detail |
|---|---|
| 🚨 **Top churn driver** | Freight cost (feature importance: 0.656) — more predictive than review score |
| 💰 **At-Risk revenue** | R$4.86M sitting in customers inactive 398+ days |
| ⭐ **Champions** | 4% of customers, avg R$466 spend, last active 50 days ago |
| 📦 **Pricing issue** | `furniture_decor` — premium priced (R$246 avg) with only 3.9★ reviews |
| 📈 **Revenue growth** | 3x from Dec 2016 to Aug 2018, Black Friday Nov 2017 = R$58K peak day |
| 🤖 **Churn model** | Random Forest ROC-AUC: **0.758** (clean — no data leakage) |

---

## Project Architecture

```
Raw Data (Kaggle CSVs)
        │
        ▼
┌─────────────────────┐
│   BigQuery (SQL)    │  9 tables joined → vw_orders_master
│   6 SQL scripts     │  RFM · Pricing · Churn · Cohort · Revenue
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│  Python (Colab)     │  EDA → Churn Model → Price Elasticity → Forecast
│  scikit-learn       │  Logistic Regression vs Random Forest
│  Prophet            │  90-day revenue forecast with seasonality
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│   Groq API          │  LLaMA 3.3 70B → auto-generates executive
│   (LLaMA 3.3)       │  summaries from RFM + pricing + churn outputs
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│  Tableau Public     │  3 dashboards: Customer Intelligence,
│                     │  Pricing Intelligence, Revenue Forecast
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│  Google Sheets      │  4-tab stakeholder tracker: KPI summary,
│                     │  RFM data, pricing flags, scenario modeller
└─────────────────────┘
```

---

## Tools & Technologies

| Layer | Tools |
|---|---|
| Data Warehouse | Google BigQuery (9-table join, window functions, CTEs) |
| Analysis | Python — Pandas, NumPy, Matplotlib, Scipy |
| Machine Learning | Scikit-learn — Logistic Regression, Random Forest |
| Forecasting | Facebook Prophet (yearly + weekly seasonality) |
| AI Integration | Groq API — LLaMA 3.3 70B (executive summary generation) |
| Visualisation | Tableau Public (3 interactive dashboards) |
| Reporting | Google Sheets (KPI tracker + scenario modeller) |
| Version Control | GitHub |

---

## Results

### Churn Model Performance

| Model | ROC-AUC | Notes |
|---|---|---|
| Logistic Regression | 0.565 | Linear baseline |
| **Random Forest** | **0.758** | **Best model — selected** |

**Important:** An earlier version of this model achieved ROC-AUC of 1.000 — immediately identified as data leakage (`days_inactive` directly encoding the churn label). The final model uses **pure behavioural features only** with zero time-derived fields. See `notebooks/olist_pricing_churn_analysis.ipynb` Section 3 for the full leakage detection walkthrough.

### Top Churn Predictors (Random Forest Feature Importance)

| Feature | Importance | Business Meaning |
|---|---|---|
| avg_freight | 0.656 | Shipping cost burden |
| avg_delay | 0.116 | Delivery performance |
| freight_to_price_ratio | 0.065 | Perceived value for money |
| is_sp | 0.065 | São Paulo customers churn less |
| total_spend | 0.041 | Order value signal |

### RFM Segmentation

| Segment | Customers | Avg Revenue | Total Revenue | Action |
|---|---|---|---|---|
| Champions | 3,826 (4%) | R$466 | R$1.78M | Retain — VIP treatment |
| At-Risk | 15,154 (16%) | R$321 | R$4.86M | 🚨 Win-back campaign |
| Loyal Customers | 11,972 (12%) | R$262 | R$3.13M | Upsell opportunities |
| Needs Attention | 38,250 (40%) | R$123 | R$4.70M | Re-engagement |
| Recent Customers | 11,428 (12%) | R$73 | R$0.83M | Nurture to repeat |
| Lost | 15,848 (16%) | R$56 | R$0.88M | Low priority |

### Revenue Forecast (Prophet)

- **Avg daily revenue:** ~R$27,000
- **Black Friday peak:** ~R$58K (Nov 24, 2017)
- **90-day projected total:** ~R$2.4M
- **Seasonality:** November spike, January dip, Mon–Tue weekly peak

---

## Project Links

| Resource | Link |
|---|---|
| 📊 Tableau Dashboard | [View on Tableau Public](https://public.tableau.com/app/profile/aditya.guleria7085/viz/OlistBrazilianE-CommerceAnalysis_17828384122880/PricingIntelligence) |
| 📓 Kaggle Notebook | [Notebook link](https://www.kaggle.com/code/adityafx7/olist-e-commerce-end-to-end-analytics) |
| 📋 Google Sheets KPI Tracker | [Spreadsheet link](https://docs.google.com/spreadsheets/d/1umnHgzXAKBrNLNqh7wnHNRFFRkVdEFCjXMxnnbiXb98/edit?usp=sharing) |
| 📦 Dataset | [Olist Brazilian E-Commerce (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |

---

## Repository Structure

```
olist-ecommerce-pricing-churn-analysis/
├── README.md
├── sql/
│   ├── 01_schema_verification.sql
│   ├── 02_rfm_segmentation.sql
│   ├── 03_pricing_analysis.sql
│   ├── 04_churn_signals.sql
│   ├── 05_cohort_retention.sql
│   └── 06_revenue_breakdown.sql
├── notebooks/
│   └── olist_pricing_churn_analysis.ipynb
├── scripts/
│   └── ai_narrator.py
├── data/
│   └── README.md
└── outputs/
    ├── ai_rfm_summary.txt
    ├── ai_pricing_alerts.txt
    └── ai_churn_insights.txt
```

---

## How to Run

### Prerequisites
```bash
pip install pandas numpy matplotlib seaborn scikit-learn prophet groq google-cloud-bigquery
```

### 1. BigQuery Setup
- Create a Google Cloud project
- Upload the 9 Olist CSVs to BigQuery
- Run SQL scripts in `/sql/` in order (01 → 06)
- The master view `vw_orders_master` is created by script 01

### 2. Python Analysis
- Open `notebooks/olist_pricing_churn_analysis.ipynb` in Kaggle or Colab
- If using Colab: authenticate with your Google account for BigQuery access
- If using Kaggle: attach the Olist dataset — it loads via `kagglehub`
- Run all cells top to bottom

### 3. AI Narrative (optional)
- Get a free API key from [console.groq.com](https://console.groq.com)
- **Never hardcode the key** — use environment variables or Kaggle Secrets
- Run `scripts/ai_narrator.py` with `GROQ_API_KEY` set

### 4. Tableau Dashboard
- Open `Olist_Analysis.twb` in Tableau Public Desktop
- Reconnect data sources to your local CSV exports from BigQuery
- Publish to Tableau Public

---

## Dataset Notes

**Important structural limitation:** Olist anonymises `customer_id` per order — each customer_id maps to exactly one transaction. This means:
- Traditional frequency analysis (repeat purchases) is not possible at the customer level
- Any time-derived feature (`purchase_year`, `purchase_month`, `days_inactive`) directly encodes the churn label — causing data leakage
- The churn rate of 60% in this analysis is lower than the true churn rate because single-order customers with recent purchases appear "active"

This limitation is documented throughout the notebook and is itself a key analytical finding.

---

## About

Built by **Aditya Guleria** — Data Analyst specialising in e-commerce analytics and predictive modelling.

- 📍 Bangalore, India
- 🎓 B.Tech Computer Science, Jaypee University of Information Technology (2025)
- 💼 Targeting: Data Analyst · Growth Analyst · Pricing Analyst roles

