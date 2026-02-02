
-- SQL Business Analytics Project
-- Dataset: customers, orders, order_items, products
-- Author: Akanksha Gupta

-- 1) Top 10 customers by revenue
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o      ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 2) Revenue by region
SELECT c.region,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS region_revenue
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.region
ORDER BY region_revenue DESC;

-- 3) Top products by revenue
SELECT p.product_id, p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC;

-- 4) Order count by customer (including customers with zero orders)
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC, c.customer_id;

-- 5) Average order value (AOV)
WITH order_totals AS (
  SELECT o.order_id,
         SUM(oi.quantity * oi.unit_price) AS order_total
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id
)
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM order_totals;

-- 6) Monthly revenue trend
SELECT strftime('%Y-%m', o.order_date) AS year_month,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY year_month
ORDER BY year_month;

-- 7) Most recent order date by customer (customer activity)
SELECT c.customer_id, c.customer_name,
       MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY last_order_date;

-- 8) Customers with no orders (potential churn / inactive)
SELECT c.customer_id, c.customer_name, c.region
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 9) Top 3 customers per region by revenue (window function)
WITH customer_revenue AS (
  SELECT c.region, c.customer_id, c.customer_name,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM customers c
  JOIN orders o       ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.region, c.customer_id, c.customer_name
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS rnk
  FROM customer_revenue
)
SELECT region, customer_id, customer_name,
       ROUND(revenue, 2) AS revenue, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY region, rnk;

-- 10) Revenue share: top 20% customers contribution
WITH customer_rev AS (
  SELECT c.customer_id, c.customer_name,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM customers c
  JOIN orders o       ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id, c.customer_name
),
ranked AS (
  SELECT *,
         NTILE(5) OVER (ORDER BY revenue DESC) AS quintile
  FROM customer_rev
),
totals AS (
  SELECT SUM(revenue) AS total_revenue FROM ranked
)
SELECT
  ROUND(100.0 * SUM(CASE WHEN quintile = 1 THEN revenue ELSE 0 END) / (SELECT total_revenue FROM totals), 2)
  AS top_20_percent_revenue_share
FROM ranked;

