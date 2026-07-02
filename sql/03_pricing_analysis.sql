-- ============================================================
-- 03 Pricing Analysis
-- Price vs review score vs volume by category
-- Flags categories with pricing-satisfaction mismatches
-- ============================================================

WITH category_pricing AS (
  SELECT
    product_category_name_english AS category,
    COUNT(order_id)               AS order_count,
    ROUND(AVG(price), 2)          AS avg_price,
    ROUND(MIN(price), 2)          AS min_price,
    ROUND(MAX(price), 2)          AS max_price,
    ROUND(STDDEV(price), 2)       AS price_stddev,
    ROUND(AVG(review_score), 2)   AS avg_review_score,
    ROUND(AVG(freight_value), 2)  AS avg_freight,
    ROUND(SUM(price), 2)          AS total_revenue
  FROM `portfolioproject-500222.Datasetraw.vw_orders_master`
  WHERE product_category_name_english IS NOT NULL
  GROUP BY category
  HAVING order_count > 50
),
ranked AS (
  SELECT *,
    RANK() OVER (ORDER BY total_revenue DESC)      AS revenue_rank,
    RANK() OVER (ORDER BY avg_review_score DESC)   AS review_rank,
    ROUND(price_stddev / NULLIF(avg_price,0)*100,1) AS price_cv_pct
  FROM category_pricing
)
SELECT
  category,
  order_count,
  avg_price,
  price_cv_pct,
  avg_review_score,
  total_revenue,
  revenue_rank,
  review_rank,
  CASE
    WHEN avg_review_score >= 4.2 AND price_cv_pct > 40
      THEN 'High satisfaction — inconsistent pricing'
    WHEN avg_review_score < 3.5 AND avg_price > 200
      THEN 'Low satisfaction — premium priced'
    WHEN revenue_rank <= 10 AND avg_review_score < 3.8
      THEN 'High volume but poor reviews'
    ELSE 'Monitor'
  END AS pricing_flag
FROM ranked
ORDER BY total_revenue DESC
LIMIT 30;
