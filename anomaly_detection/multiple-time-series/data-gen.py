import pandas as pd
import numpy as np
import logging
from itertools import product
import random
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
    end_date = '2027-01-16'

    as_of_dates = pd.date_range(start_date, end_date, freq='D')
    # logging.info(as_of_dates)
    n_dates = len(as_of_dates)
    last_year_start = (n_dates // 3) *2
        
    np.random.seed(42)
    random.seed(42)
    
    rows = []
    
    for k1, k2, k3 in product(allowed_key_1,allowed_key_2,allowed_key_3):
        base_value = random.randint(1000, 10000)
        values = np.random.normal(loc=base_value, scale=0.002, size=n_dates)
        
        anomaly_idx = np.random.choice(
            range(last_year_start, n_dates),
            size = 5,
            replace=False
        )
        
        values[anomaly_idx] += 50
        
        for dt, val in zip(as_of_dates, values):
            rows.append((dt, k1, k2, k3, val))
            
    df = pd.DataFrame(
        rows,
        columns=['as_of_date', 'key_1', 'key_2', 'key_3', 'value']
    )
    
    output = './data'
    os.makedirs(output, exist_ok=True)

    df.to_csv('./data/data.csv', index=False)
    # df.to_csv(
    #     "./data/data.csv.zip",
    #     index=False,
    #     compression="zip"
    # )
    
def main():
    logging.info("Hey suu-b!")
    logging.info("Generating Data:")
    gen_data()
    logging.info("Exiting...")
    
if __name__ == '__main__':
    main()
    
    