/* 31. 'Top 5 customers' */
select 
		c.customerid,
		concat(c.firstname, ' ', c.lastname) as "Full_Name",
		sum(p.amount) as "Total_Paid",
		round(avg(p.amount),2) as "avg_per_order"
from customers c
join orders o on o.customerid = c.customerid 
join payments p on p.orderid =o.orderid
group by 1,2

/* 32. 'above AVG customers' */
with above_AVg as (
					select 
							c.customerid,
							concat(c.firstname, ' ', c.lastname ) as "full_name",
							sum(p.amount) as "total_spent"
					from customers c
					join orders o on o.customerid = c.customerid 
					join payments p on p.orderid = o .orderid 
					group by 1,2
					)
					
select
		"customerid",
		"full_name",
from above_AVg 
where total_spent > (select
							avg(total_spent)
					from above_AVg)
					
/* 33. 'Top order per Restaurant' */
with restaurant_rank as (
select
		r.restaurantname,
		concat(c.firstname,' ', c.lastname) as "Full_Name",
		sum(p.amount) as "Order_Amount",
		o.orderdate as "Order_Date",
		rank() over(partition by r.restaurantname order by sum(p.amount) desc) as "ranking"
from restaurants r
join orders o on o.restaurantid = r.restaurantid 
join customers c on c.customerid = o.customerid
join payments p on p.orderid = o.orderid 
group by 1,2,4)
select
		*
from restaurant_rank
where ranking = 1

/* 34. 'Top 3 Customers per Restaurant' */
with restaurant_rank as (
select
		r.restaurantname,
		concat(c.firstname,' ', c.lastname) as "Full_Name",
		sum(p.amount) as "Order_Amount",
		rank() over(partition by r.restaurantname order by sum(p.amount) desc) as "ranking_per_Restaurant"
from restaurants r
join orders o on o.restaurantid = r.restaurantid 
join customers c on c.customerid = o.customerid
join payments p on p.orderid = o.orderid 
group by 1,2)
select
		*
from restaurant_rank
where "ranking_per_Restaurant"  <= 3

/* 35. 'Calculation per Customer' */
select
		c.customerid,
		count(o.orderid) as "Total_Orders",
		sum(p.amount) as "Total_Amount",
		round(Avg(p.amount),2) as "AVG_Amount",
		case 
			when sum(p.amount) >= 5000 then 'VIP'
			when sum(p.amount) < 5000 and sum(p.amount) >= 2000 then 'Regular'
			when sum(p.amount) < 2000 then 'Low Value'
		end as "Customer_Type"
from customers c
join orders o on o.customerid =c.customerid 
join payments p on p.orderid = o.orderid 
group by 1
/* 36. 'Restaurants over AVG' */
with above_AVg as (
					select 
							r.restaurantname,
							sum(p.amount) as "total_revenue"
					from restaurants r
					join orders o on o.restaurantid = r.restaurantid
					join payments p on p.orderid = o .orderid 
					group by 1
					)
					
select
		"restaurantname",
		"total_revenue"
from above_AVg
where total_revenue > (select
							avg(total_revenue)
					from above_AVg)
					
/* 37. 'Calculation per Month' */
with calc as 
	(select
		extract(month from p.paymentdate) as "Month",
		count(p.orderid) as "Total_Orders",
		round(avg(p.amount),2) as "Average_Income",
		sum(p.amount) as "Total_Income"
from payments p 
group by 1)

select
		*,
		lag("Total_Income") over(order by "Month" ) as "Previous_Month_Income",
		"Total_Income" - lag("Total_Income") over(order by "Month" ) as "Difference"
from calc

/* 38. 'Min 2 Orders Customers' */
with row_rank as (
					select
							o.customerid,
							o.orderdate,
							p.amount,
							row_number() over(partition by o.customerid order by o.orderdate) as "first_order",
							row_number() over(partition by o.customerid order by o.orderdate desc) as "last_order"
					from orders o 
					join payments p on p.orderid  = o.orderid
				)
				
select 
		"customerid",
		max(
			case
				when "first_order" = 1 then "amount"
			end) as "first_order_amount"
			,
		max(case
				when "last_order" = 1 then "amount"
			end) as last_order_amount
			,
			count(*) as "Total_Orders"
			
from row_rank
group by 1 
having count(*) >=2 and max(
			case
				when "first_order" = 1 then "amount"
			end) 
			 > max(case
				when "last_order" = 1 then "amount"
			end
			)

					

/* 39. 'Employes Order Count' */
with oc as 
(
	select 
			e.employeeid,
			count(o.orderid) as "total"
	from orders o
	join employees e on e.employeeid = o.employeeid 
	group by 1
) 
			
select
		oc."employeeid",
		concat(e.firstname,' ', e.lastname) as "Full_Name",
		count(o.orderid) as "Orders_Count",
		concat(round(count(o.orderid)*100/sum("total"),2),'%') as "Percent_of_Total"
from oc  
join employees e on e.employeeid = oc.employeeid
join orders o on o.employeeid =e.employeeid 
group by 1,2
order by employeeid 

/* 40. 'Most Valuable Customer' */
select
		r.restaurantname,
		sum(p.amount) as "Total_Ravenue",
		count(o.orderid) as "Total_Orders",
		round(avg(p.amount),2) as "AVG_Amount_per_Orders",
		case 
			when rank() over(order by avg(p.amount) desc) <= 3 then 'Top'
			when rank() over(order by avg(p.amount) desc) <= 6 then 'Good'
			when rank() over(order by avg(p.amount) desc) > 6 then 'Standard'
		end as "Performance"
from restaurants r 
join orders o on o.restaurantid =r.restaurantid 
join payments p on p.orderid =o.orderid
group by 1 
order by 1 






