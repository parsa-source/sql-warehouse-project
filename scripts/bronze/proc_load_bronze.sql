/*
=====================================================================================
Stored procedure: load bronze layer (source -> bronze)
=====================================================================================
Script pupose:
    this stored procedure loads data into the 'bronze' schema from external CSV files.
    it performs the following actions:
    - Truncates the bronze table before loading data.
    - Use the 'BLUK INSERT' command to load data from CSV files to bronze tables.

parameters:
    None.
 this stored procedure deos not accept any parameters or return any values.

Usage example:
    EXEC bronze.load_bronze;
=====================================================================================
*/

create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time  datetime,@batch_end_time  datetime;
			set @batch_start_time = GETDATE();
	begin try
		print'======================================';
		print'loading bronze layer';
		print'======================================';

		print'--------------------------------------';
		print'loading CRM tables';
		print'--------------------------------------';
	
		set @start_time = GETDATE();
		print'>> truncating tables: bronze.crm_cust_info';
		truncate table bronze.crm_cust_info;

		print'>> insarting data into: bronze.crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'C:\SQL2022\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print'>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'>> ------------------'
	
		set @start_time = GETDATE();
		print'>> truncating tables: bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;

		print'>> insarting data into: bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\SQL2022\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print'>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'>> ------------------'



		set @start_time = GETDATE();
		print'>> truncating tables: bronze.crm_sales_detail';
		truncate table bronze.crm_sales_detail;

		print'>> insarting data into: bronze.crm_sales_detail';
		bulk insert bronze.crm_sales_detail
		from 'C:\SQL2022\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print'>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'>> ------------------'



 		print'--------------------------------------';
		print'loading ERP tables';
		print'--------------------------------------';
	

		set @start_time = GETDATE();		
		print'>> truncating tables: bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12;

		print'>> insarting data into: bronze.erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'C:\SQL2022\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print'>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'>> ------------------'


		set @start_time = GETDATE();
		print'>> truncating tables: bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101;

		print'>> insarting data into: bronze.erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'C:\SQL2022\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print'>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'>> ------------------'


		set @start_time = GETDATE();		
		print'>> truncating tables: bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2;

		print'>> insarting data into: bronze.erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\SQL2022\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print'>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'>> ------------------'



				set @batch_end_time = GETDATE();
		print'============================================'
		print'loading bronze layer completed'
		print'>> total load duration:' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + 'seconds';
		print'============================================'

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
