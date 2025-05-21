CREATE DATABASE Supermart_Grocery_Sales;
USE Supermart_Grocery_Sales;

SELECT * FROM supermart_grocery_sales;

ALTER TABLE supermart_grocery_sales
ADD COLUMN OrderDate1 DATE;
SET SQL_SAFE_UPDATES = 0;

UPDATE supermart_grocery_sales
SET OrderDate1 = CASE
    WHEN OrderDate LIKE '%/%' THEN STR_TO_DATE(TRIM(OrderDate), '%m/%d/%Y')   
    WHEN OrderDate LIKE '%-%' THEN STR_TO_DATE(TRIM(OrderDate), '%m-%d-%Y')   
    ELSE NULL
END
WHERE OrderDate IS NOT NULL;

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM supermart_grocery_sales;


#check for duplicates
SELECT OrderID, COUNT(*) AS count_order
FROM supermart_grocery_sales
GROUP BY OrderID
HAVING COUNT(*) > 1;

#check number of empty rows
SELECT * FROM supermart_grocery_sales
WHERE OrderID IS NULL 
   OR CustomerName IS NULL 
   OR City IS NULL
   OR Category IS NULL
   OR OrderDate1 IS NULL
   OR Region IS NULL
   OR Sales IS NULL
   OR Discount IS NULL
   OR Profit IS NULL
   OR State IS NULL;

#count number of empty rows
SELECT COUNT(*) AS empty_row_count FROM supermart_grocery_sales
WHERE OrderID IS NULL 
   OR CustomerName IS NULL 
   OR City IS NULL
   OR Category IS NULL
   OR OrderDate1 IS NULL
   OR Region IS NULL
   OR Sales IS NULL
   OR Discount IS NULL
   OR Profit IS NULL
   OR State IS NULL;

#1 How many total orders are there in the dataset?
select count(OrderID) from supermart_grocery_sales;

#2 List all the unique categories and sub-categories.

#Count of Unique Categories
SELECT COUNT(DISTINCT Category) FROM supermart_grocery_sales;
#Count of Unique SubCategories
SELECT COUNT(DISTINCT SubCategory) FROM supermart_grocery_sales;
#List of Unique Categories
SELECT DISTINCT Category FROM supermart_grocery_sales;
#List of Unique SubCategories
SELECT DISTINCT SubCategory FROM supermart_grocery_sales;

#3 Find the total sales(before discount), total profit, total cost and total discount
ALTER TABLE supermart_grocery_sales
ADD COLUMN cost INT,
ADD COLUMN sales_before_discount INT,
ADD COLUMN discount_amount INT;

SET SQL_SAFE_UPDATES = 0;
UPDATE supermart_grocery_sales 
SET 
discount_amount = Discount*Sales,
sales_before_discount = discount_amount+Sales,
cost = sales_before_discount - Profit - discount_amount;
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM supermart_grocery_sales;

SELECT ROUND(SUM(sales_before_discount), 0) AS total_sales_before_discount,
       ROUND(SUM(profit), 0) AS total_profit,
       ROUND(SUM(cost), 0) AS total_cost,
       ROUND(SUM(discount), 0) AS total_discount
FROM supermart_grocery_sales;

#4 Which cities have the highest number of orders?
SELECT City, COUNT(OrderID) AS total_orders FROM supermart_grocery_sales
GROUP BY City
ORDER BY total_orders DESC;

#5 Retrieve all orders made in the year 2017
select OrderID,CustomerName,Category,SubCategory,City,Region from supermart_grocery_sales
where year(OrderDate1)=2017;
#number of orders made in 2017
select count('OrderID') as number_of_orders_made from supermart_grocery_sales
where year(OrderDate1)=2017;

#6 What is the total sales(before_discount),cost and profit per category?
select Category, 
    sum(sales_before_discount) as total_sales_before_discount, 
	sum(cost)as total_cost, 
	round(sum(Profit),0) as total_profit  
from supermart_grocery_sales
group by Category
ORDER BY total_profit DESC, total_sales_before_discount DESC;

#7 Top 5 customer has made the highest number of purchases?
select CustomerName, count(CustomerName) as no_of_purchases from supermart_grocery_sales
group by CustomerName
ORDER BY count(CustomerName) DESC limit 5;

#8 Calculate the average discount given for each sub-category.
select SubCategory, round(avg(discount),2) as average_percentage_discount,round(avg(discount_amount),2) as average_discount from supermart_grocery_sales
group by SubCategory
order by average_percentage_discount desc, average_discount desc;

#9 Find the top 5 cities by total sales(before_discount) amount.
select City, sum(sales_before_discount) as total_sales_before_discount from supermart_grocery_sales
group by City
order by total_sales_before_discount desc limit 5;

#10	Show yearly sales trend for the entire dataset (extract year from Order Date).
SELECT year(OrderDate1) AS year,
       SUM(sales_before_discount) AS total_sales_before_discount
FROM supermart_grocery_sales
GROUP BY year
ORDER BY year;

#11	Show monthly sales trend for the entire dataset (extract month from Order Date).
SELECT MONTH(OrderDate1) AS month_number,
       MONTHNAME(OrderDate1) AS month_name,
       SUM(sales_before_discount) AS total_sales_before_discount
FROM supermart_grocery_sales
GROUP BY month_number, month_name
ORDER BY month_number;

#12 Which city has the highest profit margin (Profit/Sales)?
select City, round(sum(Profit)/sum(sales_before_discount),4) as profit_margin from supermart_grocery_sales
GROUP BY City
ORDER BY profit_margin desc;

#13 Find the top 3 most profitable sub-categories.
select SubCategory, round(sum(Profit)/sum(sales_before_discount),4) as profit_margin, round(sum(Profit),2) as total_profit from supermart_grocery_sales
group by SubCategory
ORDER BY profit_margin desc, total_profit desc
LIMIT 3;

#14 Identify the month and year when the maximum sales before discount happened.
select year(OrderDate1)as year , monthname(OrderDate1) as month_name,sum(sales_before_discount) as total_sales_before_discount from supermart_grocery_sales
group by year , month_name
order by total_sales_before_discount desc;

#15 Create a report showing sales,sales before discount, profit, discount amount, profit margin by city.
select City, 
sum(sales_before_discount) as total_sales_before_discount, 
sum(Sales) as total_sales,
round(sum(Profit),2) as total_profit,
sum(discount_amount) as total_discount,
round(sum(Profit)/sum(sales_before_discount),4) as profit_margin
from supermart_grocery_sales
group by City
order by profit_margin desc,total_profit desc,total_sales_before_discount desc, total_sales desc, total_discount desc;

#16	Find out if higher discounts are associated with lower profits.

SELECT 
    CASE 
        WHEN Discount BETWEEN 0 AND 0.1 THEN '0%-10%'
        WHEN Discount BETWEEN 0.1 AND 0.2 THEN '10%-20%'
        WHEN Discount BETWEEN 0.2 AND 0.3 THEN '20%-30%'
        WHEN Discount BETWEEN 0.3 AND 0.4 THEN '30%-40%'
        WHEN Discount > 0.4 THEN '>40%'
    END AS discount_range,
    ROUND(AVG(Profit), 2) AS avg_profit,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(*) AS number_of_orders
FROM supermart_grocery_sales
GROUP BY discount_range
ORDER BY discount_range;

#17 Find out if higher Profit Margin is associated with higher Sales Before Discount.
SELECT 
    ROUND(Sales_before_discount, 2) AS sales_before_discount,
    ROUND(SUM(Profit) / SUM(Sales_before_discount), 4) AS profit_margin
FROM supermart_grocery_sales
GROUP BY sales_before_discount
ORDER BY profit_margin DESC;

#18 How do Discount in percentange and Profit margin correlate over the years, and is there an optimal discount range for maximizing profit?
SELECT 
    YEAR(OrderDate1) AS year,
    CASE 
        WHEN Discount BETWEEN 0 AND 0.1 THEN '0%-10%'
        WHEN Discount BETWEEN 0.1 AND 0.2 THEN '10%-20%'
        WHEN Discount BETWEEN 0.2 AND 0.3 THEN '20%-30%'
        WHEN Discount BETWEEN 0.3 AND 0.4 THEN '30%-40%'
        WHEN Discount > 0.4 THEN '>40%'
    END AS discount_range,
    ROUND(AVG(Profit), 2) AS avg_profit,
    ROUND(AVG(Profit / Sales_before_discount), 4) AS avg_profit_margin
FROM supermart_grocery_sales
GROUP BY year, discount_range
ORDER BY year, discount_range;

#19 What is the total Sales Before Discount and Profit by SubCategory for each Year, and how do these vary across time?
SELECT 
    YEAR(OrderDate1) AS year,
    SubCategory,
    ROUND(SUM(sales_before_discount), 2) AS total_sales_before_discount,
    ROUND(SUM(Profit), 2) AS total_profit
FROM supermart_grocery_sales
GROUP BY year, SubCategory
ORDER BY year, total_sales_before_discount DESC;













