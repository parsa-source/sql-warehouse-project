/*
=================================================================================
product report
=================================================================================
purpose:
	- this report consolidate key product metrics and behaviors.

highlights:
	1. gathers essential fields such as product names, category, subcategory , and cost details.
	2. segments products by revenue to identify high-performers, mid-range, or low-performers.
	3. aggregates product-leve; metrics:
	   - total orders
	   - total sales
	   - total quantity sold
	   - total customers (unique)
	   - lifespan (in months)
	4. calculates valuable KPIs:
	   - recemcy (months since last sale)
	   - average order revenue (AOR)
	   - average monthly revenue
	   =================================================================================
*/
create view gold.report_products as

with base_query as(
/*--------------------------------------------------------------------------------------
1) base query: retrieves core columns from tables
--------------------------------------------------------------------------------------*/
	select
  	f.order_number,
  	f.customer_key,
  	f.order_date,
  	f.sales_amount,
  	f.quantity,
  	p.product_key,
  	p.product_name,
  	p.category,
  	p.subcategory,
  	p.cost
	from gold.fact_sales f
	left join gold.dim_products p
	on  f.product_key = p.product_key
	where order_date is not null -- only consider valid sales dates
)
,
product_aggregation as(
/*--------------------------------------------------------------------------------------
2) product_aggregation: summerizes key metrics at the customer level
--------------------------------------------------------------------------------------*/
	select
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		sales_amount,
		count(distinct order_number) as total_orders,
		sum(cost)					as total_cost,
		sum(sales_amount)			as total_sales,
		sum(quantity)				as total_quantity,
		count(distinct customer_key) as total_customers,
		max(order_date)				as last_order_date,
		datediff(month,min(order_date),max(order_date)) as lifespan,
		round(avg(cast(sales_amount as float) / nullif(quantity,0)),1) as avg_selling_price
	from base_query
	group by
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		sales_amount
)

/*--------------------------------------------------------------------------------------
3) final query : combines all product results into one output
--------------------------------------------------------------------------------------*/

select		
		product_key,
		product_name,
		category,
		subcategory,
		total_cost,
		last_order_date,
		datediff(month, last_order_date, getdate()) as recency_in_month,
    case 
    	 when total_sales > 50000 then 'high_performers'
    	 when total_sales >= 10000 then 'mid_range'
    	 else'low'
    end as product_segment,
    
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    
    -- comupate average order revenue (AOR)
    case 
    	when total_orders = 0 then 0
    	else total_sales / total_orders
    end as avg_order_revenue,
    -- comupate average monthly revenue
    case 
    	when lifespan = 0 then total_sales
    	else total_sales / lifespan
    end as avg_monthly_revenue
from product_aggregation
