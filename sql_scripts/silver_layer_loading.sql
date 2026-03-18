-- transform bronze tables and insert into silver layer tables

-- 1. table crm_cust_info
TRUNCATE TABLE silver.crm_cust_info;
insert into silver.crm_cust_info (
	cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
select 
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	case upper(cst_marital_status)
		when 'M' then 'Married'
		when 'S' then 'Single'
		else 'n/a'
	end as cst_marital_status,
	case upper(cst_gndr)
		when 'M' then 'Male'
		when 'F' then 'Female'
	end as cst_gndr,
	cast(cst_create_date as date) as cst_create_date
from (
	select *,
		row_number() over (partition by cst_id order by cst_create_date desc) as rn
	from bronze.crm_cust_info
	where cst_id is not null
) temp_table
where rn = 1;

-- 2. table crm_prd_info
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
	SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key,        -- Extract product key
	prd_nm,
	coalesce(prd_cost, 0) as prd_cost,
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line, -- Map product line codes to descriptive values
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) as date)-1 as prd_end_dt
FROM bronze.crm_prd_info;

-- 3. table crm_sales_details
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE 
		WHEN CAST(sls_order_dt AS INT) = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL 
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE 
		WHEN CAST(sls_ship_dt AS INT) = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE 
		WHEN CAST(sls_due_dt AS INT) = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
	sls_quantity,
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / COALESCE(sls_quantity, 0)
		ELSE sls_price  -- Derive price if original value is  invalid
	END AS sls_price
FROM bronze.crm_sales_details;

-- 4. table erp_cust_az
TRUNCATE TABLE silver.erp_cust_az;
INSERT INTO silver.erp_cust_az (
	cid,
	bdate,
	gen 
)
SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, length(cid)) -- Remove 'NAS' prefix if present
		ELSE cid
	END AS cid, 
	CASE
		WHEN cast(bdate as date) > current_date THEN NULL
		ELSE cast(bdate as date)
	END AS bdate, -- Set future birthdates to NULL
	CASE
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen -- Normalize gender values and handle unknown cases
FROM bronze.erp_cust_az;


-- 5. table erp_loc
TRUNCATE TABLE silver.erp_loc;
INSERT INTO silver.erp_loc (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid, 
	CASE
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry) 
	END AS cntry -- Normalize and Handle missing or blank country codes
FROM bronze.erp_loc;

-- 6. table erp_px_cat
TRUNCATE TABLE silver.erp_px_cat;
INSERT INTO silver.erp_px_cat (
	id,
	cat,
	subcat,
	maintenance
)
SELECT
	id,
	trim(cat) as cat,
	trim(subcat) as subcat,
	trim(maintenance) as maintenance
FROM bronze.erp_px_cat;