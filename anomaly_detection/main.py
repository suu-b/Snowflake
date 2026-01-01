from snowflake.snowpark import Session
import os
from dotenv import load_dotenv
import logging
from datetime import datetime

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

connection_parameters = {
  "account": os.getenv('ACCOUNT'),
  "user": os.getenv('USER'),
  "password": os.getenv('PASSWORD'),
  "role": os.getenv('ROLE'), 
  "warehouse": os.getenv('WAREHOUSE')
}

def main():
  session = Session.builder.configs(connection_parameters).create()
  
  session.use_database('anomaly_detection')
  session.use_schema('nyc_taxi_set')
  
  incoming_rows = [(datetime(2015, 2, 1, 0, 0), 1015171)]
    
  test_df = session.create_dataframe(incoming_rows, schema=['timestamp', 'value'])
  test_df.create_or_replace_temp_view('incoming_data')
  
  session.sql("""
    call holmes!detect_anomalies(
    input_data => table(select * from incoming_data),
    timestamp_colname => 'timestamp',
    target_colname => 'value'
    )            
  """).show()
  
  
  
if __name__ == "__main__":
  main()