-- 七日留存

-- 统计周期内，每日活跃用户数在第N日仍启动该App的用户数占比的平均值。七日留存率也就是N取7时的留存结果

-- 原始数据结构是什么？
    -- 用户在App上的行为通过埋点记录在日志表
    -- 数仓会抽象出一个每天用户活跃表

create table if not exists user_active(
    uid bigint,
    visit_day varchar(20)
)

insert into user_active (uid, visit_day) values(1001, '2022-01-01'),
                                               (1001, '2022-01-02'),
                                               (1001, '2022-01-03'),
                                               (1001, '2022-01-04'),
                                               (1001, '2022-01-06'),
                                               (1001, '2022-01-07'),
                                               (1001, '2022-01-08'),
                                               (1001, '2022-01-09'),
                                               (1002, '2022-01-03'),
                                               (1002, '2022-01-10'),
                                               (1001, '2022-01-09')


with t1 as
(
    select uid,
           visit_day
    from user_active
    where visit_day >= '2022-01-01'
    and   visit_day <= '2022-01-31'
),
t2 as
(
    select uid,
           visit_day
    from user_active
    where visit_day >= '2022-01-01'
    and   visit_day <= '2022-02-07'
)
select t1.visit_day,
       count(t1.uid) as visit_num,
       count(t2.uid) as visit_num_7day,
       count(t2.uid) / count(t1.uid) as visit_rat_7day
from t1
left join t2
on t1.uid = t2.uid
and datediff (t2.visit_day, t1.visit_day) = 7
group by t1.visit_day; 



-- Test Only
select datediff('20220207', '20220210') as datediff;













