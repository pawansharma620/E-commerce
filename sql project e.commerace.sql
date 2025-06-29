

-- =============================================
   -- E_COMMARCE PROJECT DATA ANALYTICS
-- =============================================

-- 1. CREATE DATABASE E_COMMERCE PROJECT

 create database e_commerce_project;
 
 -- 2. CREATE TABLES
 
 -- customer table
 create table customers
 (customer_id int primary key,
 name varchar(100),
 email varchar(100),
 city varchar(40),
 created_at date);
 
 -- product tables
 create table product
 (product_id int primary key,
 name varchar(100),
 price decimal(10.3),
 stock int);
 
 -- order tables
 create table orders_1
 (order_id int primary key,
 customer_id int,
 order_date date,
 total_amount decimal(10.2),
 foreign key(customer_id) references customers(customer_id));
 
 -- order items tables
 create table order_items
 (order_item_id int primary key,
 order_id int,
 product_id int,
 quantity int,
 price decimal(10.2),
 foreign key(order_id)references orders_1(order_id),
 foreign key(product_id)references product(product_id));
 
 -- payment tables
 create table payment
 (payment_id int primary key,
 order_id int,
 payment_method varchar(50),
 payment_status varchar(50),
 payment_date date,
 amount decimal(10.2),
 foreign key (order_id)references orders_1(order_id));
 
 
 -- 3. INSERT SAMPLE DATA
 
 insert into customers values
 (1,"pawan","pawwankumar@gmail.com","ranchi","2025-05-25"),
 (2,"chikki","chikki@gmail.com","dhanbad","2024-01-23"),
 (3,"pintu","pintu@gmail.com","hydrabad","2012-02-24"),
 (4,"sintu","sintu@gmail.com","jharkhand","2012-04-23"),
 (5,"shiv","shiv@gmail.com","pune","2025-03-25");
 
 
 insert into product values
 (101,"earphone",3000,40),
 (102,"mobile",32000,99),
 (103,"laptop",49000,10),
 (104,"chair",3000,29),
 (105,"table",4000,20);
 
 
 insert into orders_1 values
 (201,1,"2023-02-23",30000),
 (202,2,"2024-09-23",4500),
 (203,3,"2022-02-22",20000),
 (204,4,"2003-03-21",20000),
 (205,5,"2004-02-22",2023);
 
 
 insert into order_items values
 (1001,201,101,23,30000),
 (1002,202,102,59,40000),
 (1003,203,103,88,45000),
 (1004,204,104,78,3099),
 (1005,205,105,22,2000);
 
 
 insert payment values
 (11,201,"online","paid","2022-02-22",2000),
 (12,202,"cash","paid","2023-02-21",3440),
 (13,203,"cash","dues","2022-02-24",4500),
 (14,204,"onlne","paid","2024-04-24",299),
 (15,205,"online","paid","2011-11-21",2000);
 
 
-- 4. BASIS ANALYTICS QUERIES

-- * TOTAL SALES:

select sum(total_amount) as total_sales from orders_1;

-- * TOTAL CUSTOMERS:

select count(*) from customers;

-- * TOTAL REVENUE COLLECTED (PAID ORDERS ONLY)

select sum(AMOUNT) as total_revenue from payment
where payment_status ="paid";

-- * TOP 5 SELLING PRODUCTS:

select p.name, sum(oi.quantity) as total_sold
from order_items oi
join product p on oi.product_id = p.product_id
group by p.name
order by total_sold desc
limit 5;

-- * REVENUE BY PAYMENT METHOD 

select payment_method, sum(amount) as total_collection
from payment
where payment_status ="paid"
group by payment_method;

-- * (USING JOINS, CTEs)
-- *  MONTHLY REVENUE REPORT:

select date_format(order_date,'%y-%m') as month, sum(total_amount) as revenue
from orders_1
group by month
order by month;


-- * MONTHLY PAYMENT TREND

select date_format(payment_date, '%y-%m') as month, sum(amount) as revenue
from payment
where payment_status = "paid"
group by month
order by month;


-- * RETURNING VS NEW CUSTOMERS:

with first_order as (
select customer_id, min(order_date)as first_order_date
from orders_1
group by customer_id
)
select
    case
        when o.order_date = f.first_order_date then 'new'
        else 'returning'
        end as customer_types,
        count(distinct o.customer_id) as total_customer
        from orders_1 o
        join first_order f on o.customer_id = f.customer_id
        group by customer_types;

    -- * (USES WINDOW FUNCTION , STORED PROCEDURES, TRIGGERS)
	
        -- * RFM SCORE:
        
        select customer_id,
			  max(order_date)as last_purchase,
              datediff(curdate(), max(order_date)) as recency,
              count(order_id) as frequency,
              sum(total_amount) as monetory
	   from orders_1
       group by customer_id;
       
-- * STORED PROCEDURE: GENERATE MONTHLY SALES REPORTS

DROP PROCEDURE IF EXISTS generate_monthly_sales_report;

create procedure generate_monthly_sales_report(in report_month varchar(7))
begin
     select c.name,o.order_id,o.order_date,o.order_amount
     from orders_1 o
     join customer c on o.customer_id = c.customer_id
     where date_format(o.order_date,'%y-%m') = report_month;
end;

