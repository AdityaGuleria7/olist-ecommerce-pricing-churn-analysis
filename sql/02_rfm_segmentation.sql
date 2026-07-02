-- ============================================================
-- 02 RFM Segmentation
-- Classifies all customers by Recency, Frequency, Monetary
-- Uses NTILE window functions to score each dimension 1-5
-- Result: 6 segments with revenue and customer metrics
-- ============================================================

WITH rfm_base AS (
  SELECT
    customer_id,
    DATE_DIFF(DATE '2018-08-31',
      MAX(DATE(order_purchase_timestamp)), DAY) AS recency_days,
    ROUND(SUM(total_order_value), 2)            AS monetary
  FROM `portfolioproject-500222.Datasetraw.vw_orders_master`
  GROUP BY customer_id
),
rfm_scores AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY monetary DESC)     AS m_score
  FROM rfm_base
),
rfm_segments AS (
  SELECT *,
    CASE
      WHEN r_score = 5 AND m_score = 1  THEN 'Champions'
      WHEN r_score >= 4 AND m_score <= 2 THEN 'Loyal Customers'
      WHEN r_score = 5 AND m_score >= 3  THEN 'Recent Customers'
      WHEN r_score <= 2 AND m_score <= 2 THEN 'At-Risk'
      WHEN r_score <= 2 AND m_score >= 4 THEN 'Lost'
      ELSE 'Needs Attention'
    END AS segment
  FROM rfm_scores
)
SELECT
  segment,
  COUNT(*)                       AS customer_count,
  ROUND(AVG(recency_days), 1)   AS avg_recency_days,
  ROUND(AVG(monetary), 2)       AS avg_revenue,
  ROUND(SUM(monetary), 2)       AS total_revenue,
  ROUND(COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (), 1)   AS pct_of_customers
FROM rfm_segments
GROUP BY segment
ORDER BY total_revenue DESC;
