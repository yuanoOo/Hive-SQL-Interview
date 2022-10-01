CREATE CATALOG hive WITH (
    'type' = 'hive',
    'default-database' = 'default',
    'hive-conf-dir' = '/opt/module/apache-hive-3.1.3-bin/conf'
);

USE CATALOG hive;

LOAD MODULE hive WITH ('hive-version' = '3.1.2');

use modules hive,core;

set table.exec.hive.fallback-mapred-reader = true;

SET execution.runtime-mode = batch;

SET table.optimizer.join-reorder-enabled = true;

SET sql-client.execution.result-mode = tableau;

set table.sql-dialect=hive; 
SET sql-client.execution.result-mode = tableau;



create table test(
  id bigint,
  name string
)stored as parquet;


create external table if not exists fun_user_external (
    tid INT,
    userid STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE;


load data local inpath '/tmp/1.txt' into table fun_user_external;


select * from default.fun_user_external;

create table if not exists `user` (
    tid INT,
    userid STRING
) stored as orc;

insert overwrite table user select tid, userid from fun_user_external;