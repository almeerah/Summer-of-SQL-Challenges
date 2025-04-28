/* 
Challenge can be found here: https://8weeksqlchallenge.com/case-study-1/
This was completed using PostgreSQL

   --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

    SELECT s.customer_id, SUM(m.price) AS total_spent
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
    SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS total_visits
    FROM sales s
    GROUP BY s.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
	WITH ranked_orders AS (
      SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
    )
    SELECT customer_id, order_date, product_name
    FROM ranked_orders
    WHERE rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

	WITH product_orders AS (
      SELECT 
        m.product_name, 
        COUNT(DISTINCT s.order_date) AS orders
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
      GROUP BY m.product_name
    )
    SELECT product_name, orders
    FROM product_orders
    ORDER BY orders DESC
    LIMIT 1;

-- 5. Which item was the most popular for each customer?

    	WITH product_orders AS (
      SELECT 
        s.customer_id, 
        m.product_name,
        COUNT(DISTINCT s.order_date) AS orders,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY COUNT(DISTINCT s.order_date) DESC) AS rn      
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
      GROUP BY s.customer_id, m.product_name
    )
    SELECT customer_id, product_name, orders
    FROM product_orders
    WHERE rn = 1
    ORDER BY customer_id ASC;
    
-- 6. Which item was purchased first by the customer after they became a member?

	WITH date_orders AS (
      SELECT
      s.customer_id,
      m.product_name,
      mem.join_date,
      ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rn     
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
      JOIN members mem ON s.customer_id = mem.customer_id
      WHERE s.order_date >= mem.join_date
      ORDER BY order_date ASC
    )
    SELECT customer_id, product_name
    FROM date_orders
    WHERE rn = 1;
    
-- 7. Which item was purchased just before the customer became a member?

	WITH date_orders AS (
      SELECT
      s.customer_id,
      m.product_name,
      mem.join_date,
      ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn     
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
      JOIN members mem ON s.customer_id = mem.customer_id
      WHERE s.order_date < mem.join_date
      ORDER BY order_date DESC
    )
    SELECT customer_id, product_name
    FROM date_orders
    WHERE rn = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

	WITH date_orders AS (
      SELECT
      s.customer_id,
      s.order_date,
      m.product_name,
      mem.join_date,
      m.price
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
      JOIN members mem ON s.customer_id = mem.customer_id
      WHERE s.order_date < mem.join_date
    )
    SELECT customer_id, sum(price) as total_spend, COUNT (DISTINCT order_date) as num_orders
    FROM date_orders
    GROUP BY customer_id;
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

	WITH points_table AS (
      SELECT
      s.customer_id,
      m.product_name,
      m.price,
      CASE 
      WHEN m.product_name = 'sushi'
        THEN m.price * 20
        ELSE m.price * 10
      END AS points
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
    )
    SELECT customer_id, sum(points) as points_total
    FROM points_table
    GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
	
    WITH points_table AS (
      SELECT
      s.customer_id,
      m.product_name,
      m.price,
      s.order_date,
      CASE 
        WHEN order_date BETWEEN mem.join_date AND  mem.join_date + INTERVAL '6 day' THEN price*2*10
      WHEN m.product_name = 'sushi'
        THEN m.price * 20
        ELSE m.price * 10
      END AS points
      FROM sales s
      JOIN menu m ON s.product_id = m.product_id
      JOIN members mem ON s.customer_id = mem.customer_id
    )
    SELECT customer_id, sum(points) as points_total
    FROM points_table
    WHERE order_date <= '2021-01-31'
    GROUP BY customer_id;

-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;
