CREATE TABLE IF NOT EXISTS bronze.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR,
    cst_firstname VARCHAR,
    cst_lastname VARCHAR,
    cst_marital_status VARCHAR,
    cst_gndr VARCHAR,
    cst_create_date VARCHAR
);

CREATE TABLE IF NOT EXISTS bronze.crm_prd_info(
    prd_id INT,
    prd_key VARCHAR,
    prd_nm VARCHAR,
    prd_cost INT,
    prd_line VARCHAR,
    prd_start_dt VARCHAR,
    prd_end_dt VARCHAR
);

CREATE TABLE IF NOT EXISTS bronze.crm_sales_details(
    sls_ord_num VARCHAR,
    sls_prd_key VARCHAR,
    sls_cust_id INT,
    sls_order_dt VARCHAR,
    sls_ship_dt VARCHAR,
    sls_due_dt VARCHAR,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

CREATE TABLE IF NOT EXISTS bronze.erp_cust_az(
    cid VARCHAR,
    bdate VARCHAR,
    gen VARCHAR
);

CREATE TABLE IF NOT EXISTS bronze.erp_loc(
    cid VARCHAR,
    cntry VARCHAR
);

CREATE TABLE IF NOT EXISTS bronze.erp_px_cat(
    id VARCHAR,
    cat VARCHAR,
    subcat VARCHAR,
    maintenance VARCHAR
);