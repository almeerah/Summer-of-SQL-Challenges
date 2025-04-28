    /*
Challenge can be found here: https://8weeksqlchallenge.com/case-study-2/
This challenge was completed using PostgreSQL
*/

-- SECTION A --

-- How many pizzas were ordered
SELECT COUNT(order_id) from customer_orders;

-- How many unique customer orders were made?
SELECT COUNT (DISTINCT order_id) from customer_orders;

-- How many successful orders were delivered by each runner?
SELECT COUNT (DISTINCT order_id)
FROM runner_orders
WHERE cancellation NOT LIKE '%Cancellation';

-- How many of each type of pizza was delivered?
SELECT
pizza_name,
COUNT (c.order_id) as delivered_pizzas
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
JOIN pizza_names p ON c.pizza_id = p.pizza_id
WHERE pickup_time <>'null'
GROUP BY p.pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
c.customer_id,
p.pizza_name,
COUNT (c.order_id) as num_pizzas
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY p.pizza_name, c.customer_id
ORDER BY c.customer_id;

-- What was the maximum number of pizzas delivered in a single order?
SELECT 
  ro.order_id, 
  COUNT(co.order_id) as delivered_pizzas 
FROM 
  customer_orders as co 
  INNER JOIN pizza_names as pn on co.pizza_id = pn.pizza_id 
  INNER JOIN runner_orders as ro on ro.order_id = co.order_id 
WHERE 
  pickup_time<>'null'
GROUP BY 
  ro.order_id 
ORDER BY 
  COUNT(co.order_id) DESC 
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  c.customer_id, 

  SUM(CASE 
    WHEN 
        (
          (exclusions IS NOT NULL AND exclusions<>'null' AND LENGTH(exclusions)>0) 
        AND (extras IS NOT NULL AND extras<>'null' AND LENGTH(extras)>0)
        )=TRUE
    THEN 1 
    ELSE 0
  END) as changes, 
  SUM(CASE 
    WHEN 
        (
          (exclusions IS NOT NULL AND exclusions<>'null' AND LENGTH(exclusions)>0) 
        AND (extras IS NOT NULL AND extras<>'null' AND LENGTH(extras)>0)
        )=TRUE
    THEN 0 
    ELSE 1
  END) as no_changes 

FROM customer_orders AS c
INNER JOIN runner_orders AS r ON r.order_id = c.order_id 
WHERE pickup_time IS NOT NULL
GROUP BY c.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT
COUNT(c.order_id)
FROM customer_orders c
JOIN runner_orders r ON r.order_id = c.order_id 
WHERE pickup_time <>'null'
AND ((exclusions IS NOT NULL AND exclusions<>'null' AND LENGTH(exclusions)>0) 
        AND (extras IS NOT NULL AND extras<>'null' AND LENGTH(extras)>0));
        
  -- What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS hour,
COUNT(order_id)
FROM customer_orders
GROUP BY hour;

-- What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time, 'Day') AS weekday,
COUNT(order_id)
FROM customer_orders
GROUP BY weekday;
