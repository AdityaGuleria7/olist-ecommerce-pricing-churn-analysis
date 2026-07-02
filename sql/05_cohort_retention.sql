-- ============================================================
-- 05 Cohort Retention
-- Monthly cohort table showing customer acquisition over time
-- Note: customer_id anonymised per order in Olist dataset
-- so this tracks order-level cohorts not true repeat buyers
-- ============================================================

WITH first_order AS (
  SELECT
    customer_id,
    DATE_TRUNC(MIN(order_purchase_timestamp), MONTH) AS cohort_month
  FROM `portfolioproject-500222.Datasetraw.vw_orders_master`
  GROUP BY customer_id
),
orders_with_cohort AS (
  SELECT
    o.customer_id,
    fo.cohort_month,
    DATE_TRUNC(o.order_purchase_timestamp, MONTH) AS order_month,
    DATE_DIFF(
      DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH),
      DATE(fo.cohort_month),
      MONTH
    ) AS month_number
  FROM `portfolioproject-500222.Datasetraw.vw_orders_master` o
  JOIN first_order fo USING (customer_id)
)
SELECT
  FORMAT_DATE('%Y-%m', cohort_month) AS cohort,
  month_number,
  COUNT(DISTINCT customer_id)        AS active_customers
FROM orders_with_cohort
GROUP BY cohort, month_number
ORDER BY cohort, month_number;
