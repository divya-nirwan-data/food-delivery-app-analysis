
create database capstone;

use capstone;

select * from orders;
select * from ratings;
select * from customers;
select * from delivery_partners;
select * from restaurants;

-- Ques1. Count the total number of orders placed.

select count(order_id) as Total_orders from orders;

-- Ques2. Find the total revenue generated from all orders?

select sum(order_amount) as Total_Revenue from orders;

-- Ques3. Find the Average Order Value.

select round(sum(order_amount)/
count(order_id),2) as Average_Order_Value
from orders;

-- Ques4. If App commission is 25% , how much revenue does the app earn?

select sum(order_amount) * 0.25 as app_revenue
from orders;

-- Ques5. How much revenue do restaurants keep after commission?

select sum(order_amount)*0.75 as restaurant_revenue
from orders;

-- Ques6. Find order status wise total orders.

select order_status , count(order_id) as Total_Orders
from orders
group by order_status;

-- Ques7. Find the total number of unique customers who placed orders.

select count(distinct customer_id) as total_customers from customers;

-- Ques8. Find City wise Total Customers.

select city , count(customer_id) as Total_Customers 
from customers
group by city;

-- Ques9. Find Top 5 customers by orders.

select c.customer_name , count(order_id) as Total_order 
from orders o join customers c on o.customer_id = c.customer_id 
group by c.customer_name
order by total_order desc 
limit 5;

-- Ques10. Display Restaurant-Wise total revenue, sorted from highest to lowest.

select r.restaurant_name , sum(o.order_amount) as Revenue
from orders o join restaurants r on o.restaurant_id = r.restaurant_id
group by r.restaurant_name 
order by Revenue desc;


-- Ques11. Find the customer-wise total spending and show customer name.

select c.customer_name , sum(o.order_amount) as Total_Spent 
from orders o join customers c on o.customer_id = c.customer_id
group by c.customer_name;

-- Ques12. Display top 5 customers based on total order amount.

select c.customer_name , sum(o.order_amount) Total_order 
from orders o join customers c on o.customer_id = c.customer_id 
group by c.customer_name
order by total_order desc 
limit 5;

-- Ques13. Find restaurant wise average rating.

select restaurant_name , avg(rating) as Average_Rating
from restaurants
group by restaurant_name;

-- Ques14. List delivery partners and the number of orders delivered by each.

select d.partner_name , count(o.order_id) as total_deliveries
from delivery_partners d join orders o on d.partner_id = o.partner_id
group by d.partner_name;

-- Ques15. Find total orders by vehicle type.

select d.vehicle_type , count(o.order_id) as total_orders
from delivery_partners d join orders o on d.partner_id = o.partner_id 
group by vehicle_type
order by total_orders desc;

-- Ques16. Find the number of orders placed daily.

select order_date , count(order_id) as Total_orders 
from orders
group by order_date
order by order_date;

-- Ques17. Calculate monthly revenue trend(year and month).

select year(order_date) as Year , month(order_date) as Month,
sum(order_amount) as Revenue
from orders
group by year(order_date) , month(order_date)
order by Year , Month;

-- Ques18. Identify repeat customers (customers with more than 3 orders).

select customer_id , count(order_id) as order_count
from orders
group by customer_id
having count(order_id) >3;

-- Ques19. Find Top 3 restaurants by revenue for each month.

with monthly_revenue as 
(select restaurant_id , year(order_date) as Year,
month(order_date) as Month,
sum(order_amount) as Revenue
from orders
group by restaurant_id , year(order_date) , month(order_date)),
ranked_restaurants as
(select restaurant_id , year , month , revenue,
rank() over (partition by year , month order by revenue desc) as rk
from monthly_revenue)
select r.restaurant_name , year , month , revenue 
from ranked_restaurants rr
join restaurants r on rr.restaurant_id = r.restaurant_id
where rk <= 3;

-- Ques20. Calculate the cancellation percentage.

select round(sum(case when order_status = "Cancelled" then 1 else 0 end)*100/count(order_id),2) as Cancellation_Percentage
from orders;

-- Ques21. Use CTE to find Top 5 Customers by total spending.

with customer_spending as 
(select customer_id , sum(order_amount) as total_spent
from orders
group by customer_id)
select c.customer_name,
    cs.total_spent
FROM customer_spending cs
JOIN customers c 
    ON cs.customer_id = c.customer_id
ORDER BY cs.total_spent DESC
LIMIT 5;

-- Ques22. Rank restaurants based on total revenue using a Window function.

select r.restaurant_name , sum(o.order_amount) as Revenue,
rank() over (order by sum(o.order_amount) desc) as R_R
from orders o 
join restaurants r on o.restaurant_id = r.restaurant_id
group by restaurant_name;

-- Ques23. Find customers who have placed more orders than the average mumber of orders per customer.

select customer_id from orders 
group by customer_id 
having count(order_id) >
(select avg(cnt)
from (select count(order_id) as cnt
from orders 
group by customer_id)t);

-- Ques24. Find restaurants that have received at least one rating above the average rating.

select distinct restaurant_id
from restaurants
where rating >
(select avg(rating) from restaurants);

-- Ques25. Create a stored procedure that accepts a restaurant_id and returns its total_revenue.

delimiter //
create procedure restaurant_revenue(IN res_id varchar(10))
begin 
select sum(order_amount) as revenue 
from orders
where restaurant_id = res_id;
end //
delimiter ;

call restaurant_revenue('Res_021');

-- Change Data Type of order_date.

ALTER TABLE orders
ADD order_date_new DATE;

UPDATE orders
SET order_date_new = STR_TO_DATE(order_date, '%d-%m-%Y');

SELECT order_date, order_date_new
FROM orders
LIMIT 10;

ALTER TABLE orders DROP order_date;

ALTER TABLE orders
CHANGE order_date_new order_date DATE;

describe orders;

-- Ques26. Create a stored procedure that accepts
-- start_date
-- end_date
-- and returns total revenue per day within that range.

delimiter //
create procedure Get_Revenue_By_Date (
    IN start_date DATE,
    IN end_date DATE
)
begin
    select
        order_date,
        sum(order_amount) as total_revenue
    from orders
    where order_date between start_date and end_date
    group by order_date
    order by order_date;
end //
delimiter ;

Call Get_Revenue_By_Date('2024-01-01', '2024-01-31');

-- Ques27. Calculate CY Revenue.

select year(order_date) as year, sum(order_amount) as cy_revenue
from orders
where year(order_date) = 2025
group by year(order_date);

-- Ques28. Calculate PY Revenue

select year(order_date) as year, sum(order_amount) as revenue,
lag(sum(order_amount)) over (order by year(order_date)) as PY_Revenue
from orders
group by year(order_date)
order by year;

-- Ques29. Calculate the Year-over-Year (YOY) revenue growth by comparing each year’s revenue with the previous year.

select year(order_date) as year, sum(order_amount) as revenue,
lag(sum(order_amount)) over (order by year(order_date)) as prev_year_revenue,
round(
(sum(order_amount) - lag(sum(order_amount)) over (order by year(order_date)))
/ lag(sum(order_amount)) over (order by year(order_date)) * 100, 2
) as yoy_growth_pct
from orders
group by year(order_date);

-- Ques30. Calculate the Month-over-Month (MOM) revenue growth by comparing each month’s revenue with the previous month.

select curr.month, curr.revenue as current_month_revenue,
prev.revenue AS previous_month_revenue,
round((curr.revenue - prev.revenue) / prev.revenue * 100, 2) as mom_growth_pct
from
(select date_format(order_date, '%Y-%m') as month, sum(order_amount) AS revenue
from orders
group by date_format(order_date, '%Y-%m')) curr
left join
(select date_format(order_date, '%Y-%m') as month, sum(order_amount) AS revenue
from orders
group by date_format(order_date, '%Y-%m')) prev
on curr.month = date_format(date_sub(str_to_date(concat(prev.month, '-01'), '%Y-%m-%d'),
interval -1 month),'%Y-%m')
order by curr.month;




