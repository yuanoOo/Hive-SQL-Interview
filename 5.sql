## 同时在线问题

- 如下为某直播平台主播开播及关播时间，根据该数据计算出平台最高峰同时在线的主播
人数。

id		stt						edt
1001	2021-06-14 12:12:12		2021-06-14 18:12:12
1003	2021-06-14 13:12:12		2021-06-14 16:12:12
1004	2021-06-14 13:15:12		2021-06-14 20:12:12
1002	2021-06-14 15:12:12		2021-06-14 16:12:12
1005	2021-06-14 15:18:12		2021-06-14 20:12:12
1001	2021-06-14 20:12:12		2021-06-14 23:12:12
1006	2021-06-14 21:12:12		2021-06-14 23:15:12
1007	2021-06-14 22:12:12		2021-06-14 23:10:12

流式！

1)对数据分类,在开始数据后添加正1,表示有主播上线,同时在关播数据后添加-1,表示有主播下线
select id,stt dt,1 p from test5
union
select id,edt dt,-1 p from test5;t1

1001	2021-06-14 12:12:12	1
1001	2021-06-14 18:12:12	-1
1001	2021-06-14 20:12:12	1
1001	2021-06-14 23:12:12	-1
1002	2021-06-14 15:12:12	1
1002	2021-06-14 16:12:12	-1
1003	2021-06-14 13:12:12	1
1003	2021-06-14 16:12:12	-1
1004	2021-06-14 13:15:12	1
1004	2021-06-14 20:12:12	-1
1005	2021-06-14 15:18:12	1
1005	2021-06-14 20:12:12	-1
1006	2021-06-14 21:12:12	1
1006	2021-06-14 23:15:12	-1
1007	2021-06-14 22:12:12	1
1007	2021-06-14 23:10:12	-1

2)按照时间排序,计算累加人数
select
    id,
    dt,
    sum(p) over(order by dt) sum_p
from
    (select id,stt dt,1 p from test5
union
select id,edt dt,-1 p from test5)t1;t2

3)找出同时在线人数最大值
select
    max(sum_p)
from
    (select
    id,
    dt,
    sum(p) over(order by dt) sum_p
from
    (select id,stt dt,1 p from test5
union
select id,edt dt,-1 p from test5)t1)t2;
