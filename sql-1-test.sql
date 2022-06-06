 id		dt				lowcarbon
1001    2021-12-12  123
1002	2021-12-12  45
1001	2021-12-13  43
1001	2021-12-13  45
1001	2021-12-13  23
1002	2021-12-14  45
1001	2021-12-14  230
1002	2021-12-15  45
1001    2021-12-15  23
找出连续3天及以上减少碳排放量在100以上的用户


-- 实现
SELECT id,
       count(*) as ct,
       flag
FROM
(
    SELECT id,
        dt,
        lowcarbon,
        date_sub(dt, rank) as flag
    FROM
    (
        SELECT  id,
                dt,
                lowcarbon,
                RANK() OVER(PARTITION BY id ORDER BY dt) as rank
        FROM 
        (
            SELECT  id,
                    dt,
                    sum(lowcarbon) as lowcarbon
            FROM    lowcarbon
            GROUP BY id, dt
            HAVING  lowcarbon > 100
        )t1
    )t2
)t3
GROUP BY id, flag
HAVING ct >= 3;


create external table if not exists lowcarbon(
    id bigint,
    dt string,
    lowcarbon bigint
) 
row format delimited fields terminated by ','
stored as textfile
location 'user/hive/warehouse/'; 

load data local inpath '/opt/data/data1/lowcorn.txt' overwrite into table lowcarbon;
load data local inpath '/opt/data/data1/l.txt.txt' overwrite into table lowcarbon;

select * from lowcarbon;

-- 连续N天：应该有模板代码和惯性思维
set hive.exec.mode.local.auto=true; 

-- 过滤出所有碳排量在100以上的用户
SELECT  id, dt, sum(lowcarbon) as lowcarbon
FROM    lowcarbon
group by id, dt
having lowcarbon > 100;t1

1001    2021-12-12      123
1001    2021-12-13      111
1001    2021-12-14      230

select id,
        flag,
        count(*) as ct
from
(
    select
    id,
    dt,
    lowcarbon,
    date_sub(dt,rk) flag
from 
(
select id,
       dt,
       lowcarbon,
       rank() over(partition by id order by dt) as rk
from 
(
    SELECT  id, dt, sum(lowcarbon) as lowcarbon
FROM    lowcarbon
group by id, dt
having lowcarbon > 100
)t1
)t2
)t3
group by id, flag
having ct >= 3;



-- 等差数列法:两个等差数列如果等差相同,则相同位置的数据相减等到的结果相同
-- 按照用户分组,同时按照时间排序,计算每条数据的Rank值

select id,
       dt,
       lowcarbon,
       rank() over(partition by id order by dt) as rk
from t1;t2
1001    2021-12-12      123     1
1001    2021-12-13      111     2
1001    2021-12-14      230     3

-- 3)将每行数据中的日期减去Rank值
select
    id,
    dt,
    lowcarbon,
    date_sub(dt,rk) flag
from t2;t3

1001    2021-12-12      123     2021-12-11
1001    2021-12-13      111     2021-12-11
1001    2021-12-14      230     2021-12-11


select id,
flag,
count(*) as ct
from t3
group by id,flag
having ct >= 3;

1001    2021-12-11      3