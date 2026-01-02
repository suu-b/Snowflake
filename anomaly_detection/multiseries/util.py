# First consider adding headers to the table from A to AL in excel or notepad++
import pandas as pd
from datetime import datetime, timedelta
def main():
    # config
    base_time="2026-01-02 00:00:00"
    interval=1 # in seconds
    df = pd.read_csv('./dataset/smd_raw.csv')
    
    start_time = pd.to_datetime(base_time)
    df['timestamp'] = [start_time + timedelta(seconds=i*interval) for i in range(len(df))]
    df.to_csv('./dataset/smd.csv', index=False)

if __name__ == "__main__":
    main()