/*
=====================================================================================================
DDL script: create gold view
=====================================================================================================
script purpose:
	this script create views for the gold layer in the data warehouse.
	the gold layer represents the final dimension and fact tables (star schema)

	each view performs transformations and combines data from the silver layer
	to produce a clean, enriched, and business-ready dataset.

usage:
	- these views can be quired directly for analytics and reporting.
=====================================================================================================
*/

-- ==================================================================================================
-- create dimension: gold.dim_customers
-- ==================================================================================================

if object_id('gold.dim_customers', 'v') is not null
	drop view gold.dim_customers;
go

create view  gold.dim_customers  as
select 
	row_number() over (order by cst_id) as customer_key,
	ci.cst_id		 as customer_id,
	ci.cst_key		 as customer_number,
	ci.cst_firstname as customer_firstname,
	ci.cst_lastname  as customer_lastname,
	co.cntry		 as country,
	case
		when ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the master for gender info
		else coalesce(ca.gen, 'n/a')
	end as gender,
	ci.cst_material_status as marital_status,
	ca.bdate			   as birth_date,
	ci.cst_create_date	   as create_date
from silver.crm_cust_info ci

left join silver.erp_cust_az12 ca
on			ci.cst_key = ca.cid

left join silver.erp_loc_a101 co
on		    ci.cst_key = co.cid

go

-- ==================================================================================================

-- ==================================================================================================
-- create dimension: gold.dim_products
-- ==================================================================================================

if object_id('gold.dim_products', 'v') is not null
	drop view gold.dim_products;
go

create view gold.dim_products as
select 
	row_number() over (order by pn.prd_start_dt,pn.prd_key) as product_key,
	pn.prd_id		 as product_id,
	pn.prd_key		 as product_number,
	pn.prd_nm		 as product_name,
	pn.cat_id		 as category_id,
	pc.cat			 as category,
	pc.subcat		 as subcategory,
	pc.maintenance,
	pn.prd_cost		 as cost,
	pn.prd_line		 as product_line,
	pn.prd_start_dt  as start_date
from silver.crm_prd_info pn

left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null -- filter out all historical data

go

-- ==================================================================================================

-- ==================================================================================================
-- create fact: gold.fact_sales
-- ==================================================================================================

if object_id('gold.fact_sales', 'v') is not null
	drop view gold.fact_sales;
go

create view gold.fact_sales as
select 
	sd.sls_ord_num   as order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_orde_dt   as order_date,
	sd.sls_ship_dt	 as shipping_date,
	sd.sls_due_dt	 as due_date,
	sd.sls_sales	 as sales_amount,
	sd.sls_quantity  as quantity,
	sd.sls_price	 as price
from silver.crm_sales_detail sd

left join gold.dim_products pr
on		sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
on		sd.sls_cust_id = cu.customer_id

go
