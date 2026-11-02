-- SQL Analysis Pack (PostgreSQL 14+)
-- Run schema.sql, then sample_data.sql, then this file.

-- 1. Inspect all customers.
SELECT * FROM customers ORDER BY signup_date DESC;

-- 2. Total net sales from completed orders.
SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS total_net_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';

-- 3. Monthly sales and month-over-month growth using LAG.
WITH monthly AS (
  SELECT sales_month, net_sales
  FROM vw_monthly_sales
)
SELECT sales_month, net_sales,
       LAG(net_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
       ROUND(100.0 * (net_sales - LAG(net_sales) OVER (ORDER BY sales_month))
             / NULLIF(LAG(net_sales) OVER (ORDER BY sales_month), 0), 2) AS mom_growth_pct
FROM monthly
ORDER BY sales_month;

-- 4. Top 10 customers by lifetime value.
SELECT customer_id, first_name, last_name, completed_orders, lifetime_value
FROM vw_customer_lifetime_value
ORDER BY lifetime_value DESC
LIMIT 10;

-- 5. Revenue by product category.
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_sales
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY net_sales DESC;

-- 6. Best-selling products by units.
SELECT p.product_name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- 7. Average order value (AOV).
WITH order_totals AS (
  SELECT o.order_id,
         SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)) AS order_total
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'Completed'
  GROUP BY o.order_id
)
SELECT ROUND(AVG(order_total), 2) AS average_order_value FROM order_totals;

-- 8. Orders by channel.
SELECT o.sales_channel, COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_sales
FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.sales_channel
ORDER BY net_sales DESC;

-- 9. Customers who have never placed an order (LEFT JOIN / anti-join).
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 10. Customers spending above the average customer lifetime value (subquery).
SELECT customer_id, first_name, last_name, lifetime_value
FROM vw_customer_lifetime_value
WHERE lifetime_value > (SELECT AVG(lifetime_value) FROM vw_customer_lifetime_value)
ORDER BY lifetime_value DESC;

-- 11. Rank customers by spend (RANK and DENSE_RANK).
SELECT customer_id, first_name, last_name, lifetime_value,
       RANK() OVER (ORDER BY lifetime_value DESC) AS spend_rank,
       DENSE_RANK() OVER (ORDER BY lifetime_value DESC) AS dense_spend_rank
FROM vw_customer_lifetime_value;

-- 12. Running monthly sales total.
SELECT sales_month, net_sales,
       SUM(net_sales) OVER (ORDER BY sales_month
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sales_total
FROM vw_monthly_sales
ORDER BY sales_month;

-- 13. Department salary ranking.
SELECT employee_id, first_name, last_name, department, annual_salary,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY annual_salary DESC NULLS LAST) AS salary_rank
FROM employees
WHERE employment_status = 'Active';

-- 14. Employee attrition by department (simple cumulative measure).
SELECT * FROM vw_employee_attrition_summary ORDER BY cumulative_termination_pct DESC NULLS LAST;

-- 15. Yearly attrition rate: terminations during year / average headcount during year.
-- Note: for a production HRIS, use a date-effective employee snapshot for precise monthly headcount.
WITH years AS (
  SELECT DISTINCT EXTRACT(YEAR FROM effective_date)::INT AS year
  FROM employee_status_history
),
yearly AS (
  SELECT y.year,
         COUNT(*) FILTER (WHERE h.status = 'Terminated') AS terminations
  FROM years y
  LEFT JOIN employee_status_history h
    ON EXTRACT(YEAR FROM h.effective_date)::INT = y.year
  GROUP BY y.year
)
SELECT year, terminations,
       ROUND(100.0 * terminations / NULLIF((SELECT COUNT(*) FROM employees), 0), 2)
         AS termination_rate_pct_of_current_roster
FROM yearly
ORDER BY year;
-- The metric above is a simplified teaching proxy, not a standard HR attrition rate.
-- A standard rate requires average headcount over the same period.

-- 16. Monthly sales by category with month-over-month category growth.
WITH category_month AS (
  SELECT DATE_TRUNC('month', o.order_date)::DATE AS sales_month, p.category,
         SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)) AS net_sales
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.order_status = 'Completed'
  GROUP BY 1, 2
)
SELECT sales_month, category, ROUND(net_sales, 2) AS net_sales,
       ROUND(100.0 * (net_sales - LAG(net_sales) OVER (PARTITION BY category ORDER BY sales_month))
       / NULLIF(LAG(net_sales) OVER (PARTITION BY category ORDER BY sales_month), 0), 2) AS mom_growth_pct
FROM category_month
ORDER BY category, sales_month;

-- 17. Repeat purchase rate: share of customers with 2+ completed orders.
WITH customer_orders AS (
  SELECT c.customer_id, COUNT(DISTINCT o.order_id) AS completed_orders
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.order_status = 'Completed'
  GROUP BY c.customer_id
)
SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE completed_orders >= 2) / NULLIF(COUNT(*), 0), 2)
       AS repeat_purchase_rate_pct
FROM customer_orders;

-- 18. Orders that are unusually large relative to the order average.
WITH order_totals AS (
  SELECT o.order_id, o.customer_id,
         SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)) AS order_total
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'Completed'
  GROUP BY o.order_id, o.customer_id
)
SELECT *
FROM order_totals
WHERE order_total > (SELECT AVG(order_total) * 2 FROM order_totals)
ORDER BY order_total DESC;

-- 19. Customer segmentation based on lifetime value.
SELECT customer_id, first_name, last_name, lifetime_value,
       CASE
         WHEN lifetime_value >= 10000 THEN 'High Value'
         WHEN lifetime_value >= 5000 THEN 'Growth'
         WHEN lifetime_value > 0 THEN 'Occasional'
         ELSE 'No Purchase'
       END AS value_segment
FROM vw_customer_lifetime_value
ORDER BY lifetime_value DESC;

-- 20. Product revenue contribution percentage.
WITH category_sales AS (
  SELECT p.category,
         SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)) AS net_sales
  FROM order_items oi JOIN orders o ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.order_status = 'Completed'
  GROUP BY p.category
)
SELECT category, ROUND(net_sales, 2) AS net_sales,
       ROUND(100.0 * net_sales / NULLIF(SUM(net_sales) OVER (), 0), 2) AS sales_share_pct
FROM category_sales
ORDER BY net_sales DESC;
