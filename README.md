# SQL Project: Data Analysis for Zomato - A Food Delivery Company

## Overview

This project demonstrates my SQL problem-solving skills by analysing data for Zomato, a popular food delivery company in India. The project involves setting up the database, importing data, handling null values, and solving various business problems using complex SQL queries.

## Project Structure

- **Database Setup:** Creation of the `zomato_dataset` database and the required tables.
- **Data Import:** Inserting sample data into the tables.
- **Data Cleaning:** Handling null values and ensuring data integrity.
- **Business Problems:** Solving 20 specific business problems using SQL queries.

## Data Cleaning and Handling Null Values

Before performing the analysis, I ensured that the data was clean and free from null values where necessary. For instance:

```sql
UPDATE orders
SET total_amount = COALESCE(total_amount, 0);
```
```sql
SELECT * FROM dbo.Customers
WHERE customer_id IS NULL
    OR customer_name IS NULL
    OR reg_date IS NULL;
```

## Business Problems Solved

### 1. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

```sql
select 
	order_slots,
	count(*) as total_orders
from
(
	select 
		case
		when DATEPART(HOUR,order_time) between 0 and 1 then ' :00 - 02:00'
		when DATEPART(HOUR,order_time) between 2 and 3 then '02:00 - 04:00'
		when DATEPART(HOUR,order_time) between 4 and 5 then '04:00 - 06:00'
		when DATEPART(HOUR,order_time) between 6 and 7 then '06:00 - 08:00'
		when DATEPART(HOUR,order_time) between 8 and 9 then '08:00 - 10:00'
		when DATEPART(HOUR,order_time) between 10 and 11 then '10:00 - 12:00'
		when DATEPART(HOUR,order_time) between 12 and 13 then '12:00 - 14:00'
		when DATEPART(HOUR,order_time) between 14 and 15 then '14:00 - 16:00'
		when DATEPART(HOUR,order_time) between 16 and 17 then '16:00 - 18:00'
		when DATEPART(HOUR,order_time) between 18 and 19 then '18:00 - 20:00'
		when DATEPART(HOUR,order_time) between 20 and 21 then '20:00 - 22:00'
		when DATEPART(HOUR,order_time) between 22 and 23 then '22:00 - 00:00'
		end as order_slots
	from
		orders
)as x
group by 
	order_slots
order by 
	total_orders desc
```
**Approach 2:**
```sql
WITH TimeIntervals AS (
    SELECT 
        FLOOR(DATEPART(HOUR, order_time) / 2) * 2 AS start_time,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY 
        FLOOR(DATEPART(HOUR, order_time) / 2) * 2
)
SELECT 
    concat(start_time,'-',start_time + 2) as order_slots,
    total_orders
FROM TimeIntervals
ORDER BY total_orders DESC;
```
### 2. Write a query to find the top 5 most frequently ordered dishes by a customer called "Arjun Mehta" in the last 1 year.

**Approach 1:**

```sql
SELECT
	TOP 10
	CUSTOMER_NAME,
	ORDER_ITEM
FROM
(
	SELECT 
		--O.customer_id,
		C.customer_name AS CUSTOMER_NAME,
		COUNT(*) AS MOST_ORDERED,
		O.order_item AS ORDER_ITEM
	FROM 
		orders O
	JOIN
		customers C
	ON O.customer_id = C.customer_id
	WHERE
		customer_name LIKE '%ARJUN MEHTA%'
		AND
		Order_Date BETWEEN DATEADD(YEAR, -1, GETDATE()) AND GETDATE()
	GROUP BY 
		C.customer_name,
		O.order_item	
) AS X
ORDER BY 
		MOST_ORDERED DESC
```

**Approach 2:**

```sql
SELECT 
	CUSTOMER_NAME,
	ORDER_ITEM,
	MOST_ORDERED,
	RANKS
FROM(
	SELECT 
		C.customer_name AS CUSTOMER_NAME,
		COUNT(*) AS MOST_ORDERED,
		O.order_item AS ORDER_ITEM,
		DENSE_RANK() OVER(ORDER BY COUNT(*) DESC ) AS RANKS
	FROM 
		orders O
	JOIN
		customers C
	ON O.customer_id = C.customer_id
	WHERE C.customer_name LIKE '%ARJUN MEHTA%'
    AND
		--O.order_date BETWEEN '2023-03-03' AND '2023-12-31'
		Order_Date BETWEEN DATEADD(YEAR, -1, GETDATE()) AND GETDATE()
	GROUP BY 
		O.order_item,C.customer_name
) AS X
WHERE X.RANKS <= 5
```

### 3. Order Value Analysis
-- Question: Find the average order value per customer with more than 750 orders.Return customer_name, and aov(average order value)

```sql
SELECT 
    c.customer_name,
    ROUND(AVG(total_amount), 2) AS avg_amount_spent
FROM
    Orders o
JOIN
    Customers c
ON
    o.customer_id = c.customer_id
GROUP BY
    customer_name
HAVING
    COUNT(*) > 750
ORDER BY
    avg_amount_spent DESC;
```

### 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders. Return customer_name, and customer_id!

```sql
SELECT 
    c.customer_name,
    o.customer_id,
    SUM(total_amount) AS total_amount_spent
FROM
    Orders o
JOIN
    Customers c
ON
    o.customer_id = c.customer_id
GROUP BY
    o.customer_id,
    customer_name
HAVING 
    SUM(total_amount) > 100000;
```

### 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. Return each restaurant name, city and number of not delivered orders 

```sql
-- Approach 1
SELECT 
    r.restaurant_name,
    r.city,
    COUNT(*) AS cancelled_orders
FROM
    restaurants r
JOIN
    orders o ON r.restaurant_id = o.restaurant_id
LEFT JOIN
    deliveries d ON d.order_id = o.order_id
WHERE 
    d.delivery_id IS NULL
GROUP BY
    r.restaurant_name,
    r.city
ORDER BY 
    cancelled_orders DESC;
```


### 6. Restaurant Revenue Ranking: 
-- Question: Rank restaurants by their total revenue from the last year, including their name, total revenue, and rank within their city.

```sql
SELECT 
    x.city,
    x.restaurant_name,
    x.total_revenue
FROM
(
    SELECT 
        r.restaurant_name,
        r.city,
        SUM(o.total_amount) AS total_revenue,
        ROW_NUMBER() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rn
    FROM
        orders o
    JOIN 
        restaurants r ON r.restaurant_id = o.restaurant_id
    GROUP BY
        r.restaurant_name,
        r.city
) AS x
WHERE
    x.rn <= 2;

```

### 7. Most Popular Dish by City: 
-- Question: Identify the most popular dish in each city based on the number of orders.

```sql
SELECT 
    city,
    order_item,
    amount_ordered
FROM
(
    SELECT
        r.city,
        o.order_item,
        COUNT(*) AS amount_ordered,
        ROW_NUMBER() OVER(PARTITION BY r.city ORDER BY COUNT(*) DESC) AS rn
    FROM
        orders o
    JOIN
        restaurants r ON r.restaurant_id = o.restaurant_id
    GROUP BY
        o.order_item,
        r.city
) AS x
WHERE x.rn = 1;
```

### 8. Customer Churn: 
--Question:  Find customers who haven’t placed an order in 2024 but did in 2023.

```sql
WITH cte1 AS
(
    SELECT 
        c.customer_id,
        c.customer_name,
        o.order_date
    FROM 
        orders o
    LEFT JOIN
        customers c ON c.customer_id = o.customer_id
    WHERE 
        YEAR(order_date) = 2023
),
cte2 AS
(
    SELECT 
        c.customer_id,
        c.customer_name,
        o.order_date
    FROM 
        orders o
    LEFT JOIN
        customers c ON c.customer_id = o.customer_id
    WHERE 
        YEAR(order_date) = 2024
)
SELECT 
    DISTINCT c1.customer_name
FROM cte1 c1
LEFT JOIN cte2 c2 ON c1.customer_id = c2.customer_id
WHERE c2.customer_id IS NULL;

```
**Approach 2:**
```sql
SELECT 
	c.customer_name,
	o.order_date
FROM 
	customers c
join
	orders o
on
	o.customer_id= c.customer_id
where
	o.customer_id not in
					(select distinct customer_id from orders where year(order_date) = 2024)
	and year(o.order_date) =2023
```

### 9. Cancellation Rate Comparison: 
-- Question: Calculate and compare the order cancellation rate for each restaurant between the current year and the previous year.

```sql
WITH previous_cancel_ratio AS 
(
    SELECT 
        r.restaurant_id,
        ROUND((CAST(COUNT(CASE WHEN d.delivery_status LIKE '%Not delivered%' THEN 1 END) AS FLOAT) / CAST(COUNT(*) AS FLOAT)) * 100, 2) AS [previous year cancelled ratio],
        YEAR(GETDATE()) - 1 AS year
    FROM 
        orders o
    LEFT JOIN 
        deliveries d ON d.order_id = o.order_id 
    JOIN	
        restaurants r ON r.restaurant_id = o.restaurant_id
    WHERE
        YEAR(o.order_date) = YEAR(GETDATE()) - 1 -- 2023
    GROUP BY 
        r.restaurant_id
),
current_cancel_ratio AS 
(
    SELECT 
        r.restaurant_id,
        ROUND((CAST(COUNT(CASE WHEN d.delivery_status LIKE '%Not delivered%' OR d.delivery_status IS NULL THEN 1 END) AS FLOAT) / CAST(COUNT(*) AS FLOAT)) * 100, 2) AS [current year cancelled ratio]
    FROM 
        orders o
    LEFT JOIN 
        deliveries d ON d.order_id = o.order_id 
    JOIN	
        restaurants r ON r.restaurant_id = o.restaurant_id
    WHERE
        YEAR(o.order_date) = YEAR(GETDATE()) -- 2024
    GROUP BY 
        r.restaurant_id
)
SELECT 
    pc.restaurant_id,
    pc.[previous year cancelled ratio],
    cc.[current year cancelled ratio]
FROM 
    previous_cancel_ratio pc
JOIN
    current_cancel_ratio cc ON pc.restaurant_id = cc.restaurant_id
ORDER BY 
    cc.restaurant_id ASC;
```

### 10. Rider Average Delivery Time: 
--Question: Determine each rider's average delivery time.

```sql
WITH cte1 AS
(
	SELECT 
		r.rider_id,
		r.rider_name,
		CASE 
			WHEN CAST(d.delivery_time AS DATETIME) >= CAST(o.order_time AS DATETIME) 
				THEN DATEDIFF(MINUTE, CAST(o.order_time AS DATETIME), CAST(d.delivery_time AS DATETIME))
			ELSE DATEDIFF(MINUTE, CAST(o.order_time AS DATETIME), DATEADD(DAY, 1, CAST(d.delivery_time AS DATETIME)))
		END AS total_delivery_time -- Adjust for day boundaries
	FROM orders o
	FULL JOIN deliveries d ON o.order_id = d.order_id
	FULL JOIN riders r ON r.rider_id = d.rider_id
	WHERE d.delivery_status = 'Delivered'
)
SELECT 
	rider_id,
	rider_name,
	AVG(total_delivery_time) AS [average time (in mins)]
FROM 
	cte1 c
GROUP BY
	c.rider_id,
	c.rider_name;
```

### 11. Monthly Restaurant Growth Ratio: 
--Question: Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

```sql
WITH cte1 AS
(
	SELECT 
		r.restaurant_name,
		MONTH(o.order_date) AS month_num,
		COUNT(*) AS current_month_sales,
		LAG(COUNT(*)) OVER (PARTITION BY r.restaurant_name ORDER BY MONTH(o.order_date)) AS previous_month_sales
	FROM 
		orders o 
	FULL JOIN
		restaurants r ON r.restaurant_id = o.restaurant_id
	FULL JOIN
		deliveries d ON d.order_id = o.order_id
	WHERE
		d.delivery_status = 'Delivered'
	GROUP BY
		MONTH(o.order_date),
		r.restaurant_name
)
SELECT 
	c.restaurant_name,
	c.current_month_sales,
	c.previous_month_sales,
	ROUND(((CAST(c.current_month_sales AS FLOAT) - CAST(c.previous_month_sales AS FLOAT)) / CAST(c.previous_month_sales AS FLOAT)) * 100, 2) AS growth_ratio
FROM 
	cte1 c
WHERE 
	c.previous_month_sales IS NOT NULL;
```

### 12. Customer Segmentation: 
-- Question: Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's total number of orders and total revenue

```sql
SELECT
	customer_id,
	SUM(total_amount) AS amount_spent,
	CASE 
		WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold'
		ELSE 'Silver'
	END AS category
FROM
	orders 
GROUP BY
	customer_id;
```

### 13. Rider Monthly Earnings: 
-- Question:  Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

```sql
SELECT 
    d.rider_id,
    COUNT(*) AS riders_total_orders,
    FORMAT(o.order_date, 'MM-yy') AS month_name,
    SUM(o.total_amount) AS revenue,
    (0.08 * SUM(o.total_amount)) AS rider_earnings
FROM 
    orders o
JOIN 
    deliveries d ON d.order_id = o.order_id
GROUP BY
    d.rider_id,
    FORMAT(o.order_date, 'MM-yy');

```

### Q.14 Rider Ratings Analysis: 
--Question:  Find the number of 5-star, 4-star, and 3-star ratings each rider has. Riders receive this rating based on delivery time.
If orders are delivered less than 15 minutes before the order received time the rider gets a 5-star rating, if they deliver within 15 and 20 minutes they get a 4-star rating if they deliver after 20 minutes they get 3-star rating.

```sql
WITH cte1 AS
(
    SELECT 
        d.rider_id,
        CASE
            WHEN d.delivery_time > o.order_time 
                THEN DATEDIFF(MINUTE, o.order_time, d.delivery_time)
            ELSE 
                DATEDIFF(MINUTE, o.order_time, DATEADD(DAY, 1, CAST(d.delivery_time AS DATETIME)))
        END AS delivery_time_diff
    FROM
        orders o
    JOIN 
        deliveries d ON d.order_id = o.order_id
),
cte2 AS
(
	SELECT 
		rider_id,
		delivery_time_diff,
		CASE    
			WHEN delivery_time_diff <= 15 THEN '5 Star'
			WHEN delivery_time_diff BETWEEN 15 AND 20 THEN '4 Star'
			ELSE '3 Star'
		END AS star_rating
	FROM 
		cte1
)
SELECT 
	rider_id,
	star_rating,
	COUNT(*) AS no_of_orders
FROM 
	cte2 
GROUP BY 
	rider_id,
	star_rating
ORDER BY 
	rider_id,
	star_rating DESC;

```

### Q.15 Order Frequency by Day: 
-- Question: Analyze order frequency per day of the week and identify the peak day for each restaurant.

```sql
SELECT 
    x.restaurant_name,
    x.weekday,
    x.total_orders
FROM
(
	SELECT 
		r.restaurant_id,
		r.restaurant_name,
		DATENAME(WEEKDAY, o.order_date) AS weekday,
		COUNT(*) AS total_orders,
		DENSE_RANK() OVER (PARTITION BY r.restaurant_id ORDER BY COUNT(*) DESC) AS rn
	FROM 
		orders o
	JOIN 
		restaurants r ON r.restaurant_id = o.restaurant_id
	GROUP BY
		r.restaurant_id,
		r.restaurant_name,
		DATENAME(WEEKDAY, o.order_date)
) AS x
WHERE 
    rn = 1
ORDER BY 
    weekday, 
    total_orders DESC;
```

### 16. Customer Lifetime Value (CLV): 
-- Question: Calculate the total revenue generated by each customer over all their orders.

```sql
select 
	c.customer_id,
	c.customer_name,
	sum(o.total_amount) as total_revenue
from 
	orders o
join 
	customers c
on c.customer_id = o.customer_id
group by	
	c.customer_name,
	c.customer_id
order by
	total_revenue desc;
```

### 17. Monthly Sales Trends: 
--Question: Identify sales trends by comparing each month's total sales to the previous month.

```sql
select 
	YEAR(order_date) AS YEARS,
	MONTH(order_date) AS MONTH_NAME,
	SUM(total_amount) AS TOTAL_SALES,
	LAG(SUM(total_amount),1) OVER(ORDER BY MONTH(order_date))
from 
	orders
GROUP BY
	YEAR(order_date),
	MONTH(order_date)
ORDER BY
	YEARS,
	MONTH_NAME;
```

### 18. Rider Efficiency: 
--Question: Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.

```sql

WITH CTE1 AS
(
	SELECT 
			D.rider_id,
			AVG(CASE
					WHEN d.delivery_time > o.order_time 
						THEN DATEDIFF(MINUTE, o.order_time, d.delivery_time)
					WHEN d.delivery_time < o.order_time 
						THEN DATEDIFF(MINUTE, o.order_time, DATEADD(DAY, 1, CAST(d.delivery_time AS DATETIME)))
				END) AS AVG_DELIVERY_TIME_DIFF
		FROM orders O
		JOIN deliveries D
		ON O.order_id = D.order_id
		GROUP BY D.rider_id
)

SELECT 
	X.rider_id,
	AVG_DELIVERY_TIME_DIFF AS DELIVERY_TIME
FROM
	CTE1 AS X
WHERE X.AVG_DELIVERY_TIME_DIFF = (SELECT MIN(AVG_DELIVERY_TIME_DIFF) FROM CTE1)
 OR X.AVG_DELIVERY_TIME_DIFF = (SELECT MAX(AVG_DELIVERY_TIME_DIFF) FROM CTE1)
ORDER BY DELIVERY_TIME DESC;
```

### 19. Order Item Popularity: 
--Question: Track the popularity of specific order items over time and identify seasonal demand spikes.

```sql
with seasons_table as
(
	select *,
		Case	
			WHEN MONTH(order_date) BETWEEN 4 AND 6 THEN 'Spring'
			WHEN MONTH(order_date) between 6 AND 8 THEN 'Summer'
			ELSE 'Winter'
		end as seasons
	from orders
)
select 
	order_item,
	seasons,
	COUNT(*) as total_orders
from seasons_table
group by
	seasons,
	order_item
order by 
	order_item,
	total_orders desc;
```

### 20. Rank each city based on the total revenue for the last year 2023
```sql
select 
	r.city,
	sum(o.total_amount) as total_revenue,
	DENSE_RANK() over(order by sum(o.total_amount) desc)
from orders o
join restaurants r
on r.restaurant_id = o.restaurant_id
where YEAR(o.order_date) = year(GETDATE()) -1
group by 
	r.city
order by total_revenue desc;
```

#### ---- End of Script ----
## Conclusion

This project highlights my ability to handle complex SQL queries and provide solutions to real-world business problems in the context of a food delivery service like Zomato.
The approach taken here demonstrates a structured problem-solving methodology, data manipulation skills, and the ability to derive actionable insights from data.
