from sqlalchemy import create_engine, text
import sqlparse
import pandas as pd

# Connection string format
# postgresql+psycopg2://username:password@host:port/database_name

postgres_host = 'localhost'
postgres_user = 'postgres'
postgres_password = '07064487301'
postgres_db = 'de_dw_demo'

conn_string = f'postgresql+psycopg2://{postgres_user}:{postgres_password}@{postgres_host}:5432/{postgres_db}'
engine = create_engine(conn_string)

# with open('sql_scripts/create_tables.sql', 'r') as file:
  #  query = file.read()

# with engine.begin() as conn:
   # conn.execute(text(query))


# with open('sql_scripts/insert_data.sql', 'r') as file:
    # query2 = file.read()

# with engine.begin() as conn:
   # conn.execute(text(query2))

with open ('sql_scripts/silver_tables.sql', 'r') as file:
    statements = file.read()

queries = sqlparse.split(statements)

with engine.begin() as conn:
    for query in queries:
        conn.execute(text(query))
        
        
print('Queries executed successfully!')

# read csv files into pandas df
#crm_cust_info = pd.read_csv('datasets/source_crm/cust_info.csv')
#crm_prd_info = pd.read_csv('datasets/source_crm/prd_info.csv')
#crm_sales_details = pd.read_csv('datasets/source_crm/sales_details.csv')

erp_cust = pd.read_csv('datasets/source_erp/CUST_AZ12.csv')
erp_loc = pd.read_csv('datasets/source_erp/LOC_A101.csv')
erp_px_cat = pd.read_csv('datasets/source_erp/PX_CAT_G1V2.csv')

# load the data into database tables

#crm_cust_info.to_sql('crm_cust_info', con = engine, schema='bronze', if_exists='append', index=False)
#print('crm_cust_info loaded successfully')
#crm_prd_info.to_sql('crm_prd_info', con=engine, schema='bronze', if_exists='append', index=False)
#print('crm_prd_info loaded successfully')
#crm_sales_details.to_sql('crm_sales_details', con=engine, schema='bronze', if_exists='append', index=False)
#print(print('crm_sales_details loaded successfully'))
#erp_cust.to_sql('erp_cust_az', con=engine, schema='bronze', if_exists='append', index=False)
#print('erp_cust loaded successfully')
#erp_loc.to_sql('erp_loc', con=engine, schema='bronze', if_exists='append',index=False)
#print('erp_loc loaded successfully')
#erp_px_cat.to_sql('erp_px_cat', con=engine, schema='bronze', if_exists='append', index=False)
#print('erp_px_cat loaded successfully')