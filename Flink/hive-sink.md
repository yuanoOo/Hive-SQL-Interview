# load hive catelog
CREATE CATALOG hive WITH (
    'type' = 'hive',
    'default-database' = 'default',
    'hive-conf-dir' = '/opt/module/apache-hive-3.1.3-bin/conf'
);

USE CATALOG hive;


SET table.sql-dialect=hive;
CREATE TABLE test.hive_table (
  user_id STRING,
  order_amount DOUBLE
) PARTITIONED BY (dt STRING, hr STRING) STORED AS parquet TBLPROPERTIES (
  'partition.time-extractor.timestamp-pattern'='$dt $hr:00:00',
  'sink.partition-commit.trigger'='process-time',
  'sink.rolling-policy.file-size'='1mb',
  'sink.partition-commit.delay'='5 min',
  'sink.partition-commit.policy.kind'='metastore,success-file'
);

CREATE TABLE test.hive_table (
  user_id STRING,
  order_amount DOUBLE
) STORED AS parquet TBLPROPERTIES (
  'sink.rolling-policy.file-size'='5mb'
);

DROP TEMPORARY TABLE datagen;
SET table.sql-dialect=default;
CREATE temporary TABLE datagen (
  price INT,
  customer_name STRING,
  ts AS localtimestamp,
  WATERMARK FOR ts AS ts
) WITH (
  'connector' = 'datagen',
  'rows-per-second'='10000',
  'fields.price.kind'='random',
  'fields.customer_name.length'='10'
);


set execution.checkpointing.interval=1min;
-- streaming sql, insert into hive table
INSERT INTO hive_table 
SELECT customer_name , price, DATE_FORMAT(ts, 'yyyy-MM-dd'), DATE_FORMAT(ts, 'HH')
FROM datagen;

-- batch sql, select with partition pruning
SET execution.runtime-mode = batch;
SET sql-client.execution.result-mode = tableau;
SELECT * FROM hive_table WHERE dt='2020-05-20' and hr='12';