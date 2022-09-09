# 订阅Kafka中的CDC Log数据，导入到Doris

-- Flink-SQL Kafka DDL, 数据源表
CREATE TABLE user_behavior (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    ts TIMESTAMP(3),
    proctime as PROCTIME(),   -- 通过计算列产生一个处理时间列
    WATERMARK FOR ts as ts - INTERVAL '5' SECOND  -- 在ts上定义watermark，ts成为事件时间列
) WITH (
    'connector.type' = 'kafka',  -- 使用 kafka connector
    'connector.version' = 'universal',  -- kafka 版本，universal 支持 0.11 以上的版本
    'connector.topic' = 'user_behavior',  -- kafka topic
    'connector.startup-mode' = 'earliest-offset',  -- 从起始 offset 开始读取
    'connector.properties.zookeeper.connect' = 'localhost:2181',  -- zookeeper 地址
    'connector.properties.bootstrap.servers' = 'localhost:9092',  -- kafka broker 地址
    'format.type' = 'json'  -- 数据源格式为 json
);


-- enable checkpoint
SET 'execution.checkpointing.interval' = '10s';
CREATE TABLE flink_doris_sink (
    name STRING,
    age INT,
    price DECIMAL(5,2),
    sale DOUBLE
    ) 
    WITH (
      'connector' = 'doris',
      'fenodes' = 'FE_IP:8030',
      'table.identifier' = 'db.table',
      'username' = 'root',
      'password' = 'password',
      'sink.label-prefix' = 'doris_label'
);



CREATE TABLE cdc_mysql_source (
  id int
  ,name VARCHAR
  ,PRIMARY KEY (id) NOT ENFORCED
) WITH (
 'connector' = 'mysql-cdc',
 'hostname' = '127.0.0.1',
 'port' = '3306',
 'username' = 'root',
 'password' = 'password',
 'database-name' = 'database',
 'table-name' = 'table'
);


CREATE TABLE products (
    id INT,
    name STRING,
    description STRING,
    PRIMARY KEY (id) NOT ENFORCED
  ) WITH (
    'connector' = 'mysql-cdc',
    'hostname' = 'localhost',
    'port' = '3306',
    'username' = 'root',
    'password' = '1234',
    'database-name' = 'mydb',
    'table-name' = 'products'
  );

# 使用 Flink CDC 接入 Doris 示例（支持 Insert / Update / Delete 事件）
-- 支持删除事件同步(sink.enable-delete='true'),需要 Doris 表开启批量删除功能
CREATE TABLE doris_sink (
id INT,
name STRING,
description STRING
) 
WITH (
  'connector' = 'doris',
  'fenodes' = '127.0.0.1:8030',
  'table.identifier' = 'test.products',
  'username' = 'root',
  'password' = '',
  'sink.properties.format' = 'json',
  'sink.properties.read_json_by_line' = 'true',
  'sink.enable-delete' = 'true',
  'sink.label-prefix' = 'doris_label'
);

insert into doris_sink select id,name,description from products;

CREATE TABLE IF NOT EXISTS test.products
(
id INT,
name STRING,
description STRING
)
UNIQUE KEY(`id`)
DISTRIBUTED BY HASH(`id`) BUCKETS 1
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);


CREATE TABLE products (
    id INT,
    name STRING,
    description STRING,
    PRIMARY KEY (id) NOT ENFORCED
  ) WITH (
    'connector' = 'mysql-cdc',
    'hostname' = '172.30.160.5',
    'port' = '3306',
    'username' = 'root',
    'password' = '1234',
    'database-name' = 'mydb',
    'table-name' = 'products'
  );


CREATE TABLE IF NOT EXISTS test.product
(
id INT,
name STRING,
description STRING,
weight DECIMAL(10,2)
)
UNIQUE KEY(`id`)
DISTRIBUTED BY HASH(`id`) BUCKETS 1
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);



## 前言
- Oracle的binlog日志已经由DBA通过OGG同步到Kafka中了，因此用不到Flink CDC
- 同步到Kafka中的JSON样式
  ```json
  {
  "before": {
    "id": 111,
    "name": "scooter",
    "description": "Big 2-wheel scooter",
    "weight": 5.18
  },
  "after": {
    "id": 111,
    "name": "scooter",
    "description": "Big 2-wheel scooter",
    "weight": 5.15
  },
  "op_type": "U",
  "op_ts": "2020-05-13 15:40:06.000000",
  "current_ts": "2020-05-13 15:40:07.000000",
  "primary_keys": [
    "id"
  ],
  "pos": "00000000000000000000143",
  "table": "PRODUCTS"
  }
  ```

## Flink SQL
> 需要下载以下Jar包，放在{flink_home}/lib/下
> flink-sql-connector-kafka_2.12-1.14.5.jar
> flink-json-1.15.1.jar
> flink-doris-connector-1.14_2.12-1.1.0.jar

- 开启CheckPoint：`SET 'execution.checkpointing.interval' = '10min';`

- 创建Kafka数据源表，设置`'format' = 'ogg-json'`，只有`org.apache.flink.flink-json-1.15.1`中以上才支持ogg-json fromat
```sql
CREATE TABLE topic_products (
  id INT,
  name STRING,
  description STRING,
  weight DECIMAL(10, 2)
) WITH (
  'connector' = 'kafka',
  'topic' = 'products_ogg_1',
  'properties.bootstrap.servers' = '172.30.160.5:9092',
  'properties.group.id' = 'testGroup',
  'format' = 'ogg-json',
  'scan.startup.mode' = 'earliest-offset',
  'ogg-json.ignore-parse-errors' = 'true'
);
```

- 创建Doris-Sink表
```sql
CREATE TABLE doris_sink (
id INT,
name STRING,
description STRING,
weight DECIMAL(10, 2)
)
WITH (
  'connector' = 'doris',
  'fenodes' = '172.30.160.5:8030',
  'table.identifier' = 'test.product',
  'username' = 'root',
  'password' = '',
  'sink.properties.format' = 'json',
  'sink.properties.read_json_by_line' = 'true',
  'sink.enable-delete' = 'true',
  'sink.label-prefix' = 'doris_label'
);
```

- 执行`INSERT into doris_sink select * from topic_products;`语句，写入Doris


curl --location --request POST 'http://127.0.1.1:8888/openapi/savepointTask' \
--header 'Content-Type: application/json' \
--data-raw '{
        "taskId":a4e539fb890c61d9c01c51482e3363ee,
        "type":"trigger"
}'