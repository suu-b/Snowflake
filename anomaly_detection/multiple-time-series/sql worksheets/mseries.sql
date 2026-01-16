select * from M_SERIES limit 10;
select min("as_of_date"), max("as_of_date") from m_series;


create or replace view mseries_training as
select 
    ["key_1", "key_2", "key_3"] as row_key, 
    to_timestamp("as_of_date") as as_of_date, 
    "value" as value
from m_series
where to_timestamp("as_of_date") < to_timestamp('2026-01-16');

select count (*) from mseries_training;

create or replace snowflake.ml.anomaly_detection holmes_alpha(
    input_data => table(mseries_training),
    series_colname => 'row_key',
    timestamp_colname => 'as_of_date',
    target_colname => 'value',
    label_colname => ''
)

create or replace view mseries_test as
select 
    ["key_1", "key_2", "key_3"] as row_key, 
    to_timestamp("as_of_date") as as_of_date, 
    "value" as value
from m_series
where to_timestamp("as_of_date") > to_timestamp('2026-01-16');

select count(*) from mseries_test;

call holmes_alpha!detect_anomalies(
    input_data => table(mseries_test),
    series_colname => 'row_key',
    timestamp_colname => 'as_of_date',
    target_colname => 'value'
)

create or replace table m_series_test_results as
select * from table(result_scan(last_query_id()));