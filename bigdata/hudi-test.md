# Spark 3.2
spark-shell \
  --master local[2] \
  --packages org.apache.hudi:hudi-spark3.2-bundle_2.12:0.12.0 \
  --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' \
  --conf 'spark.sql.catalog.spark_catalog=org.apache.spark.sql.hudi.catalog.HoodieCatalog' \
  --conf 'spark.sql.extensions=org.apache.spark.sql.hudi.HoodieSparkSessionExtension'


// spark-shell
import org.apache.hudi.QuickstartUtils._
import scala.collection.JavaConversions._
import org.apache.spark.sql.SaveMode._
import org.apache.hudi.DataSourceReadOptions._
import org.apache.hudi.DataSourceWriteOptions._
import org.apache.hudi.config.HoodieWriteConfig._
import org.apache.hudi.common.model.HoodieRecord

val tableName = "hudi_trips_cow"
val basePath = "hdfs://localhost:9000/user/hadoop/hudi-warehouse/hudi_trips_cow"
val dataGen = new DataGenerator
val snapshotQuery = "SELECT begin_lat, begin_lon, driver, end_lat, end_lon, fare, partitionpath, rider, ts, uuid FROM hudi_ro_table"


df.write
  .mode(Overwrite)
  .format("hudi")
  .options(getQuickstartWriteConfigs)
  .option(PRECOMBINE_FIELD_OPT_KEY, "ts")
  .option(RECORDKEY_FIELD_OPT_KEY, "uuid")
  .option(PARTITIONPATH_FIELD_OPT_KEY, "partitionpath")
  .option(TABLE_NAME, tableName)
  .save(basePath)
