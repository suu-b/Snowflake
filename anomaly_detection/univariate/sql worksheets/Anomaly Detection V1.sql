-- select * from nyc_taxi_v1 limit 10;

-- To check sanity
-- SELECT
--     MIN(timestamp) AS min_ts,
--     MAX(timestamp) AS max_ts,
--     COUNT(*) AS total_count
-- FROM nyc_taxi_v1;

-- Timestamps are too fine, we collected them into days
-- create or replace table nyc_taxi_v1_daily as 
-- select 
--     date(timestamp) as day,
--     sum(value) as daily_value
-- from nyc_taxi_v1
-- group by day
-- order by day;

-- select * from nyc_taxi_v1_daily limit 10;

-- select dayofweek(day) as dow,
--     avg(daily_value) as avg_value
-- from nyc_taxi_v1_daily 
-- group by dow
-- order by dow;

-- The Intellectual core:
-- The Rolling mean and rolling std dev of the same day

-- create or replace table nyc_taxi_v1_baseline as 
-- select day, daily_value, dayofweek(day) as dow, 
--     avg(daily_value) over (
--         partition by dayofweek(day)
--         order by day
--         rows between 8 preceding and 1 preceding
--     ) as baseline_mean,

--     stddev(daily_value) over (
--         partition by dayofweek(day)
--         order by day
--         rows between 8 preceding and 1 preceding
--     ) as baseline_std
-- from nyc_taxi_v1_daily;

-- select * from nyc_taxi_v1_baseline;

-- AT THIS POINT WE GOT TO KNOW THAT SOME MID-ROWS IN THE BASELINE HAD NULLS. WE CANNOT MOVE FORWARD. SO WE ARE WORKING AROUND.

-- CREATE OR REPLACE TABLE calendar AS
-- SELECT
--     DATEADD(day, seq4(), start_date) AS day
-- FROM (
--     SELECT MIN(day) AS start_date
--     FROM nyc_taxi_v1_daily
-- ),
-- TABLE(GENERATOR(ROWCOUNT => 10000));

-- DELETE FROM calendar
-- WHERE day > (SELECT MAX(day) FROM nyc_taxi_v1_daily);

-- DROP TABLE nyc_taxi_daily_filled;

-- CREATE OR REPLACE TABLE nyc_taxi_v1_daily_filled AS
-- SELECT
--     c.day,
--     COALESCE(d.daily_value, 0) AS daily_value
-- FROM calendar c
-- LEFT JOIN nyc_taxi_v1_daily d
--     ON c.day = d.day
-- ORDER BY c.day;

-- select * from nyc_taxi_v1_daily_filled;

-- CREATE OR REPLACE TABLE nyc_taxi_v1_baseline AS
-- SELECT
--     day,
--     daily_value,
--     DAYOFWEEK(day) AS dow,

--     AVG(daily_value) OVER (
--         PARTITION BY DAYOFWEEK(day)
--         ORDER BY day
--         ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING
--     ) AS baseline_mean,

--     STDDEV(daily_value) OVER (
--         PARTITION BY DAYOFWEEK(day)
--         ORDER BY day
--         ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING
--     ) AS baseline_std
-- FROM nyc_taxi_v1_daily_filled;


-- select * from nyc_taxi_v1_baseline;
-- SELECT day
-- FROM nyc_taxi_v1_baseline
-- WHERE dow = 3
-- ORDER BY day;

-- The anomalies table
-- CREATE OR REPLACE TABLE nyc_taxi_v1_anomalies AS
-- SELECT
--     day,
--     daily_value,
--     baseline_mean,
--     baseline_std,
--     (daily_value - baseline_mean) / baseline_std AS z_score,
--     CASE
--         WHEN baseline_std IS NULL THEN NULL
--         WHEN ABS((daily_value - baseline_mean) / baseline_std) >= 3 THEN TRUE
--         ELSE FALSE
--     END AS is_anomaly
-- FROM nyc_taxi_v1_baseline;


-- select * from nyc_taxi_v1_anomalies;

-- TILL WE ONLY CONSIDER WEEKDAYS TO CHECK AGAINST. NOW, WE WILL MOVE TO  A HYBIRD APPROACH CONSIDERING LAST FEW DAYS AS WELL

-- CREATE OR REPLACE TABLE nyc_taxi_v1_daily_hybrid AS
-- SELECT
--     day,
--     daily_value,
--     DAYOFWEEK(day) AS dow,

--     -- Weekday seasonal baseline
--     AVG(daily_value) OVER (
--         PARTITION BY DAYOFWEEK(day)
--         ORDER BY day
--         ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING
--     ) AS seasonal_mean,

--     STDDEV(daily_value) OVER (
--         PARTITION BY DAYOFWEEK(day)
--         ORDER BY day
--         ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING
--     ) AS seasonal_std,

--     -- Recent 7-day rolling mean (trend)
--     AVG(daily_value) OVER (
--         ORDER BY day
--         ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
--     ) AS recent_mean

-- FROM nyc_taxi_v1_daily_filled
-- ORDER BY day;


-- CREATE OR REPLACE TABLE nyc_taxi_v1_daily_hybrid_baseline AS
-- SELECT
--     *,
--     0.7*seasonal_mean + 0.3*recent_mean AS hybrid_mean,
--     seasonal_std AS hybrid_std 
-- FROM nyc_taxi_v1_daily_hybrid;

-- CREATE OR REPLACE TABLE nyc_taxi_v1_hybrid_anomalies AS
-- SELECT
--     day,
--     daily_value,
--     seasonal_mean,
--     recent_mean,
--     hybrid_mean,
--     hybrid_std,
--     (daily_value - hybrid_mean) / hybrid_std AS z_score,
--     CASE
--         WHEN hybrid_std IS NULL THEN NULL
--         WHEN ABS((daily_value - hybrid_mean) / hybrid_std) >= 3 THEN TRUE
--         ELSE FALSE
--     END AS is_anomaly
-- FROM nyc_taxi_v1_daily_hybrid_baseline;

select * from nyc_taxi_v1_hybrid_anomalies;




