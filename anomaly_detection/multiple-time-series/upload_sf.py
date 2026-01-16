import pandas as pd
import logging
import os
from snowflake.snowpark import Session
from dotenv import load_dotenv

load_dotenv()

connection_parameters = {
  "account": os.getenv('ACCOUNT'),
  "user": os.getenv('USER'),
  "password": os.getenv('PASSWORD'),
  "role": os.getenv('ROLE'), 
  "warehouse": os.getenv('WAREHOUSE')
}

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

def main():
    session = Session.builder.configs(connection_parameters).create()  
    session.use_database('anomaly_detection')  
    
    table_name = "M_SERIES"
    tables = session.sql(
        f"SHOW TABLES LIKE '{table_name}'"
    ).collect()
    
    if tables:
        spdf = session.table(table_name)
        df = spdf.to_pandas()
        
    else:
        df = pd.read_csv('./data/data.csv')
        df.set_index('as_of_date')
        
        logging.info(df.head())
        spdf = session.create_dataframe(df)
        spdf.write.save_as_table(table_name, mode='overwrite')
        
if __name__ == '__main__':
    main()
    
    