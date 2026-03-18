-- create gold layer schema
create schema if not exists gold;

-- create views for dimensions and facts in the gold layer

-- 1. Create dimension customers by joining the 3 customers tables in silver layer
create view gold.dim_customers as
select 
	row_number() over (order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	el.cntry as country,
	case
		when ci.cst_gndr is not null then ci.cst_gndr
		else cz.gen
	end as gender,
	ci.cst_marital_status as marital_status,
	cz.bdate as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az cz
on ci.cst_key = cz.cid
left join silver.erp_loc el
on ci.cst_key = el.cid;

-- 2. Create view for product dimension by joining the two products tables from silver layer
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;


-- 3. Create view for fact sales 
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

select * from silver.crm_sales_details;
select * from gold.dim_products;
select * from gold.dim_customers;

select * from gold.fact_sales;
select * from gold.dim_products;

-- a sample query to analyze the gold layer data
select 
	dp.product_name,
	sum(fs.sales_amount) as total_sales
from gold.fact_sales fs
left join gold.dim_products dp
	on fs.product_key = dp.product_key
group by dp.product_name;
	