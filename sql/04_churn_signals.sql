-- ============================================================
-- 04 Churn Signals
-- Identifies pre-churn behaviour patterns
-- Customers inactive 180+ days labelled as churned
-- ============================================================

WITH customer_orders AS (
  SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    total_order_value,
    review_score,
    delivery_delay_days,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_purchase_timestamp
    ) AS order_seq
  FROM `portfolioproject-500222.Datasetraw.vw_orders_master`
),
last_order AS (
  SELECT
    customer_id,
    MAX(order_seq)                AS total_orders,
    MAX(order_purchase_timestamp) AS last_purchase,
    AVG(review_score)             AS avg_review,
    AVG(delivery_delay_days)      AS avg_delay,
    SUM(total_order_value)        AS total_spend
  FROM customer_orders
  GROUP BY customer_id
),
churn_labels AS (
  SELECT *,
    DATE_DIFF(DATE '2018-08-31',
      DATE(last_purchase), DAY) AS days_since_last,
    CASE
      WHEN DATE_DIFF(DATE '2018-08-31',
        DATE(last_purchase), DAY) > 180 THEN 1
      ELSE 0
    END AS is_churned
  FROM last_order
)
SELECT
  is_churned,
  COUNT(*)                       AS customer_count,
  ROUND(AVG(total_orders), 2)   AS avg_orders,
  ROUND(AVG(avg_review), 2)     AS avg_review_score,
  ROUND(AVG(avg_delay), 1)      AS avg_delivery_delay_days,
  ROUND(AVG(total_spend), 2)    AS avg_lifetime_value,
  ROUND(AVG(days_since_last))   AS avg_days_inactive
FROM churn_labels
GROUP BY is_churned;
