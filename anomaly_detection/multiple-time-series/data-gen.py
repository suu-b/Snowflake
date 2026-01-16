import pandas as pd
import numpy as np
import logging
from pathlib import Path
from itertools import product
import os

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

def gen_data():    
    allowed_key_1 = ['key_1_a', 'key_1_b', 'key_1_c']
    allowed_key_2 = ['key_2_a', 'key_2_b', 'key_2_c']    
    allowed_key_3 = ['key_3_a', 'key_3_b', 'key_3_c']    
    
    start_date = '2024-01-16'
    end_date = '2026-01-16'

    as_of_dates = pd.date_range(start=start_date, end=end_date, freq='D').strftime('%Y-%m-%d').tolist()
    # logging.info(as_of_dates)
        
    # Data format
    # as_of_date,key_1,key_2,key_3,value
    # each row is uniquely identified by the combination of different values of the keys
    
    combinations = list(product(as_of_dates, allowed_key_1, allowed_key_2, allowed_key_3))
    # logging.info(len(combinations))    
    df = pd.DataFrame(combinations, columns=['as_of_date', 'key_1', 'key_2', 'key_3'])
    # logging.info(df.head())
    
    # df['value'] = np.random.uniform(100, 1000, size=len(df)).round(2)
    
    np.random.seed(42)
    value = np.random.normal(loc=2345, scale=0.002, size=len(df))
    df['value'] = value
    
    # Anomalies
    # logging.info(len(df))
    # Data length -> 19764
    indexes = [100_00, 500, 200, 400,110_00]
    for i in indexes:
        df.iloc[i, df.columns.get_loc('value')] += 200
    
    output = './data'
    os.makedirs(output, exist_ok=True)

    df.to_csv('./data/data.csv', index=False)
    
def main():
    logging.info("Hey suu-b!")
    logging.info("Generating Data:")
    gen_data()
    logging.info("Exiting...")
    
if __name__ == '__main__':
    gen_data()
    
    