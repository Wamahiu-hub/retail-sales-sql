select count (*) from electronics.customers;

--SECTION A

-- Q1: Retrieve all customer records
SELECT * 
FROM customers;

-- Q2: Display customer names, cities, and segments
SELECT customer_name, city, customer_segment 
FROM customers;

-- Q3: Find customers living in Nairobi
SELECT * 
FROM customers 
WHERE city = 'Nairobi';

-- Q4: Find customers registered after January 1, 2025
SELECT * 
FROM customers 
WHERE registration_date > '2025-01-01';

-- Q5: Display all unique customer cities
SELECT DISTINCT city 
FROM customers;

-- Q6: Retrieve the 10 most recent orders
SELECT * 
FROM orders 
ORDER BY order_date DESC 
LIMIT 10;

-- Q7: Find orders with unit prices above KSh 10,000
SELECT * 
FROM orders 
WHERE unit_price > 10000;

-- Q8: Find customers whose names start with A
SELECT * 
FROM customers 
WHERE customer_name LIKE 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5
SELECT * 
FROM orders 
WHERE quantity BETWEEN 2 AND 5;

-- Q10: Find orders paid through M-Pesa
SELECT * 
FROM orders 
WHERE payment_method = 'M-Pesa';

--SECTION B
-- Q11: Count all customers
SELECT COUNT(*) AS total_customers 
FROM customers;


-- Q12: Count all orders
SELECT COUNT(*) AS total_orders 
FROM orders;


-- Q13: Calculate completed-order revenue
SELECT 
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue
FROM orders
WHERE order_status = 'Completed';


-- Q14: Calculate the average completed-order value
SELECT 
    ROUND(AVG(quantity * unit_price * (1 - discount / 100.0)), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Completed';


-- Q15: Find the highest and lowest product prices
SELECT 
    MAX(unit_price) AS max_unit_price,
    MIN(unit_price) AS min_unit_price
FROM orders
WHERE order_status = 'Completed';


-- Q16: Calculate revenue by product category
SELECT 
    product_category,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY total_revenue DESC;


-- Q17: Count customers by city
SELECT 
    city,
    COUNT(customer_id) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;


-- Q18: Calculate quantity sold by product
SELECT 
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY total_quantity_sold DESC;


-- Q19: Find categories generating more than KSh 100,000 in revenue
SELECT 
    product_category,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100.0)) > 100000
ORDER BY total_revenue DESC;


-- Q20: Calculate the percentage of cancelled orders
SELECT 
    ROUND(
        (COUNT(*) FILTER (WHERE order_status = 'Cancelled') * 100.0) / COUNT(*), 
        2
    ) AS cancelled_order_percentage
FROM orders;

--SECTION C

-- Q21: Display orders with customer names and cities
SELECT 
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date,
    o.product_name,
    o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;


-- Q22: Calculate total spending by customer
SELECT 
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;




-- Q23: Identify customers who have never ordered
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.registration_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Q24: Find the 10 highest-spending customers
SELECT 
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 10;


-- Q25: Calculate revenue by customer city
SELECT 
    c.city,
    ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY total_revenue DESC;


-- Q26: Identify customers with more than five orders
-- Note: Rule 2 specifies order counts include all statuses
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC;


-- Q27: Calculate average customer spending by segment
-- Definition: Calculates total spending per purchasing customer, then averages those totals by segment
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_segment,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_segment
)
SELECT 
    customer_segment,
    ROUND(AVG(total_spend), 2) AS avg_customer_spending
FROM customer_spending
GROUP BY customer_segment
ORDER BY avg_customer_spending DESC;


-- Q28: Identify the most popular category among VIP customers
-- Definition: Popularity defined by total unit quantity sold among VIP customers
SELECT 
    o.product_category,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'VIP'
  AND o.order_status = 'Completed'
GROUP BY o.product_category
ORDER BY total_units_sold DESC
LIMIT 1;

--SECTION D

-- Q29: Find customers spending above the average total spending per purchasing customer
WITH customer_totals AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    ROUND(total_spent, 2) AS total_spent
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY total_spent DESC;


-- Q30: Find products priced above the overall average unit price
SELECT DISTINCT
    product_name,
    unit_price
FROM orders
WHERE unit_price > (SELECT AVG(unit_price) FROM orders)
ORDER BY unit_price DESC;


-- Q31: Use a CTE to identify the three highest-revenue months
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM monthly_revenue
ORDER BY total_revenue DESC
LIMIT 3;


-- Q32: Find customers purchasing from at least three categories
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.product_category) AS distinct_categories_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY distinct_categories_count DESC;


-- Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin
WITH category_financials AS (
    SELECT 
        product_category,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
        SUM(quantity * cost_price) AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT 
    product_category,
    ROUND(revenue, 2) AS total_revenue,
    ROUND(cost, 2) AS total_cost,
    ROUND(revenue - cost, 2) AS total_profit,
    ROUND(((revenue - cost) / NULLIF(revenue, 0)) * 100.0, 2) AS profit_margin_pct
FROM category_financials
ORDER BY total_profit DESC;


-- Q34: Find customers whose latest completed order is more than 90 days before the latest order date in the dataset
WITH dataset_max_date AS (
    SELECT MAX(order_date) AS max_date FROM orders
),
customer_last_order AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.customer_name,
    clo.last_order_date,
    (dmd.max_date - clo.last_order_date) AS days_since_last_order
FROM customers c
JOIN customer_last_order clo ON c.customer_id = clo.customer_id
CROSS JOIN dataset_max_date dmd
WHERE (dmd.max_date - clo.last_order_date) > 90
ORDER BY days_since_last_order DESC;

--SECTION E

-- Q35: Rank customers by spending using RANK()
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    ROUND(total_spending, 2) AS total_spending,
    RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM customer_spending
ORDER BY spending_rank;


-- Q36: Number each customer's orders by recency using ROW_NUMBER()
SELECT 
    order_id,
    customer_id,
    order_date,
    product_name,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) AS order_recency_num
FROM orders;


-- Q37: Rank products within categories using DENSE_RANK()
WITH product_category_sales AS (
    SELECT 
        product_category,
        product_name,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT 
    product_category,
    product_name,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (PARTITION BY product_category ORDER BY total_revenue DESC) AS product_rank
FROM product_category_sales
ORDER BY product_category, product_rank;


-- Q38: Calculate cumulative monthly revenue
with total_months as 
(select order_id,date_trunc('month', order_date) as sales_months
from orders o 
group by order_id)
select sales_months,
count (*) as count
from total_months
group by sales_months;

count (*)  from 
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS monthly_rev
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_name,
    ROUND(monthly_rev, 2) AS monthly_revenue,
    ROUND(SUM(monthly_rev) OVER (ORDER BY sales_month), 2) AS cumulative_revenue
FROM monthly_revenue
ORDER BY sales_month;


-- Q39: Compare monthly revenue using LAG()
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS monthly_rev
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_name,
    ROUND(monthly_rev, 2) AS monthly_revenue,
    ROUND(LAG(monthly_rev) OVER (ORDER BY sales_month), 2) AS previous_month_revenue
FROM monthly_revenue
ORDER BY sales_month;


-- Q40: Calculate month-over-month revenue growth (%)
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS monthly_rev
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_lag AS (
    SELECT 
        sales_month,
        monthly_rev,
        LAG(monthly_rev) OVER (ORDER BY sales_month) AS prev_month_rev
    FROM monthly_revenue
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_name,
    ROUND(monthly_rev, 2) AS monthly_revenue,
    ROUND(prev_month_rev, 2) AS prev_month_revenue,
    ROUND(((monthly_rev - prev_month_rev) / NULLIF(prev_month_rev, 0)) * 100.0, 2) AS mom_growth_pct
FROM revenue_lag
ORDER BY sales_month;


-- Q41: Divide customers into four spending groups using NTILE(4)
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    ROUND(total_spending, 2) AS total_spending,
    NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_quartile
FROM customer_spending
ORDER BY spending_quartile, total_spending DESC;


-- Q42: Calculate each category's share of total revenue using window functions
WITH category_revenue AS (
    SELECT 
        product_category,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS cat_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT 
    product_category,
    ROUND(cat_revenue, 2) AS category_revenue,
    ROUND((cat_revenue / SUM(cat_revenue) OVER ()) * 100.0, 2) AS revenue_share_pct
FROM category_revenue
ORDER BY category_revenue DESC;

--SECTION F

-- Q43: Create a monthly_sales_summary view and query it
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT 
    DATE_TRUNC('month', order_date) AS sales_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue,
    ROUND(SUM(quantity * cost_price), 2) AS total_cost,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)) - SUM(quantity * cost_price), 2) AS total_profit
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date);

-- Query the view ordered chronologically
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_name,
    total_orders,
    total_revenue,
    total_cost,
    total_profit
FROM monthly_sales_summary
ORDER BY sales_month;


-- Q44: Create a PostgreSQL function returning completed-order revenue for a customer ID
CREATE OR REPLACE FUNCTION get_customer_revenue(p_customer_id INTEGER)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE 
    v_revenue NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price * (1 - discount / 100.0)), 0.00)
    INTO v_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';
      
    RETURN v_revenue;
END;
$$;

-- Test 1: For an existing customer (e.g., customer_id 141)
SELECT get_customer_revenue(141) AS customer_141_revenue;

-- Test 2: For an ID that does not exist (returns 0, not NULL)
SELECT get_customer_revenue(9999) AS non_existent_customer_revenue;


-- Q45: Segment customers into High, Medium, and Low Value with Rationale
/*
  Threshold Rationale:
  - High Value (>= KSh 150,000): Premium VIP and top-tier corporate clients driving primary profitability.
  - Medium Value (KSh 50,000 - KSh 149,999): Consistent regular retail buyers with steady purchasing frequency.
  - Low Value (< KSh 50,000): Occasional or low-ticket buyers with minimal overall contribution.
*/
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    ROUND(total_spending, 2) AS total_spending,
    CASE 
        WHEN total_spending >= 150000 THEN 'High'
        WHEN total_spending >= 50000 THEN 'Medium'
        ELSE 'Low'
    END AS customer_value_segment
FROM customer_spending
ORDER BY total_spending DESC;


-- Q46: Produce a management report (Top 5 customers, top 5 products, most profitable category, lowest-revenue month)

-- Part A: Top 5 Customers by Revenue
SELECT 
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Part B: Top 5 Products by Revenue
SELECT 
    product_name,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Part C: Most Profitable Category
SELECT 
    product_category,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)) - SUM(quantity * cost_price), 2) AS total_profit
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY total_profit DESC
LIMIT 1;

-- Part D: Lowest-Revenue Month
SELECT 
    TO_CHAR(DATE_TRUNC('month', order_date), 'YYYY-MM') AS lowest_revenue_month,
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY total_revenue ASC
LIMIT 1;