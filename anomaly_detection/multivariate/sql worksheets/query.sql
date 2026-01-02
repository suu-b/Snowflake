use database anomaly_detection;
create schema psra;

select * from psra_v1 limit 10;

select max(year), min(year) from psra_v1;

-- split the train
create or replace view psra_v1_train as
    select 
        to_timestamp_ntz(concat(year, '-', month, '-', day, ' ', hour, ':00:00')) as TS,
        pm2dot5 as PM25,
        temp, pres, rain, wspm
    from psra_v1
    where ts < '2017-01-01';

-- split the test
create or replace view psra_v1_test as
    select 
        to_timestamp_ntz(concat(year, '-', month, '-', day, ' ', hour, ':00:00')) as TS,
        pm2dot5 as PM25,
        temp, pres, rain, wspm
    from psra_v1
    where ts > '2017-01-01';


create or replace snowflake.ml.anomaly_detection psra_model(
    input_data => table(psra_v1_train),
    timestamp_colname => 'ts',
    target_colname => 'pm25',
    label_colname =>  ''
);


call psra_model!detect_anomalies(
    input_data => table(psra_v1_test),
    timestamp_colname => 'ts',
    target_colname => 'pm25'
);

create or replace table psra_anomaly_test_result as 
    select * from table(result_scan(last_query_id()));
call psra_model!show_evaluation_metrics();
call psra_model!explain_feature_importance();

select * from psra_anomaly_test_result;
