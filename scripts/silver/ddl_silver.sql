/*
=========================================================================================
DDL: script:create silver tables
=========================================================================================
script purpose:
      this script creats tables in the 'silver' schema, dropping existing tables
      if they already exist.
      runthis script to re_define the DDL structure of 'bronze' tables
=========================================================================================
*/
if object_id('silver.crm_cust_info','U') is not null
  drop table silver.crm_cust_info;
go
    
create table silver.crm_cust_info (
    cst_id              int,
    cst_key             nvarchar(50),
    cst_firstname       nvarchar(50),
    cst_lastname        nvarchar(50),
    cst_material_status nvarchar(50),
    cst_gndr            nvarchar(50),
    cst_create_date     date,
    dwh_create_date datetime2 default getdate()
);

if object_id('silver.crm_prd_info','U') is not null
  drop table silver.crm_prd_info;
go

create table silver.crm_prd_info (
    prd_id       int,
    cat_id       nvarchar(50),
    prd_key      nvarchar(50),
    prd_nm       nvarchar(50),
    prd_cost     int,
    prd_line     nvarchar(50),
    prd_start_dt date,
    prd_end_dt   date,
    dwh_create_date datetime2 default getdate()
);


if object_id('silver.crm_sales_detail','U') is not null
  drop table silver.crm_sales_detail;
go

create table silver.crm_sales_detail (
    sls_ord_num nvarchar(50),
    sls_prd_key  nvarchar(50),
    sls_cust_id  int,
    sls_orde_dt  date,
    sls_ship_dt  date,
    sls_due_dt   date,
    sls_sales    int,
    sls_quantity int,
    sls_price    int,
    dwh_create_date datetime2 default getdate()
);

if object_id('silver.erp_cust_az12','U') is not null
  drop table silver.erp_cust_az12;
go

create table silver.erp_cust_az12
(
    cid   nvarchar(50),
    bdate date,
    gen   nvarchar(50),
    dwh_create_date datetime2 default getdate()
);

if object_id('silver.erp_loc_a101','U') is not null
  drop table silver.erp_loc_a101;
go

create table silver.erp_loc_a101
(
    cid   nvarchar(50),
    cntry nvarchar(50),
    dwh_create_date datetime2 default getdate()
);

if object_id('silver.erp_px_cat_g1v2','U') is not null
  drop table silver.erp_px_cat_g1v2;
go

create table silver.erp_px_cat_g1v2
(
    id          nvarchar(50),
    cat         nvarchar(50),
    subcat      nvarchar(50),
    maintenance nvarchar(10),
    dwh_create_date datetime2 default getdate()
);
