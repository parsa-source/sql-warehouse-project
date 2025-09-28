***naming conventions***
____________________________________________________________

this document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

***table of contents***
__________________________________________________________

1. generate principles
2. table naming conventions
	* bronze rules
	* silver rules
	* gold   rules
3. column naming conventions
	* surrogate keys
	* technical columns
4. stored procedure

______________________________________________________________________

***general principles***

  * naming conventions: use snake_case , with lowercase letters and underscore(_) to separate words.
  * language: use english for all names.
  * avoid reserved words: do not use SQL reserved words as object names.


______________________________________________________________________

***table naming conventions***


bronze rules

  * all names must start with the source system name, and table names must match their original names without renaming.
  * (sourcesystem)_(entity)
  
        1.<sourcesystem>:name of the source system(e.g, crm, erp).
        2.<entity>:exact table name from the source system.
        3.example: crm_customer_info -> customer information from the CRM system.

silver rules

  * all names must start with the source system name, and table names must match their original names without renaming.
  * (sourcesystem)_(entity)
    
	      1.<sourcesystem>:name of the source system(e.g, crm, erp).
	      2.<entity>:exact table name from the source system.
	      3.example: crm_customer_info -> customer information from the CRM system.


gold rules

  * all names must use meaningful, business-aligned names for tables, starting with the category prefix.
  
  * (category)_(entity)
  
        1. <category>:describes the role of the table, such as (dim) as dimension or (fact) as fact table.
        2. <entity>:descriptive name of the table, aligned with the business domain(e.g, customers, products, sales).
        3. example:
                dim_customers -> dimension table for customer data. 
                fact_sales    -> fact table containing sales transactions.


***glossy of category patterns***

|pattern|meaning|example(s)|
|-------|-------|----------|
|dim_|dimension table|dim_customer, dim_product|
|fact_|fact table|fact_sales|
|egg_|aggregated table|agg_customers, agg_sales_monthly|


***column naming convention***
______________________________________________________________________

***surrogate keys***
  
  * all primary keys in dimension tables must use suffix (_key).
  * <table_name>_key
    
      	1. <table_name>:refers to the name of the table or entity the key belongs to.
	      2. _key : a suffix indicating that this column is a surrogate key.
	      3. example: (customer_key) -> surrogate key in the (dim_customers) table.

***technical columns***

  *all technical columns must start with the prefix (dwh_), followed by a descriptive name indicating the column's purpose.
  * dwh_<<column_name>
    
	      1. dwh : prefix exclusively for system-generated metadata.
	      2. <<column_name> : descriptive name indicating the column's purpose.
	      3. example: dwh_load_date -> system-generated column used to store the date when the record was loaded.


***stored procedure***
________________________________________________________________________

  * all stored procedures used for loading data must follow the naming pattern (load_(layer)).
      1. (layer): represents the layer beign loaded, such as (bronze) , (silver) or (gold).
      2. example:
            
            1. load_bronze -> stored procedure for loading into the bronze layer.
            2. load_silver -> stored procedure for loading into the silver layer. 

