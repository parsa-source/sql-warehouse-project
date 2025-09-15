/*
========================================================================
DDL script: create bronze tables
========================================================================
script purpose:
    this script creates tables in the 'bronze' schema, droppinf existing tables
    if they already exist.
    Run this script to re-define theDDL structure of 'bronze' tables

========================================================================
*/

if object_id('bronze.crm_cust_info','U') is not null
  drop table bronze.crm_cust_info;
go
    
create table bronze.crm_cust_info (
cst_id              int,
cst_key             nvarchar(50),
cst_firstname       nvarchar(50),
cst_lastname        nvarchar(50),
cst_material_status nvarchar(50),
cst_gndr            nvarchar(50),
cst_create_date     date
);

if object_id('bronze.crm_prd_info','U') is not null
  drop table bronze.crm_prd_info;
go

create table bronze.crm_prd_info (
prd_id       int,
prd_key      nvarchar(50),
prd_nm       nvarchar(50),
prd_cost     int,
prd_line     nvarchar(50),
prd_start_dt datetime,
prd_end_dt   datetime
);


if object_id('bronze.crm_sales_detail','U') is not null
  drop table bronze.crm_sales_detail;
go

create table bronze.crm_sales_detail (
sls_ord_num nvarchar(50),
sls_prd_key  nvarchar(50),
sls_cust_id  int,
sls_orde_dt  int,
sls_ship_dt  int,
sls_due_dt   int,
sls_sales    int,
sls_quantity int,
sls_price    int
);

if object_id('bronze.erp_cust_az12','U') is not null
  drop table bronze.erp_cust_az12;
go

create table bronze.erp_cust_az12
(
cid   nvarchar(50),
bdate date,
gen   nvarchar(50)
);

if object_id('bronze.erp_loc_a101','U') is not null
  drop table bronze.erp_loc_a101;
go

create table bronze.erp_loc_a101
(
cid   nvarchar(50),
cntry nvarchar(50)
);

if object_id('bronze.erp_px_cat_g1v2','U') is not null
  drop table bronze.erp_px_cat_g1v2;
go

create table bronze.erp_px_cat_g1v2
(
id          nvarchar(50),
cat         nvarchar(50),
subcat      nvarchar(50),
maintenance nvarchar(10)
);
