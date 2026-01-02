-- Permissions setup
grant usage on schema anomaly_detection.server_machine_dataset to role analyst;
grant create snowflake.ml.anomaly_detection on schema anomaly_detection.server_machine_dataset to role analyst;

-- the data types need to be consistent
CREATE OR REPLACE TABLE smd_standardized AS 
SELECT 
    timestamp,
    CAST(A AS FLOAT) AS A, CAST(B AS FLOAT) AS B, CAST(C AS FLOAT) AS C, 
    CAST(D AS FLOAT) AS D, CAST(E AS FLOAT) AS E, CAST(F AS FLOAT) AS F, 
    CAST(G AS FLOAT) AS G, CAST(H AS FLOAT) AS H, CAST(I AS FLOAT) AS I, 
    CAST(J AS FLOAT) AS J, CAST(K AS FLOAT) AS K, CAST(L AS FLOAT) AS L, 
    CAST(M AS FLOAT) AS M, CAST(N AS FLOAT) AS N, CAST(O AS FLOAT) AS O, 
    CAST(P AS FLOAT) AS P, CAST(Q AS FLOAT) AS Q, CAST(R AS FLOAT) AS R, 
    CAST(S AS FLOAT) AS S, CAST(T AS FLOAT) AS T, CAST(U AS FLOAT) AS U, 
    CAST(V AS FLOAT) AS V, CAST(W AS FLOAT) AS W, 
    X, 
    CAST(Y AS FLOAT) AS Y, CAST(Z AS FLOAT) AS Z, CAST(AA AS FLOAT) AS AA, 
    CAST(AB AS FLOAT) AS AB, CAST(AC AS FLOAT) AS AC, CAST(AD AS FLOAT) AS AD, 
    CAST(AE AS FLOAT) AS AE, CAST(AF AS FLOAT) AS AF, CAST(AG AS FLOAT) AS AG, 
    CAST(AH AS FLOAT) AS AH, CAST(AI AS FLOAT) AS AI, CAST(AJ AS FLOAT) AS AJ, 
    CAST(AK AS FLOAT) AS AK, CAST(AL AS FLOAT) AS AL
FROM smd_raw;

-- Docs ref:
-- CREATE OR REPLACE VIEW view_with_training_data_multiple_series
  -- AS SELECT
  --   [store_id, item] AS store_item,
  --   date,
  --   sales,
  --   label,
  --   temperature,
  --   humidity,
  --   holiday
  -- FROM historical_sales_data;

  DESCRIBE TABLE smd_raw;
  
create or replace view smd_standardized_view 
    as select
    timestamp, metric_name, metric_value
    from smd_standardized 
    unpivot(metric_value for metric_name in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W, Y,Z,AA,AB,AC,AD,AE,AF,AG,AH,AI,AJ,AK,AL));

-- doc ref:
-- CREATE OR REPLACE SNOWFLAKE.ML.ANOMALY_DETECTION model_for_multiple_series(
--   INPUT_DATA => TABLE(view_with_training_data_multiple_series),
--   SERIES_COLNAME => 'store_item',
--   TIMESTAMP_COLNAME => 'date',
--   TARGET_COLNAME => 'sales',
--   LABEL_COLNAME => 'label'
-- );
-- Creating the function on data with ~7% contamination
create or replace snowflake.ml.anomaly_detection smd_raw_model (
    input_data => table(smd_standardized_view),
    series_colname => 'metric_name',
    timestamp_colname => 'timestamp',
    target_colname => 'metric_value',
    label_colname => ''
)