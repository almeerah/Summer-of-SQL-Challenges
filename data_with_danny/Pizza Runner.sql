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
