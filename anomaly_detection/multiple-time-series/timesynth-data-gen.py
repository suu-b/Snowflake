import pandas as pd
import numpy as np
import logging
from itertools import product
import os
import timesynth as ts

np.random.seed(42)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

def gen_data():    
    start_date = pd.to_datetime('2023-01-01')
    end_date = pd.to_datetime('2025-12-31')
    
    n_days = (end_date - start_date).days + 1
    
    logging.info(f"Generating {n_days} days of data per series...")
    
    time_sampler = ts.TimeSampler(stop_time=n_days)
    regular_time_samples = time_sampler.sample_regular_time(num_points=n_days)
    
    allowed_key_1 = ['key_1_a', 'key_1_b', 'key_1_c']
    allowed_key_2 = ['key_2_a', 'key_2_b', 'key_2_c']
    allowed_key_3 = ['key_3_a', 'key_3_b', 'key_3_c']
    
    combinations = list(product(allowed_key_1, allowed_key_2, allowed_key_3))
    all_series_data = []
    
    for k1, k2, k3 in combinations:
        base_value = np.random.randint(500, 15000) 
        trend_slope = np.random.uniform(-0.02, 0.08)         
        signal = ts.signals.Sinusoidal(frequency=1/7, amplitude=base_value * 0.05)        
        noise = ts.noise.GaussianNoise(std=base_value * 0.015)
        timeseries = ts.TimeSeries(signal_generator=signal, noise_generator=noise)
        samples, _, _ = timeseries.sample(regular_time_samples)
        samples = base_value + (trend_slope * regular_time_samples) + samples       
        
        anomaly_start_date = pd.to_datetime('2025-01-01')
        
        # Anomaly Injection
        dates = pd.date_range(start=start_date, periods=n_days, freq='D')
        is_2025 = dates >= anomaly_start_date
        
        spike_indices = np.random.choice(np.where(is_2025)[0], size=5, replace=False)
        samples[spike_indices] += base_value * np.random.uniform(0.3, 0.6)
        
        # shift_start = np.random.choice(np.where(dates >= '2025-07-01')[0])
        # samples[shift_start:] += base_value * 0.2
        
        samples = np.maximum(0, samples)
        
        temp_df = pd.DataFrame({
            'as_of_date': pd.date_range(start=start_date, periods=n_days, freq='D'),
            'key_1': k1,
            'key_2': k2,
            'key_3': k3,
            'value': samples
        })
        all_series_data.append(temp_df)
        
    df = pd.concat(all_series_data, ignore_index=True)
    
    output_dir = './data'
    os.makedirs(output_dir, exist_ok=True)
    df.to_csv(f'{output_dir}/ts_data.csv', index=False)
    
    logging.info(f"Successfully saved {len(df)} rows to {output_dir}/data.csv")

def main():
    logging.info("Starting synthetic data generation...")
    gen_data()
    logging.info("Process complete.")
    
if __name__ == '__main__':
    main()