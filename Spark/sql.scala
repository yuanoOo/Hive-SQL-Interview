val iteblogDF = Seq(
(0, "https://www.iteblog.com"),
 (1, "iteblog_hadoop"),
 (2, "iteblog")
).toDF("id", "info")


val r = iteblogDF.join(iteblogDF, Seq("id"), "inner")


bin/spark-submit \
--class org.apache.spark.examples.SparkPi \
--master yarn \
--deploy-mode cluster \
./examples/jars/spark-examples_2.12-3.0.0.jar \ 10


git pull --rebase origin master



https://github.com/yuanoOo/clash.github.io/tree/master/css
https://yuanooo.github.io/yuanoOo/clash.github.io/tree/main/js/color-schema.js
https://yuanooo.github.io/css/main.css


hexo clean && hexo g && hexo d