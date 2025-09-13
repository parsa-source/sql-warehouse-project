/*
=========================================================
create database and schemas
=========================================================
 script purpose:
      this script creates a new database named 'datawarehouse' after checking if it already exists.
      if database ecists, it will drop and recreate it. additionally, the script sets up three schemas
      with in the database:'bromze', 'silver', 'gold'.

WARNING:
      running this script will drop the entire 'datawarehouse' database if it exists.
      all data in the database will be permanently dalated. proceed with caution
      and ensure you have proper backups before running this script.
*/

use master;
go

-- drop and recreate the 'datawarehouse' database
if exists(select 1 from sys.databases where name = 'datawarehouse')
begin
  alter database datawarehouse set single_user with rollback immediate;
  drop database datawarehouse;
end;
go
  
-- cretae the 'datawarehouse' database  
create database datawarehouse;
go

use datawarehouse;
go

create schema bronze;
go
  
create schema silver;
go
  
create schema gold;
go
