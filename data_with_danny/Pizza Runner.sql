    /*
Challenge can be found here: https://8weeksqlchallenge.com/case-study-2/
This was completed using PostgreSQL
    A. Pizza Metrics
How many pizzas were ordered?
How many unique customer orders were made?
How many successful orders were delivered by each runner?
How many of each type of pizza was delivered?
How many Vegetarian and Meatlovers were ordered by each customer?
What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
*/


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
GROUP BY p.pizza_name, c.customer_id;
