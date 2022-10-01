# 基于 Flink CDC 构建 MySQL 和 Postgres 的 Streaming ETL


SET execution.runtime-mode = batch;

 CREATE TABLE orders (
     order_id INT,
     order_date TIMESTAMP(0),
     customer_name STRING,
     price DECIMAL(10, 5),
     product_id INT,
     order_status BOOLEAN,
     PRIMARY KEY(order_id) NOT ENFORCED
     ) WITH (
        'connector' = 'mysql-cdc',
        'hostname' = 'localhost',
        'port' = '3306',
        'username' = 'root',
        'password' = '1234',
        'database-name' = 'mydb',
        'table-name' = 'orders',
        'debezium.snapshot.mode' = 'initial_only'
     );