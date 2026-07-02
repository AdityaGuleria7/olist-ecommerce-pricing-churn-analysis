-- ============================================================
-- 01 Schema Verification
-- Run after loading all 9 Olist CSVs into BigQuery
-- Verifies row counts, nulls, and date ranges
-- ============================================================

-- Row counts for all tables
SELECT 'olist_orders' AS tbl, COUNT(*) AS row_count
FROM `portfolioproject-500222.Datasetraw.olist_orders`
UNION ALL SELECT 'olist_order_items', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_order_items`
UNION ALL SELECT 'olist_customers', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_customers`
UNION ALL SELECT 'olist_products', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_products`
UNION ALL SELECT 'olist_sellers', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_sellers`
UNION ALL SELECT 'olist_order_payments', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_order_payments`
UNION ALL SELECT 'olist_order_reviews', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_order_reviews`
UNION ALL SELECT 'olist_geolocation', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_geolocation`
UNION ALL SELECT 'olist_product_translation', COUNT(*)
FROM `portfolioproject-500222.Datasetraw.olist_product_translation`;

-- Null check on key join columns
SELECT
  COUNTIF(order_id IS NULL)     AS null_order_ids,
  COUNTIF(customer_id IS NULL)  AS null_customer_ids,
  COUNTIF(order_status IS NULL) AS null_status
FROM `portfolioproject-500222.Datasetraw.olist_orders`;

-- Date range check
SELECT
  MIN(order_purchase_timestamp) AS earliest_order,
  MAX(order_purchase_timestamp) AS latest_order,
  COUNT(DISTINCT DATE(order_purchase_timestamp)) AS active_days
FROM `portfolioproject-500222.Datasetraw.olist_orders`;

-- Master analytical view
CREATE OR REPLACE VIEW
  `portfolioproject-500222.Datasetraw.vw_orders_master` AS
SELECT
  o.order_id,
  o.customer_id,
  c.customer_unique_id,
  o.order_status,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  c.customer_state,
  c.customer_city,
  oi.product_id,
  oi.seller_id,
  oi.price,
  oi.freight_value,
  (oi.price + oi.freight_value)        AS total_order_value,
  p.product_category_name,
  ct.product_category_name_english,
  r.review_score,
  pay.payment_type,
  pay.payment_value,
  DATE_DIFF(
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DAY
  ) AS delivery_delay_days
FROM `portfolioproject-500222.Datasetraw.olist_orders` o
LEFT JOIN `portfolioproject-500222.Datasetraw.olist_customers` c
  USING (customer_id)
LEFT JOIN `portfolioproject-500222.Datasetraw.olist_order_items` oi
  USING (order_id)
LEFT JOIN `portfolioproject-500222.Datasetraw.olist_products` p
  USING (product_id)
LEFT JOIN `portfolioproject-500222.Datasetraw.olist_product_translation` ct
  ON p.product_category_name = ct.product_category_name
LEFT JOIN `portfolioproject-500222.Datasetraw.olist_order_reviews` r
  USING (order_id)
LEFT JOIN `portfolioproject-500222.Datasetraw.olist_order_payments` pay
  USING (order_id)
WHERE o.order_status = 'delivered';
