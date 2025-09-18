/*
=======================================================================================
stored proceduere: load silver layer (bronze -> silver)
=======================================================================================
script puprose:
      this stored proceduere performs the ETL (extract , transforme , load) process to
      populate the 'silver' schema tables from 'bronze' schema.
actions performed:
      - truncates silve tables.
      - inserts transformed and cleansed dat from 'bronze' into 'silver' tables.

parameters:
      none.
      this stored proceduere deos not accept any parameters or return any values.

usage example:
      EXEC silver.load_silver;
=======================================================================================
*/
create or alter procedure silver.load_silver as
begin

declare @start_time datetime , @end_time datetime ,
	    @batch_start_time datetime ,@batch_end_time datetime;
		set @batch_start_time = getdate();
	begin try
	set @batch_start_time = getdate();
	print '==============================================';
	print 'loading silver layer';
	print '==============================================';


	print '==============================================';
	print 'loading CRM ltables';
	print '==============================================';
	
	-- loading silver.crm_cust_ifo
	set @start_time = getdate();
	print '>> truncating table: silver.crm_cust_ifo';
	truncate table silver.crm_cust_info;

	print '>> inserting data into: silver.crm_cust_ifo';
	insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date)
	select
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case when upper(trim(cst_material_status)) = 'S' then 'single'
	   		 when upper(trim(cst_material_status)) = 'M' then 'Married'
			 else 'n/a'
		end  cst_material_status, -- normalize material status value to readable format
		case when upper(trim(cst_gndr)) = 'F' then 'Female'
	   		 when upper(trim(cst_gndr)) = 'M' then 'Male'
			 else 'n/a'
		end  cst_gndr,-- normalize gndr value to readable format
		cst_create_date
	from(
	select
	*,
		row_number() over(partition by cst_id order by cst_create_date desc) as flaglast
		from bronze.crm_cust_info
		where cst_id is not null
	)t
		where flaglast = 1 -- seslect most recent record per customer
		set @end_time = GETDATE();
		print'>>load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
		print'>> --------------------'
	---------------------------------------------------------------------------------	
	-- loading silver.crm_prd_info
	set @start_time = getdate();

	print '>> truncating table: silver.crm_prd_info';
	truncate table silver.crm_prd_info;
	print '>> inserting data into: silver.crm_prd_info';
	insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	select 
		prd_id,
		replace(substring(prd_key, 1, 5),'-','_') as cat_id,  -- extract category id
		substring(prd_key, 7 , len(prd_key)) as prd_key,      -- extract product key
		prd_nm,
		isnull(prd_cost, 0) as prd_cost,
		case upper(trim(prd_line))
			 when 'M' then  'Mountain'
			 when 'R' then 'Road'
			 when 'S' then 'Other Sales'
			 when 'T' then 'Touring'
			 else 'n/a'
		end prd_line, -- map product line codes to descriptive values
		cast (prd_start_dt as date) as prd_start_dt,
		cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) -1 
		as date)
		as prd_end_dt -- calculate end date as one day before the next start date
	from bronze.crm_prd_info
		set @end_time = GETDATE();
		print'>>load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
		print'>> --------------------'
	---------------------------------------------------------------------------------
	-- loading silver.crm_sales_detail
	set @start_time = getdate();

	print '>> truncating table: silver.crm_sales_detail';
	truncate table silver.crm_sales_detail;
	print '>> inserting data into: silver.crm_sales_detail';
	insert into silver.crm_sales_detail(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_orde_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)

	select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
	
		case
			 when sls_orde_dt <= 0 or len(sls_orde_dt) != 8 then null
			 else cast(cast(sls_orde_dt as varchar) as date)
		end sls_orde_dt,
	
		case
			 when sls_ship_dt <= 0 or len(sls_ship_dt) != 8 then null
			 else cast(cast(sls_ship_dt as varchar) as date)
		end sls_ship_dt,
	
		case
			 when sls_due_dt <= 0 or len(sls_due_dt) != 8 then null
			 else cast(cast(sls_due_dt as varchar) as date)
		end sls_due_dt,
	
		case 
			when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
			then sls_quantity * abs(sls_price)
			else sls_sales
		end sls_sales,
	
		sls_quantity,
	
		case 
			when sls_price is null or sls_price <= 0
			then abs(sls_price) / nullif(sls_quantity,0)
			else sls_price
		end sls_price

	from bronze.crm_sales_detail
		set @end_time = GETDATE();
		print'>>load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
		print'>> --------------------'

	---------------------------------------------------------------------------------
	-- loading silver.erp_cust_az12
	set @start_time = getdate();
	
	print '>> truncating table: silver.erp_cust_az12';
	truncate table silver.erp_cust_az12;
	print '>> inserting data into: silver.erp_cust_az12';
	insert into silver.erp_cust_az12(
		cid,
		bdate,
		gen
	)
	select
		case when cid like 'NAS%' then substring(cid,4, len (cid))
		else cid
		end as cid,
	

		case 
			when bdate > getdate() then null
			else bdate
		end as bdate,

		case
			when upper(trim(gen)) in('F' , 'FEMALE') then 'Female'
			when upper(trim(gen)) in ('M' , 'MALE') then 'Male'
			else 'n/a'
		end as gen
	from bronze.erp_cust_az12
		set @end_time = GETDATE();
		print'>>load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
		print'>> --------------------'
	---------------------------------------------------------------------------------
	-- loading silver.erp_loc_a101
	set @start_time = getdate();
	
	print '>> truncating table: silver.erp_loc_a101';
	truncate table silver.erp_loc_a101;
	print '>> inserting data into: silver.erp_loc_a101';
	insert into silver.erp_loc_a101(
		cid,
		cntry
	)
	select 
		replace(cid, '-','') as cid,
	
		case 
			when trim(cntry) in ('US', 'USA' , 'United States') then 'United States'
			when trim(cntry) in ('DE' , 'Germany') then 'Germany'
			when trim(cntry) = '' or cntry is null then 'n/a'
			else trim(cntry)
		end as cntry

	from bronze.erp_loc_a101
		set @end_time = GETDATE();
		print'>>load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
		print'>> --------------------'
	---------------------------------------------------------------------------------
	-- loading silver.erp_px_cat_g1v2
	print '>> truncating table: silver.erp_px_cat_g1v2';
	truncate table silver.erp_px_cat_g1v2;
	print '>> inserting data into: silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2(
		id,
		cat,
		subcat,
		maintenance
	)
	select 
		id,
		cat,
		subcat,
		maintenance
	from bronze.erp_px_cat_g1v2
		set @end_time = GETDATE();
		print'>>load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar)+ 'seconds';
		print'>> --------------------'


		set @batch_end_time = getdate();
		print'==========================================='
		print'loading silver layer completed' 
		print'>> total load duration:' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+ 'seconds';
		print'==========================================='
	
	end try
	begin catch
		print'==========================================='
		print'ERROR OCCURED DURING LOADING BRONZE LAYER'
		print'ERROR MESSAGE' + ERROR_MESSAGE();
		print'ERROR MESSAGE' + cast(ERROR_NUMBER() as nvarchar);
		print'ERROR MESSAGE' + cast(ERROR_STATE() as nvarchar);
		print'==========================================='
	end catch
end
