/*
================================================================================
quality checks
================================================================================
script purpose:
	this script performs quality checks to validate the integrity,
	consistency and accuracy of the gold layer. these checks ensure:
	- uniqueness of surrogate keys in deimension tables.
	- referential integrity between fact and dimension tables.
	- validation of relationships in the data ,odel for analytical purposes.

usage notes:
	- run these checks after data loading silver layer.
	- investigate and resolve any discrepancies found during the checks.
================================================================================
*/

-- =============================================================================
-- checking: 'gold.dim_customers'
-- =============================================================================
-- checking for uniqueness of customer key in gold.dim_customers
-- expectation : no result
select
	customer_key,
	count(*) as duplicate_count
from gold.dim_customers

group by customer_key
having count(*) > 1;


-- =============================================================================
-- checking: 'gold.dim_products'
-- =============================================================================
-- checking for uniqueness of product key in gold.dim_products
-- expectation : no result
select
	product_key,
	count(*) as duplicate_count
from gold.dim_products

group by product_key
having count(*) > 1;


-- =============================================================================
-- checking: 'gold.fact_sales'
-- =============================================================================
-- checking the data model connctivity between fact and dimensions
select *
from	   gold.fact_sales	  f

left join  gold.dim_customers c
on		   c.customer_key = f.customer_key

left join  gold.dim_products  p
on		   p.product_key = f.product_key
where	   p.product_key is null or c.customer_key is null
