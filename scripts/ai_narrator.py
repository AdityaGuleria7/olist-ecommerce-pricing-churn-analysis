# ============================================================
# ai_narrator.py
# Sends RFM, pricing, and churn outputs to Groq LLM API
# to auto-generate plain-English executive summaries
#
# Setup:
#   pip install groq python-dotenv
#   Create a .env file with: GROQ_API_KEY=your_key_here
#   Get a free key at: https://console.groq.com
#
# NEVER commit your API key to GitHub
# Add .env to .gitignore before running
# ============================================================

import os
from groq import Groq
from dotenv import load_dotenv
import pandas as pd

load_dotenv()
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))
MODEL  = "llama-3.3-70b-versatile"

def ask_ai(prompt: str, max_tokens: int = 500) -> str:
    response = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=max_tokens
    )
    return response.choices[0].message.content

def generate_rfm_summary(rfm_data: str) -> str:
    return ask_ai(f"""You are a senior e-commerce analyst.
Below is an RFM customer segmentation summary from a
Brazilian online marketplace. Write a concise 3-paragraph
executive summary (max 200 words) covering:
1. The most valuable segment and what drives their value
2. The biggest churn risk and a specific retention action
3. One pricing or campaign recommendation
Be specific and use the numbers provided.

RFM Data:
{rfm_data}""")

def generate_pricing_alerts(pricing_data: str) -> str:
    return ask_ai(f"""You are a pricing strategist.
Below are product categories with pricing issues identified
by data analysis. For each flagged category write ONE
specific actionable recommendation (1-2 sentences max).
Format as: Category | Issue | Recommendation

Data:
{pricing_data}""")

def generate_churn_insights(churn_data: str) -> str:
    return ask_ai(f"""You are a customer retention specialist.
Below are churn model results from an e-commerce analysis.
Write a concise business summary (max 150 words) covering:
1. What the model found as the strongest churn signal
2. Which customer group is highest priority to retain
3. One specific retention campaign recommendation

Data:
{churn_data}""", max_tokens=300)


if __name__ == "__main__":
    # Replace with your actual BigQuery/Python outputs
    rfm_data = """
    segment, customer_count, avg_recency_days, avg_revenue, total_revenue
    Champions, 3826, 49.8, 466.20, 1783690
    At-Risk, 15154, 397.9, 320.57, 4857870
    Loyal Customers, 11972, 109.0, 261.50, 3130716
    Needs Attention, 38250, 233.2, 122.88, 4700093
    Recent Customers, 11428, 47.2, 72.82, 832235
    Lost, 15848, 399.5, 55.79, 884175
    """

    pricing_data = """
    category, avg_price, avg_review_score, pricing_flag
    computers_accessories, 185.4, 4.3, High satisfaction - inconsistent pricing
    furniture_decor, 245.8, 3.4, Low satisfaction - premium priced
    telephony, 312.5, 3.6, High volume but poor reviews
    health_beauty, 78.2, 4.4, Monitor
    """

    churn_data = """
    Best model: Random Forest, ROC-AUC: 0.758
    Top feature: avg_freight (importance 0.656)
    Second feature: avg_delay (importance 0.116)
    Churn rate: 60%, High risk customers (>0.7 probability): 14823
    Key finding: Freight cost stronger churn predictor than review score
    """

    print("Generating AI summaries...\n")

    rfm_summary    = generate_rfm_summary(rfm_data)
    pricing_alerts = generate_pricing_alerts(pricing_data)
    churn_insights = generate_churn_insights(churn_data)

    # Save outputs
    with open('outputs/ai_rfm_summary.txt', 'w') as f:
        f.write(rfm_summary)
    with open('outputs/ai_pricing_alerts.txt', 'w') as f:
        f.write(pricing_alerts)
    with open('outputs/ai_churn_insights.txt', 'w') as f:
        f.write(churn_insights)

    print("=== RFM EXECUTIVE SUMMARY ===")
    print(rfm_summary)
    print("\n=== PRICING ALERTS ===")
    print(pricing_alerts)
    print("\n=== CHURN INSIGHTS ===")
    print(churn_insights)
    print("\n✓ Saved all 3 outputs to /outputs/")
