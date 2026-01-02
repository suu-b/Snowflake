-- create role analyst;
grant usage on database anomaly_detection to role analyst;
grant usage on schema anomaly_detection.nyc_taxi_set to role analyst;
grant create snowflake.ml.anomaly_detection on schema anomaly_detection.nyc_taxi_set to role analyst;
grant role analyst to user SUUB;