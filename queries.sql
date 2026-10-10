-- =========================================================
-- Sales Business Intelligence Platform — Reporting Queries
-- =========================================================

-- 1. Total revenue and profit (all time)
SELECT SUM(line_revenue) AS total_revenue, SUM(line_profit) AS total_profit,
       ROUND(100.0 * SUM(line_profit) / NULLIF(SUM(line_revenue),0), 1) AS margin_pct
FROM order_items;

-- 2. Monthly revenue and profit trend
SELECT dd.year, dd.month, dd.month_name,
       SUM(oi.line_revenue) AS revenue, SUM(oi.line_profit) AS profit
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN date_dim dd ON dd.date_id = o.order_date
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- 3. Revenue by region
SELECT r.region_name, SUM(oi.line_revenue) AS revenue, SUM(oi.line_profit) AS profit
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN regions r ON r.region_id = o.region_id
GROUP BY r.region_name
ORDER BY revenue DESC;

-- 4. Revenue by product
SELECT p.product_name, p.category, SUM(oi.quantity) AS units_sold,
       SUM(oi.line_revenue) AS revenue, SUM(oi.line_profit) AS profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name, p.category
ORDER BY revenue DESC;

-- 5. Revenue by product category
SELECT p.category, SUM(oi.line_revenue) AS revenue, SUM(oi.line_profit) AS profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 6. Salesperson performance (revenue, profit, order count)
SELECT e.first_name, e.last_name, r.region_name,
       COUNT(DISTINCT o.order_id) AS orders_handled,
       SUM(oi.line_revenue) AS revenue, SUM(oi.line_profit) AS profit
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN employees e ON e.employee_id = o.employee_id
JOIN regions r ON r.region_id = e.region_id
GROUP BY e.first_name, e.last_name, r.region_name
ORDER BY revenue DESC;

-- 7. Top 10 customers by revenue
SELECT c.customer_name, c.segment, SUM(oi.line_revenue) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_name, c.segment
ORDER BY revenue DESC
LIMIT 10;

-- 8. Low-performing products (bottom 5 by revenue)
SELECT p.product_name, SUM(oi.line_revenue) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue ASC
LIMIT 5;

-- 9. Products with lowest margin %
SELECT p.product_name,
       ROUND(100.0 * (p.unit_price - p.unit_cost) / NULLIF(p.unit_price,0), 1) AS margin_pct
FROM products p
ORDER BY margin_pct ASC
LIMIT 5;

-- 10. Average order value overall
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT o.order_id, SUM(oi.line_revenue) AS order_total
    FROM order_items oi JOIN orders o ON o.order_id = oi.order_id
    GROUP BY o.order_id
) t;

-- 11. Average order value by region
SELECT r.region_name, ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT o.order_id, o.region_id, SUM(oi.line_revenue) AS order_total
    FROM order_items oi JOIN orders o ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.region_id
) t
JOIN regions r ON r.region_id = t.region_id
GROUP BY r.region_name
ORDER BY avg_order_value DESC;

-- 12. Year-over-year revenue growth
WITH yearly AS (
    SELECT dd.year, SUM(oi.line_revenue) AS revenue
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN date_dim dd ON dd.date_id = o.order_date
    GROUP BY dd.year
)
SELECT year, revenue,
       LAG(revenue) OVER (ORDER BY year) AS prev_year_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year)) / NULLIF(LAG(revenue) OVER (ORDER BY year),0), 1) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- 13. Quarter-over-quarter revenue
SELECT dd.year, dd.quarter, SUM(oi.line_revenue) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN date_dim dd ON dd.date_id = o.order_date
GROUP BY dd.year, dd.quarter
ORDER BY dd.year, dd.quarter;

-- 14. Customer segment performance
SELECT c.segment, COUNT(DISTINCT o.order_id) AS orders, SUM(oi.line_revenue) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY revenue DESC;

-- 15. Orders per salesperson per month (activity tracking)
SELECT e.first_name, e.last_name, dd.year, dd.month,
       COUNT(DISTINCT o.order_id) AS orders_count
FROM orders o
JOIN employees e ON e.employee_id = o.employee_id
JOIN date_dim dd ON dd.date_id = o.order_date
GROUP BY e.first_name, e.last_name, dd.year, dd.month
ORDER BY dd.year, dd.month, e.last_name;

-- 16. Top salesperson per region (highest revenue in each region)
SELECT DISTINCT ON (r.region_name) r.region_name, e.first_name, e.last_name, SUM(oi.line_revenue) OVER (PARTITION BY e.employee_id) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN employees e ON e.employee_id = o.employee_id
JOIN regions r ON r.region_id = e.region_id
ORDER BY r.region_name, revenue DESC;

-- 17. Customers with declining order frequency (potential churn risk)
-- Compares each customer's order count in the most recent 90 days vs. the prior 90 days
WITH recent AS (
    SELECT customer_id, COUNT(*) AS recent_orders
    FROM orders
    WHERE order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '90 days'
    GROUP BY customer_id
),
prior AS (
    SELECT customer_id, COUNT(*) AS prior_orders
    FROM orders
    WHERE order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '180 days'
      AND order_date <  (SELECT MAX(order_date) FROM orders) - INTERVAL '90 days'
    GROUP BY customer_id
)
SELECT c.customer_name, COALESCE(p.prior_orders,0) AS prior_90d, COALESCE(r.recent_orders,0) AS recent_90d
FROM customers c
LEFT JOIN recent r ON r.customer_id = c.customer_id
LEFT JOIN prior p ON p.customer_id = c.customer_id
WHERE COALESCE(r.recent_orders,0) < COALESCE(p.prior_orders,0)
ORDER BY prior_90d DESC;

-- 18. Revenue concentration: % of revenue from top 20% of customers (Pareto check)
WITH cust_rev AS (
    SELECT c.customer_id, SUM(oi.line_revenue) AS revenue
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
ranked AS (
    SELECT *, NTILE(5) OVER (ORDER BY revenue DESC) AS quintile
    FROM cust_rev
)
SELECT quintile, SUM(revenue) AS revenue,
       ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS pct_of_total
FROM ranked
GROUP BY quintile
ORDER BY quintile;

-- 19. Day-of-week sales pattern
SELECT dd.day_name, COUNT(DISTINCT o.order_id) AS orders, SUM(oi.line_revenue) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN date_dim dd ON dd.date_id = o.order_date
GROUP BY dd.day_name
ORDER BY revenue DESC;

-- 20. Product category performance by region (cross-tab style)
SELECT r.region_name, p.category, SUM(oi.line_revenue) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN regions r ON r.region_id = o.region_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY r.region_name, p.category
ORDER BY r.region_name, revenue DESC;

-- 21. New customers acquired per quarter
SELECT dd.year, dd.quarter, COUNT(*) AS new_customers
FROM customers c
JOIN date_dim dd ON dd.date_id = c.signup_date
GROUP BY dd.year, dd.quarter
ORDER BY dd.year, dd.quarter;

-- 22. Conversion-related metric: average items per order (basket size) by region
SELECT r.region_name, ROUND(AVG(item_count), 2) AS avg_items_per_order
FROM (
    SELECT o.order_id, o.region_id, COUNT(*) AS item_count
    FROM order_items oi JOIN orders o ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.region_id
) t
JOIN regions r ON r.region_id = t.region_id
GROUP BY r.region_name
ORDER BY avg_items_per_order DESC;
