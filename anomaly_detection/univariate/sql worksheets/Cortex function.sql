-- use database ANOMALY_DETECTION;
-- use schema nyc_taxi_set;

-- -- I have the role to create the anomaly detection model
-- use role analyst;

-- create or replace snowflake.ml.anomaly_detection holmes(
--     input_data => table(select day as timestamp, daily_value as value from NYC_TAXI_V1_DAILY_FILLED order by day),
--     timestamp_colname => 'timestamp',
--     target_colname => 'value',
--     label_colname => ''
-- )

-- CREATE OR REPLACE TABLE nyc_taxi_future AS
-- SELECT DATEADD(day, 1, day) AS day, daily_value
-- FROM NYC_TAXI_V1_DAILY_FILLED;


-- CREATE OR REPLACE TABLE dummy_anomaly_test AS
-- WITH base AS (
--     SELECT
--         DATEADD(day, seq4(), '2026-01-01') AS day,
--         1000 + 
--         CASE MOD(seq4(), 7) 
--             WHEN 0 THEN 50   -- simulate weekday variation
--             WHEN 1 THEN -20
--             ELSE 0
--         END AS daily_value
--     FROM TABLE(GENERATOR(ROWCOUNT => 60))
-- )
-- SELECT 
--     day,
--     CASE 
--         WHEN day = '2026-01-10' THEN 1300  -- deliberate spike
--         WHEN day = '2026-01-25' THEN 700   -- deliberate drop
--         ELSE daily_value
--     END AS daily_value
-- FROM base
-- ORDER BY day;


-- CREATE OR REPLACE TABLE latest_day_anomaly AS
-- SELECT '2026-01-01'::DATE AS timestamp, 1200000 AS value;


-- call holmes!detect_anomalies(
--     input_data => table(select * from latest_day_anomaly),
--     timestamp_colname => 'timestamp',
--     target_colname => 'value'
-- )

-- CREATE OR REPLACE TABLE latest_day_normal AS
-- SELECT '2015-02-01'::DATE AS timestamp, 1015171 AS value;


-- call holmes!detect_anomalies(
--     input_data => table(select * from latest_day_normal),
--     timestamp_colname => 'timestamp',
--     target_colname => 'value'
-- )

select * from nyc_taxi_v1_daily_filled order by day desc;

