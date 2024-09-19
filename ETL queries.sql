
select top 10 * from df_orders

-- Data Analysis using SQL
-- Business Problems


--1. find 10 highest reveneue generating products
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc

--2. find top 5 highest selling products in each region
select distinct region from df_orders


with cte as( 
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from (
select *
, ROW_NUMBER() over (partition by region order by sales desc ) as rn
from cte) A
where rn<=5


--3. Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as(
select distinct year(order_date) as order_year, sum(sale_price) as sales, MONTH(order_date) as order_month
from df_orders
group by year(order_date), month(order_date)

) 
select order_month
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

-- this was very new to learn


--4. for each category which month has highest sale
select top 5 * from df_orders
select distinct category  from df_orders


with cte as(
select category, sum (sale_price) as sales, format (order_date, 'yyyyMM')as order_month 
from df_orders
group by category,format (order_date, 'yyyyMM')
--order by category, format (order_date, 'yyyyMM') 
) 
select * from (
select *, 
ROW_NUMBER() over (partition by category order by sales desc) as rn

from cte ) a where rn=1






--5. which subcategory had highest growth by profit in 2023 as compared to 2022
select distinct sub_category from df_orders


select sub_category, sum(sale_price) as sales
where order_year 
from df_orders
group by sub_category



with cte as(
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date), month(order_date)
) 
, cte2 as (
select sub_category
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *,
(sales_2023- sales_2022)*100/sales_2022
from cte2 
order by (sales_2023- sales_2022)*100/sales_2022 desc


--6.  Identify the Most Popular Product by Total Quantity Sold
SELECT top 1 product_id, SUM(quantity) AS total_quantity_sold
FROM df_orders
GROUP BY product_id
ORDER BY total_quantity_sold DESC



--7.. Find the Day of the Week with the Highest Number of Orders
SELECT DATENAME(WEEKDAY, order_date) AS order_day, COUNT(order_id) AS total_orders
FROM df_orders
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY total_orders DESC;




--8. Identify the Most Profitable Products by Category
WITH cte AS (
    SELECT category, product_id, SUM(profit) AS total_profit
    FROM df_orders
    GROUP BY category, product_id
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_profit DESC) AS rn
    FROM cte
) ranked
WHERE rn = 1;


--9.  Identify Regions with the Largest Year-Over-Year Growth in Sales
WITH cte AS (
    SELECT region, YEAR(order_date) AS order_year, SUM(sale_price) AS total_sales
    FROM df_orders
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY region, YEAR(order_date)
),
cte2 AS (
    SELECT region,
           SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY region
)
SELECT *, ((sales_2023 - sales_2022) * 100.0 / sales_2022) AS sales_growth
FROM cte2
ORDER BY sales_growth DESC;



--10. Find the Total Revenue and Number of Orders for Each City

SELECT city, SUM(sale_price) AS total_revenue, COUNT(order_id) AS total_orders
FROM df_orders
GROUP BY city
ORDER BY total_revenue DESC;

