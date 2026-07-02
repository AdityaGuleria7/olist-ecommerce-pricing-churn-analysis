-- ============================================================
-- 06 Revenue Breakdown
-- Monthly revenue by state, category and payment type
-- Used for Tableau geographic and trend analysis
-- ============================================================

SELECT
  FORMAT_DATE('%Y-%m', order_purchase_timestamp) AS month,
  customer_state,
  product_category_name_english                  AS category,
  payment_type,
  COUNT(DISTINCT order_id)                       AS orders,
  COUNT(DISTINCT customer_id)                    AS unique_customers,
  ROUND(SUM(total_order_value), 2)               AS revenue,
  ROUND(AVG(review_score), 2)                    AS avg_review,
  COUNTIF(delivery_delay_days > 0)               AS late_deliveries
FROM `portfolioproject-500222.Datasetraw.vw_orders_master`
WHERE product_category_name_english IS NOT NULL
GROUP BY month, customer_state, category, payment_type
ORDER BY month, revenue DESC;
