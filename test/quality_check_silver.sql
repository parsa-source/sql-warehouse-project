/*
===============================================================================
quality checks
===============================================================================
script puprose:
    this script perfroms various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. it includes check for:
    -- null or duplicate primary keys.
    -- unwanted spaces in string fields.
    -- data standardization and consistency.
    -- invalid data ranges and orders.
    -- data consistency between related fields.

usage notes:
    - run these checks after data loading silver layer.
    - investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- checking 'silver.crm_cust_info'
-- ====================================================================
-- check for nulls or duplicates in primery key
-- expectation: no result

select 
  	cst_id,
  	count(*)
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-- check for unwanted spaces
-- expetation: no results
select 
    cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname)

-- check for unwanted spaces
-- expetation: no results
select 
    cst_lastname
from silver.crm_cust_info
where cst_lastname != trim(cst_lastname)

-- check for unwanted spaces
-- expetation: no results
select
    cst_key
from silver.crm_cust_info
where cst_key != trim(cst_key);

-- data standardization and consistency
select distinct 
    cst_material_status
from silver.crm_cust_info;


-- ====================================================================
-- checking 'silver.crm_prd_info'
-- ====================================================================
-- check for nulls or duplicates in primery key
-- expectation: no result
select 
	prd_id,
	count(*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null
 

-- check for invalid date orders
select*
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

-- check for unwanted spaces
-- expectation: no result
select 
	  prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm);

select distinct 
    prd_key
from bronze.crm_prd_info
where prd_end_dt<prd_start_dt
group by prd_key

-- check for nulls or negative values in cost
-- expectation: no result
select
	prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null;

-- data standardization and consistency
select 
  	distinct prd_line
from silver.crm_prd_info;

-- ====================================================================
-- checking 'silver.crm_sales_detail'
-- ====================================================================
-- chack for invalid dates
-- expectation: no result
select 
	  nullif(sls_ship_dt,0) as sls_ship_dt 
from bronze.crm_sales_detail
where sls_ship_dt <= 0 
    or len(sls_ship_dt) != 8 
    or sls_ship_dt > 20500101;
    or sls_ship_dt < 19000101;

-- chack for invalid date orders (order date > shiping/due date)
-- expectation: no result
select 
    * 
from bronze.crm_sales_detail
where sls_ship_dt < sls_orde_dt 
      or sls_orde_dt > sls_ship_dt;


-- check data consistency: between sales, quantity, and price
-- >> sales = quantity * price
-- >> valus ,ust not be null, 0 or nagative.
-- expectation: no result

select distinct
  	sls_sales,
  	sls_quantity,
  	sls_price 
from bronze.crm_sales_detail
where sls_sales != sls_quantity * sls_price 
    or sls_sales is null
    or sls_quantity is null
    or sls_price is null
    or sls_sales * sls_quantity * sls_price <= 0
order by sls_sales , sls_quantity , sls_price;

-- ====================================================================
-- checking 'silver.erp_cust_az12'
-- ====================================================================
-- identify out-of-range dates
-- expectation: birthdates between 1924-01-01 and today
select distinct
    bdate
from bronze.erp_cust_az12
where bdate < '1924-01-01' 
    or bdate > getdate()

-- data standardization and consistency
select distinct
    gen
from silver.erp_cust_az12
  

-- ====================================================================
-- checking 'silver.erp_loc_a101'
-- ====================================================================
-- data standardization and consistency
select distinct
cntry as old_cntry,
case 
	when trim(cntry) in ('US', 'USA' , 'United States') then 'United States'
	when trim(cntry) in ('DE' , 'Germany') then 'Germany'
	when trim(cntry) = '' or cntry is null then 'n/a'
	else trim(cntry)
end as cntry
from bronze.erp_loc_a101
order by cntry

-- data standardization and consistency
select distinct
    cntry
from silver.erp_loc_a101
order by cntry

  
-- ====================================================================
-- checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- check for unwanted spaces
-- expectation: no result
select
    *
from bronze.erp_px_cat_g1v2
where cat != trim(cat) 
    or subcat != trim(subcat) 
    or maintenance != trim(maintenance)

-- data standardization ans consistency
select distinct
	maintenance
from bronze.erp_px_cat_g1v2

-- checking for duplicates
-- expectation: no result
select 
    id,
    count(*)
from bronze.erp_px_cat_g1v2
group by id
having count(*)>1
