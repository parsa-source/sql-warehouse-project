**Data Dictionary for Gold Layer**
__________________________________________________________________________________________________________________________________________________
**Overview**
__________________________________________________________________________________________________________________________________________________                    
The Gold Layer is the business_level data representation, structured to support analytical and reporting use cases. It consists of **dimension
tables** and **fact tables** for specific business metrics.

__________________________________________________________________________________________________________________________________________________

1.**gold.dim_customers**

* Purpose: Stores customer details enriched with demographic and geographic data.
* Columns:

| Column Name | DataType |  Description  |
| ----------- | -------- |  -----------  |
|customer_key |INT  | Surrogate key uniquely identifying each customer record in the customer dimension table (e.g.,'1 , 2 ,...').  |
|customer_id |INT  | Unique numerical identifier assigned to each customer (e.g.,'11000 , 11001 ,...').  |
|customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and refrencing (e.g.,'AW00011000 , AW00011001 ,...').  |
|customer_firstname | NVARCHAR(50) |  The customer's first name, as recorded in the system (e.g.,'Jon , Janet ,...'). |
|customer_lastname | NVARCHAR(50) | The customer's last name or family name (e.g.,'Yang , Alvarez ,...').  |
|country | NVARCHAR(50) | The country of residence for customer (e.g.,'Germany'). |
|gender | NVARCHAR(50) | The gender of customer (e.g.,'Male , Female , n/a'). |
|marital_status | NVARCHAR(50) | The marital status of customer (e.g.,'Married , Single').  |
|birth_date | DATE | The date of birth of the customer, formatted as yyyy-MM-DD (e.g.,'1971-10-06').  |
|create_date | DATE | The date and time when customer record was created in the system |

__________________________________________________________________________________________________________________________________________________

2.**gold.dim_products**

* Purpose: Provides information about the products and thier attributes.
* Columns:

| Column Name | DataType |  Description  |
| ----------- | -------- |  -----------  |
|product_key |INT  | Surrogate key uniquely identifying each product record in the product dimension table.  |
|product_id |INT  | A unique identifier assigned to the product for internal tracking and referencing.  |
|product_number | NVARCHAR(50) | A structured alphanumeric code representing the product, often used for categorization or inventory .  |
|product_name | NVARCHAR(50) |  Descriptive name of the product, including key details such as type, color, and size(e.g, HL Road Frame_Black_58). |
|category_id| NVARCHAR(50) | A unique identifier for product's category, linking to its high_level classification.  |
|category | NVARCHAR(50) | The broader classification of the product (e.g, 'Bikes, Components') to group rlated items. |
|subcategory | NVARCHAR(50) | A more detailed classification of the product within the category, such as product type. |
|maintenance | NVARCHAR(50) | Indicates whether the product requires maintenance (e.g.,'Yes , No').  |
|cost | INT | The cost or base price of the product, measured in monetary units.  |
|product_line | NVARCHAR(50) | The specific product line or series to which the product belongs (e.g.,'Mountain , Road , Touring , ...').  |
|start_date | DATE | The date when the product became available for sale or use, stored in , formatted as yyyy-MM-DD (e.g.,'2003-07-01').  |

__________________________________________________________________________________________________________________________________________________

3.**gold.fact_sales**

* Purpose: Stores transactional sales data for analytical purposes.
* Columns:

| Column Name | DataType |  Description  |
| ----------- | -------- |  -----------  |
|order_number | NVARCHAR(50)  | A unique alphanumeric identifier for each sales order (e.g.,'SO43697 , SO43698 ,...').  |
|product_key |INT  | Surrogate key linkinng the order to the product dimension table.  |
|customer_key | INT | Surrogate key linkinng the order to the customer dimension table.  |
|order_date | DATE |  The date when the order was placed. |
|shipping_date| DATE | The date when the order was shipped to the customer.  |
|due_date | DATE | The date when the order payment was due. |
|sales_amount | INT | the total monetary value of the sale for the line item,in whole currency units (e.g,'25').  |
|quantity | INT | The number of units of the product ordered for the line item (e.g,'1').  |
|price | INT | The price per unit of the product for the line item, in whole currency units (e.g.,'25').  |
