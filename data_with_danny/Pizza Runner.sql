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




-- SECTION B --

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
  DATE '2021-01-01' + ((registration_date - DATE '2021-01-01') / 7) * 7 AS week_start,
  COUNT(runner_id) AS runners_signed_up
FROM runners
GROUP BY week_start
ORDER BY week_start;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
r.runner_id,
AVG(r.pickup_time::timestamp - c.order_time::timestamp)
FROM runner_orders r
JOIN customer_orders c ON r.order_id = c.order_id
WHERE r.pickup_time <> 'null'
GROUP BY r.runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizzas_and_time AS
(
SELECT c.order_id,
COUNT(pizza_id) as num_pizzas,
r.pickup_time::timestamp - c.order_time::timestamp as prep_time
FROM runner_orders r
JOIN customer_orders c ON r.order_id = c.order_id
WHERE r.pickup_time <> 'null'
GROUP BY c.order_id, prep_time
  )
  
  SELECT
  num_pizzas,
  AVG(prep_time) as avg_prep_time
  FROM pizzas_and_time
  GROUP BY num_pizzas
  ORDER BY num_pizzas;

-- What was the average distance travelled for each customer?
SELECT
c.customer_id,
AVG(REPLACE(distance, 'km', ''):: numeric(3, 1)) AS avg_distance
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE distance <> 'null'
GROUP BY c.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT 
  MAX(REGEXP_REPLACE(duration, '\D', '', 'g')::int) - 
  MIN(REGEXP_REPLACE(duration, '\D', '', 'g')::int) AS delivery_time_difference 
FROM 
  runner_orders 
WHERE 
  duration <> 'null';

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id,
AVG(
(REGEXP_REPLACE(distance, '[^0-9.]', '', 'g')::float)
/
(ROUND(REGEXP_REPLACE(duration, '[^0-9]', '', 'g')::numeric / 60, 2))
)AS speed_kmh
FROM runner_orders r
WHERE distance <> 'null' AND
duration <> 'null'
GROUP BY runner_id, order_id;

-- What is the successful delivery percentage for each runner?
SELECT runner_id,
(COUNT(CASE WHEN duration <> 'null'
     THEN 1 END)::decimal / COUNT(order_id)) * 100 AS successful_orders
FROM runner_orders
GROUP BY runner_id;



-- Section C ---

-- What are the standard ingredients for each pizza?
SELECT pr.pizza_id,
T.topping_name
FROM pizza_recipes pr
JOIN LATERAL unnest(string_to_array(pr.toppings, ', ')) AS topping
  ON TRUE
JOIN pizza_toppings T
  ON T.topping_id = topping::INTEGER;

-- What was the most commonly added extra?
WITH ordered_extras AS (
  SELECT 
    t.topping_name,
    count(extras_split) AS count_extras
  FROM customer_orders c
  JOIN LATERAL unnest(string_to_array(c.extras, ', ')) AS extras_split
    ON TRUE
  JOIN pizza_toppings t
    ON t.topping_id = extras_split::INT
  WHERE c.extras IS NOT NULL AND c.extras <> 'null'
  GROUP BY t.topping_name
  ORDER BY count_extras DESC
)
SELECT topping_name
FROM ordered_extras
LIMIT 1;

-- What was the most common exclusion?
WITH ordered_exc AS (
  SELECT 
    t.topping_name,
    count(exc_split) AS count_exc
  FROM customer_orders c
  JOIN LATERAL unnest(string_to_array(c.exclusions, ', ')) AS exc_split
    ON TRUE
  JOIN pizza_toppings t
    ON t.topping_id = exc_split::INT
  WHERE c.exclusions IS NOT NULL AND c.exclusions <> 'null'
  GROUP BY t.topping_name
  ORDER BY count_exc DESC
)
SELECT topping_name
FROM ordered_exc
LIMIT 1;

/* Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */
WITH ordered_exc AS (
  SELECT 
    c.order_id,
    c.pizza_id,
    ' - Exclude ' || string_agg(DISTINCT t.topping_name, ', ') AS toppings
  FROM customer_orders c
  JOIN LATERAL unnest(string_to_array(c.exclusions, ', ')) AS exc(topping_id) ON TRUE
  LEFT JOIN pizza_toppings t ON t.topping_id = exc.topping_id::int
  WHERE c.exclusions IS NOT NULL AND c.exclusions <> 'null'
  GROUP BY c.order_id, c.pizza_id
),
ordered_extras AS (
  SELECT 
    c.order_id,
    c.pizza_id,
    ' - Extra ' || string_agg(DISTINCT t.topping_name, ', ') AS toppings
  FROM customer_orders c
  JOIN LATERAL unnest(string_to_array(c.extras, ', ')) AS ext(topping_id) ON TRUE
  LEFT JOIN pizza_toppings t ON t.topping_id = ext.topping_id::int
  WHERE c.extras IS NOT NULL AND c.extras <> 'null'
  GROUP BY c.order_id, c.pizza_id
)
SELECT 
  c.order_id,
  pn.pizza_name
    || COALESCE(extr.toppings, '')
    || COALESCE(exc.toppings, '') AS full_order
FROM customer_orders c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
LEFT JOIN ordered_exc exc ON c.order_id = exc.order_id AND c.pizza_id = exc.pizza_id
LEFT JOIN ordered_extras extr ON c.order_id = extr.order_id AND c.pizza_id = extr.pizza_id
ORDER BY c.order_id;

/*Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/

WITH ordered_exclusions AS(
     SELECT 
    c.order_id,
    c.pizza_id,
    t.topping_id
  
  FROM customer_orders c
  JOIN LATERAL unnest(string_to_array(c.exclusions, ', ')) AS exc(topping_id) ON TRUE
  LEFT JOIN pizza_toppings t ON t.topping_id = exc.topping_id::int
  WHERE c.exclusions IS NOT NULL AND c.exclusions <> 'null'
  ),
ordered_extras AS(
     SELECT 
    c.order_id,
    c.pizza_id,
    t.topping_id,
  	t.topping_name
  
  FROM customer_orders c
  JOIN LATERAL unnest(string_to_array(c.extras, ', ')) AS exc(topping_id) ON TRUE
  LEFT JOIN pizza_toppings t ON t.topping_id = exc.topping_id::int
  WHERE c.extras IS NOT NULL AND c.extras <> 'null'
  ),
  orders AS (
  SELECT DISTINCT
        c.order_id,
        c.pizza_id,
        TRIM(s.value)::int AS topping_id,
        t.topping_name
    FROM customer_orders c
    INNER JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id
    LEFT JOIN LATERAL unnest(string_to_array(pr.toppings, ', ')) AS s(value) ON TRUE
    LEFT JOIN pizza_toppings t ON t.topping_id = s.value::int
    LEFT JOIN ordered_exclusions exc ON c.order_id = exc.order_id AND c.pizza_id = exc.pizza_id AND TRIM(s.value)::int = exc.topping_ID
    WHERE exc.topping_id IS NULL
  ),
  
  orders_extras_and_exclusions AS (
  
  SELECT 
	order_id,
        pizza_id,
        topping_id,
        topping_name
 FROM orders
 
 UNION ALL
 
 SELECT
 order_id,
        pizza_id,
        topping_id,
        topping_name
 FROM ordered_extras
  )
  ,
  
  ingredient_totals AS (

SELECT
order_id,
  pn.pizza_name,
  topping_name,
COUNT(topping_id) as n
FROM orders_extras_and_exclusions o
INNER JOIN pizza_names pn on pn.pizza_id = o.pizza_id
GROUP BY order_id,
  pn.pizza_name,
  topping_name
ORDER BY order_id,
  pn.pizza_name,
  topping_name
  )
  
  SELECT
order_id,
  pizza_name || ': ' || STRING_AGG( DISTINCT CASE WHEN n>1
THEN n || 'x' || topping_name
ELSE topping_name
END, ', ') as ingred

FROM ingredient_totals
GROUP BY order_id,pizza_name
;
