# 列转行

# 小明  1   山东  [99,86,100] {"身高":177,"体重":60,"年龄":18}
# 小王  2   北京  [97,77,80]  {"身高":180,"体重":70,"年龄":17}
# 小赵  2   广东  [77,89,90]  {"身高":170,"体重":50,"年龄":17}
# 小明  1   山东  [80,76,79]  {"身高":185,"体重":72,"年龄":18}

show databases;

create database test;

use  test;
drop table row_cloumn;
create table row_cloumn (
    `name` varchar(20),
    class int,
    province varchar(40),
    score varchar(40),
    info varchar(80)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

select * from row_cloumn;

insert row_cloumn values('小明', 1 , '山东',  '[99,86,100]', '{身高:177,体重:60,年龄:18}');
insert row_cloumn values('小王',  2,  '北京', '[97,77,80]',  '{身高:180,体重:70,年龄:17}');
insert row_cloumn values('小赵',  2,   '广东',  '[77,89,90]', '{身高:170,体重:50,年龄:17}');
insert row_cloumn values('小明',  1,   '山东', '[80,76,79]',  '{身高:185,体重:72,年龄:18}');


# MySQL行转列
DROP TABLE IF EXISTS tb_score;

CREATE TABLE tb_score(
    id INT(11) NOT NULL auto_increment,
    userid VARCHAR(20) NOT NULL COMMENT '用户id',
    subject VARCHAR(20) COMMENT '科目',
    score DOUBLE COMMENT '成绩',
    PRIMARY KEY(id)
)ENGINE = INNODB DEFAULT CHARSET = utf8;

INSERT INTO tb_score(userid,subject,score) VALUES ('001','语文',90);
INSERT INTO tb_score(userid,subject,score) VALUES ('001','数学',92);
INSERT INTO tb_score(userid,subject,score) VALUES ('001','英语',80);
INSERT INTO tb_score(userid,subject,score) VALUES ('002','语文',88);
INSERT INTO tb_score(userid,subject,score) VALUES ('002','数学',90);
INSERT INTO tb_score(userid,subject,score) VALUES ('002','英语',75.5);
INSERT INTO tb_score(userid,subject,score) VALUES ('003','语文',70);
INSERT INTO tb_score(userid,subject,score) VALUES ('003','数学',85);
INSERT INTO tb_score(userid,subject,score) VALUES ('003','英语',90);
INSERT INTO tb_score(userid,subject,score) VALUES ('003','政治',82);

SELECT * FROM tb_score;


SELECT userid,
MAX(CASE `subject` WHEN '语文' THEN score ELSE 0 END) as '语文',
MAX(CASE `subject` WHEN '数学' THEN score ELSE 0 END) as '数学',
MAX(CASE `subject` WHEN '英语' THEN score ELSE 0 END) as '英语',
MAX(CASE `subject` WHEN '政治' THEN score ELSE 0 END) as '政治'
FROM tb_score
GROUP BY userid;

