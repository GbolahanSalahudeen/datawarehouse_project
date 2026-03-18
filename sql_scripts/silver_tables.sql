CREATE SCHEMA IF NOT EXISTS silver;

-- create CRM tables
CREATE TABLE IF NOT EXISTS silver.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR,
    cst_firstname VARCHAR,
    cst_lastname VARCHAR,
    cst_marital_status VARCHAR,
    cst_gndr VARCHAR,
    cst_create_date DATE,
    dw_load_dt TIMESTAMP DEFAULT CURRENT_DATE
);

CREATE TABLE silver.crm_prd_info (
	prd_id int,
	cat_id varchar,
	prd_key varchar,
	prd_nm varchar,
	prd_cost int,
	prd_line varchar,
	prd_start_dt date,
	prd_end_dt date,
	dw_load_dt timestamp DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS silver.crm_sales_details (
    sls_ord_num VARCHAR,
    sls_prd_key VARCHAR,
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dw_load_dt TIMESTAMP DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS silver.erp_cust_az (
    cid VARCHAR,
    bdate DATE,
    gen VARCHAR,
    dw_load_dt TIMESTAMP DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS silver.erp_loc (
    cid VARCHAR,
    cntry VARCHAR,
    dw_load_dt TIMESTAMP DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS silver.erp_px_cat (
    id VARCHAR,
    cat VARCHAR,
    subcat VARCHAR,
    maintenance VARCHAR,
    dw_load_dt TIMESTAMP DEFAULT CURRENT_DATE
);