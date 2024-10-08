#Basic

#1.total order placed

select count(order_id) as total_orders
from orders


#2.total revenue from pizzas

select
round(sum(pz.price*od.quantity)) as total_sales
from order_details od left join pizzas pz
on
od.pizza_id=pz.pizza_id



#3.highest prize rated


select pt.name as pizza_name, pz.price as price
from pizzas pz join pizza_types pt on
pz.pizza_type_id=pt.pizza_type_id
order by price desc limit 1;

#4.most common pizza size ordered 

select pz.size as size,count(od.quantity) as qty
from order_details od join pizzas pz on 
od.pizza_id=pz.pizza_id 
group by size
order by qty desc limit 1;



#5.top 5 most ordered pizza types

select pt.name,sum(od.quantity) as qty
from order_details od join pizzas pz
on
od.pizza_id=pz.pizza_id
join pizza_types pt
on
pz.pizza_type_id=pt.pizza_type_id
group by pt.name
order by qty desc limit 5;

#Intermediate

#1.total qty of each pizza category ordered

select pt.category,sum(od.quantity) as qty
from order_details od join pizzas pz on
od.pizza_id=pz.pizza_id
join pizza_types pt on
pz.pizza_type_id=pt.pizza_type_id
group by pt.category
order by qty desc;

#2.Determine the distribution of orders by hour of the day.

select hour(od.order_time) as timing,count(od.order_id) as counting
from orders od
group by timing


#3.Join relevant tables to find the category-wise distribution of pizzas.

select pt.category,count(pt.name) as name
from pizza_types pt 
group by pt.category


#4.Group the orders by date and calculate the average number of pizzas ordered per day.


select round(avg(qty)) from 
(select ors.order_date,sum(od.quantity) as qty
from orders ors join order_details od on
ors.order_id=od.order_id
group by ors.order_date) as avg_per_day_order_quantity;



#5.Determine the top 3 most ordered pizza types based on revenue.


select pz.pizza_type_id,sum(od.quantity*pz.price) as revenue
from order_details od join pizzas pz on
od.pizza_id=pz.pizza_id
group by pz.pizza_type_id
order by revenue desc limit 3;

#Advanced

#1.Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category,
ROUND(SUM(pz.price * od.quantity) / 
(SELECT SUM(pz.price * od.quantity) FROM order_details od JOIN pizzas pz ON pz.pizza_id = od.pizza_id) * 100, 2) AS revenue
FROM pizza_types pt
JOIN pizzas pz ON pt.pizza_type_id = pz.pizza_type_id
JOIN order_details od ON pz.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC
LIMIT 5;

#2.Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from 
(select orde.order_date,round(sum(pz.price*od.quantity),2) as revenue
from order_details od join pizzas pz  on od.pizza_id = pz.pizza_id
join orders orde on od.order_id = orde.order_id
group by orde.order_date) as sales

#3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue
from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pt.category,pt.name, sum(pz.price*od.quantity) AS revenue
from order_details od join pizzas pz on od.pizza_id=pz.pizza_id
join pizza_types pt on pz.pizza_type_id=pt.pizza_type_id
group by pt.category,pt.name) as  A) as B
where rn<=3;

