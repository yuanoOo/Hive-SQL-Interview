-- 查看导入到Kafka的数据
docker-compose exec kafka bash -c 'kafka-console-consumer.sh --topic user_behavior --bootstrap-server kafka:9094 --from-beginning --max-messages 10'

-- Kafka中数据示例
{
    "user_id": "952483",
    "item_id": "310884",
    "category_id": "4580532",
    "behavior": "pv",
    "ts": "2017-11-27T00:00:00Z"
}

{
    "user_id": "794777",
    "item_id": "5119439",
    "category_id": "982926",
    "behavior": "pv",
    "ts": "2017-11-27T00:00:00Z"
}


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



# 统计每小时的成交量

-- 使用 DDL 创建 Elasticsearch 表
CREATE TABLE buy_cnt_per_hour ( 
    hour_of_day BIGINT,
    buy_cnt BIGINT
) WITH (
    'connector.type' = 'elasticsearch', -- 使用 elasticsearch connector
    'connector.version' = '6',  -- elasticsearch 版本，6 能支持 es 6+ 以及 7+ 的版本
    'connector.hosts' = 'http://localhost:9200',  -- elasticsearch 地址
    'connector.index' = 'buy_cnt_per_hour',  -- elasticsearch 索引名，相当于数据库的表名
    'connector.document-type' = 'user_behavior', -- elasticsearch 的 type，相当于数据库的库名
    'connector.bulk-flush.max-actions' = '1',  -- 每条数据都刷新
    'format.type' = 'json',  -- 输出数据格式 json
    'update-mode' = 'append'
);


-- 将统计的每小时成交量导入ES中
INSERT INTO buy_cnt_per_hour
SELECT HOUR(TUMBLE_START(ts, INTERVAL '1' HOUR)), COUNT(*)
FROM user_behavior
WHERE behavior = 'buy'
GROUP BY TUMBLE(ts, INTERVAL '1' HOUR);


# 统计一天每10分钟累计独立用户数

-- SQL CLI 中创建一个 Elasticsearch 表，用于存储结果汇总数据。主要有两个字段：时间和累积 uv 数。
CREATE TABLE cumulative_uv (
    time_str STRING,
    uv BIGINT
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '6',
    'connector.hosts' = 'http://localhost:9200',
    'connector.index' = 'cumulative_uv',
    'connector.document-type' = 'user_behavior',
    'format.type' = 'json',
    'update-mode' = 'upsert'
);


-- 为了实现该曲线，我们可以先通过 OVER WINDOW 计算出每条数据的当前分钟，
-- 以及当前累计 uv（从0点开始到当前行为止的独立用户数）。

-- 这里我们使用 SUBSTR 和 DATE_FORMAT 还有 || 内置函数，将一个 TIMESTAMP 
-- 字段转换成了 10分钟单位的时间字符串，如: 12:10, 12:20。
CREATE VIEW uv_per_10min AS
SELECT 
  MAX(SUBSTR(DATE_FORMAT(ts, 'HH:mm'),1,4) || '0') OVER w AS time_str, 
  COUNT(DISTINCT user_id) OVER w AS uv
FROM user_behavior
WINDOW w AS (ORDER BY proctime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);


-- 由于 uv_per_10min 每条输入数据都产生一条输出数据，因此对于存储压力较大。
-- 我们可以基于 uv_per_10min 再根据分钟时间进行一次聚合，这样每10分钟只有一个
-- 点会存储在 Elasticsearch 中，对于 Elasticsearch 和 Kibana 可视化渲染的压力会小很多。
INSERT INTO cumulative_uv
SELECT time_str, MAX(uv)
FROM uv_per_10min
GROUP BY time_str;


# 顶级类目排行榜

-- 在 SQL CLI 中创建 MySQL 表，后续用作维表查询。
CREATE TABLE category_dim (
    sub_category_id BIGINT,  -- 子类目
    parent_category_id BIGINT -- 顶级类目
) WITH (
    'connector.type' = 'jdbc',
    'connector.url' = 'jdbc:mysql://localhost:3306/flink',
    'connector.table' = 'category',
    'connector.driver' = 'com.mysql.jdbc.Driver',
    'connector.username' = 'root',
    'connector.password' = '123456',
    'connector.lookup.cache.max-rows' = '5000',
    'connector.lookup.cache.ttl' = '10min'
);

-- 同时我们再创建一个 Elasticsearch 表，用于存储类目统计结果
CREATE TABLE top_category (
    category_name STRING,  -- 类目名称
    buy_cnt BIGINT  -- 销量
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '6',
    'connector.hosts' = 'http://localhost:9200',
    'connector.index' = 'top_category',
    'connector.document-type' = 'user_behavior',
    'format.type' = 'json',
    'update-mode' = 'upsert'
);


-- 第一步我们通过维表关联，补全类目名称。我们仍然使用 CREATE VIEW 将该查询注册成一个视图，
-- 简化逻辑。维表关联使用 temporal join 语法
CREATE VIEW rich_user_behavior AS
SELECT U.user_id, U.item_id, U.behavior, 
  CASE C.parent_category_id
    WHEN 1 THEN '服饰鞋包'
    WHEN 2 THEN '家装家饰'
    WHEN 3 THEN '家电'
    WHEN 4 THEN '美妆'
    WHEN 5 THEN '母婴'
    WHEN 6 THEN '3C数码'
    WHEN 7 THEN '运动户外'
    WHEN 8 THEN '食品'
    ELSE '其他'
  END AS category_name
FROM user_behavior AS U LEFT JOIN category_dim FOR SYSTEM_TIME AS OF U.proctime AS C
ON U.category_id = C.sub_category_id;

-- 最后根据 类目名称分组，统计出 buy 的事件数，并写入 Elasticsearch 中。
INSERT INTO top_category
SELECT category_name, COUNT(*) buy_cnt
FROM rich_user_behavior
WHERE behavior = 'buy'
GROUP BY category_name;