# 网络通信篇

Netty 是当前最流⾏的 NIO 框架，Netty 在互联⽹领域、⼤数据分布式计算领域、游戏⾏业、通信⾏业等获得了⼴泛的应⽤，业界著名的开源组件只要涉及到⽹络通信，Netty 是
最佳的选择之⼀。

Netty框架
Netty 三层⽹络架构：Reactor 通信调度层、职责链 PipeLine、业务逻辑处理层
Netty 的线程调度模型
序列化⽅式
链路有效性检测
流量整形
优雅停机策略
Netty 对 SSL/TLS 的⽀持 等等

关于 Netty 我们要掌握：
Netty 三层⽹络架构：Reactor通信调度层、职责链PipeLine、业务逻辑处理层
Netty 的线程调度模型
Netty的核⼼组件：
Channel
EventLoop
ChannelFuture
EventLoopGroup
ChannelHandler
ChannelPipeLine
ChannelHandlerContext
ByteBuf
TCP/IP粘包拆包
编/解码器
零拷⻉、内存池设计


# Hive
Hive 是⼀个数据仓库基础⼯具，在 Hadoop 中⽤来处理结构化数据。它架构在 Hadoop之上，总归为⼤数据，并使得查询和分析⽅便。Hive 是应⽤最⼴泛的 OLAP 框架。Hive SQL 也是我们进⾏ SQL 开发⽤的最多的框架。

关于 Hive 你必须掌握的知识点如下：
- HiveSQL原理和引擎：MapRuce、Tez、Spark

- Hive 和普通关系型数据库有什么区别

  > MySQL：是常用的数据库，采用行存储模式，底层是binlog，用来存储业务数据，数据量存储较小。
  >
  > HBase：列式数据库，底层是hdfs，可以存储海量的数据，主要用来存储海量的业务数据和日志数据。
  >
  > Hive：数据仓库，用来做数据分析和数据建模使用，数据可以批量导入。

- Hive ⽀持哪些数据格式

  > ## **TEXTFILE**
  >
  > Hive数据表的默认格式，存储方式：行存储。
  > 可以使用Gzip压缩算法，但压缩后的文件不支持split
  > **在反序列化过程中，必须逐个字符判断是不是分隔符和行结束符，因此反序列化开销会比SequenceFile高几十倍。**
  >
  > ## **SEQUENCEFILE**
  >
  > 压缩数据文件可以节省磁盘空间，但Hadoop中有些原生压缩文件的缺点之一就是不支持分割。支持分割的文件可以并行的有多个mapper程序处理大数据文件，大多数文件不支持可分割是因为这些文件只能从头开始读。Sequence File是可分割的文件格式，支持Hadoop的block级压缩。
  >
  > Hadoop API提供的一种二进制文件，以key-value的形式序列化到文件中。存储方式：行存储。
  >
  > sequencefile支持三种压缩选择：NONE，RECORD，BLOCK。Record压缩率低，RECORD是默认选项，通常BLOCK会带来较RECORD更好的压缩性能。
  >
  > 优势是文件和hadoop api中的MapFile是相互兼容的。
  >
  > ## **RCFILE**
  >
  > 存储方式：数据按行分块，每块按列存储。结合了行存储和列存储的优点：
  > RCFile 保证同一行的数据位于同一节点，因此元组重构的开销很低
  > 像列存储一样，RCFile 能够利用列维度的数据压缩，并且能跳过不必要的列读取
  > 数据追加：RCFile不支持任意方式的数据写操作，仅提供一种追加接口，这是因为底层的 HDFS当前仅仅支持数据追加写文件尾部。
  > 行组大小：行组变大有助于提高数据压缩的效率，但是可能会损害数据的读取性能，因为这样增加了 Lazy 解压性能的消耗。而且行组变大会占用更多的内存，这会影响并发执行的其他MR作业。 考虑到存储空间和查询效率两个方面，Facebook 选择 4MB 作为默认的行组大小，当然也允许用户自行选择参数进行配置。
  >
  > ## **ORCFILE**
  >
  > 存储方式：数据按行分块，每块按照列存储。
  > 压缩快，快速列存取。效率比rcfile高，是rcfile的改良版本。
  >
  > ## Parquet
  >
  > （1）Parquet支持嵌套的数据模型，类似于Protocol Buffers，每一个数据模型的schema包含多个字段，每一个字段有三个属性：重复次数、数据类型和字段名，重复次数可以是以下三种：required(只出现1次)，repeated(出现0次或多次)，optional(出现0次或1次)。每一个字段的数据类型可以分成两种： group(复杂类型)和primitive(基本类型)。
  >
  > （2）Parquet中没有Map、Array这样的复杂数据结构，但是可以通过repeated和group组合来实现的。
  >
  > （3）由于Parquet支持的数据模型比较松散，可能一条记录中存在比较深的嵌套关系，如果为每一条记录都维护一个类似的树状结可能会占用较大的存储空间，因此Dremel论文中提出了一种高效的对于嵌套数据格式的压缩算法：Striping/Assembly算法。通过Striping/Assembly算法，parquet可以使用较少的存储空间表示复杂的嵌套格式，并且通常Repetition level和Definition level都是较小的整数值，可以通过RLE算法对其进行压缩，进一步降低存储空间。
  >
  > Parquet文件是以二进制方式存储的，是不可以直接读取和修改的，Parquet文件是自解析的，文件中包括该文件的数据和元数据。

- Hive 在底层是如何存储 NULL 的

  > Hive的NULL存储为'\N'，同时Hive允许修改NULL的存储格式：`alter table name SET SERDEPROPERTIES('serialization.null.format' = '\N')` 
  >
  > 同时在面对String=""，的情况中，Hive存储的是""。
  >
  > 判断空时要根据实际的存储来进行判断。在开发过程中如果需要对空进行判断，一定得知道存储的是哪种数据。

- HiveSQL ⽀持的⼏种排序各代表什么意思（Sort By/Order By/Cluster By/Distrbute By）
  问题分析

  > 考官主要考察你对hive排序的理解，以判断你的hive和sql基础是否扎实，排序是hive中常有的操作，比较重要。
  >
  > ## 核心问题讲解
  >
  > 笼统地看，这四个语法在hive中都有排序和聚集的作用，然而，它们在执行时所启动的MR却各不相同。
  >
  > ### Order By
  > Hive中的order by跟传统的sql语言中的order by作用是一样的，会对查询的结果做一次全局排序，所以说，只有hive的sql中制定了order by所有的数据都会到同一个reducer进行处理（不管有多少map，也不管文件有多少的block只会启动一个reducer）。但是对于大量数据这将会消耗很长的时间去执行。
  >
  > 这里跟传统的sql还有一点区别：如果指定了hive.mapred.mode=strict（默认值是nonstrict）,这时就必须指定limit来限制输出条数，原因是：所有的数据都会在同一个reducer端进行，数据量大的情况下可能不能出结果，那么在这样的严格模式下，必须指定输出的条数。
  >
  > ### Sort By
  > Hive中指定了sort by，**那么在每个reducer端都会做排序**，也就是说保证了局部有序（每个reducer出来的数据是有序的，但是不能保证所有的数据是有序的，除非只有一个reducer），好处是：执行了局部排序之后可以为接下去的全局排序提高不少的效率（其实就是做一次归并排序就可以做到全局排序了）。
  >
  > ### distribute by
  > ditribute by是控制map的输出在reducer是如何划分的，举个例子，我们有一张表，mid是指这个store所属的商户id，money是这个商户的盈利，name是这个store的名字。
  >
  > mid	money	name
  > AA	15.0	商店1
  > AA	20.0	商店2
  > BB	22.0	商店3
  > CC	44.0	商店4
  >
  > 执行hive语句: 
  >
  > ```sql
  > select mid, money, name from store distribute by mid sort by mid asc, money asc;
  > ```
  >
  > 我们所有的mid相同的数据会被送到同一个reducer去处理，这就是因为指定了distribute by mid，这样的话就可以统计出每个商户中各个商店盈利的排序了（这个肯定是全局有序的，因为相同的商户会放到同一个reducer去处理）。这里需要注意的是distribute by必须要写在sort by之前。
  >
  > ### cluster by
  > **cluster by的功能就是distribute by和sort by相结合**，如下2个语句是等价的：
  >
  > select mid, money, name from store cluster by mid;
  > select mid, money, name from store distribute by mid sort by mid;
  >
  > 如果需要获得与3中语句一样的效果：
  > select mid, money, name from store cluster by mid sort by money;
  > 注意被cluster by指定的列只能是降序，不能指定asc和desc。
  >
  > ### 问题扩展
  >
  > 在hive的使用中，有很多相似的语法函数，比如分区和分桶，日期转换函数unix_timestamp和from_unixtime等，遇到类似问题要善于总结分析，以便在工作中能够灵活运用。
  >
  > ### 结合项目中使用
  >
  > **对于配置信息等少量数据的排序，可以使用order by语句；对于数据量大的排序操作，使用distribute by和sort by，或者使用cluster by来进行降序排序。**

- Hive 的动态分区

  > 静态分区与动态分区的主要区别在于静态分区是手动指定，而动态分区是通过数据来进行判断。
  >
  > 详细来说，静态分区的列实在编译时期，通过用户传递来决定的；动态分区只有在SQL执行时才能决定。

- HQL 和 SQL 有哪些常⻅的区别

  > hive下的SQL特点：
  >
  >   1.不支持等值连接，一般使用left join、right join 或者inner join替代。
  >
  >   2.不能智能识别concat(‘;’,key)，只会将‘；’当做SQL结束符号。分号是sql语句的结束符号，在hive中也是，但是hive对分号的识别没有那么智能，有时需要进行转义 “；” --> “\073”
  >
  >   3.不支持INSERT INTO 表 Values（）, UPDATE, DELETE等操作
  >
  >   4.HiveQL中String类型的字段若是空(empty)字符串, 即长度为0, 那么对它进行IS NULL的判断结果是False，使用left join可以进行筛选行。
  >
  >   5.不支持 ‘< dt <’这种格式的范围查找，可以用dt in(”,”)或者between替代。

- Hive 中的内部表和外部表的区别

  > ### 内部表和外部表的区别：
  >
  > - 创建内部表时：会将数据移动到数据仓库指向的路径;
  > - 创建外部表时：仅记录数据所在路径，不对数据的位置做出改变;
  > - 删除内部表时：删除表元数据和数据;
  > - 删除外部表时，删除元数据，不删除数据。

- Hive 表进⾏关联查询如何解决⻓尾和数据倾斜问题

- HiveSQL 的优化（系统参数调整、SQL语句优化）

- Hive分桶

  > 桶表是对数据`某个字段`进行哈希取值，然后放到不同文件中存储。
  >
  > 数据加载到桶表时，会对字段取hash值，然后与桶的数量取模。把数据放到对应的文件中。物理上，每个桶就是表(或分区）目录里的一个文件，一个作业产生的桶(输出文件)和reduce任务个数相同。
  >
  > 桶表专门用于抽样查询，是很专业性的，不是日常用来存储数据的表，需要抽样查询时，才创建和使用桶表。



# 列式数据库 Hbase
我们在提到列式数据库这个概念的时候，第⼀反应就是 Hbase。
HBase 本质上是⼀个数据模型，类似于⾕歌的⼤表设计，可以提供快速随机访问海量结构化数据。它利⽤了 Hadoop 的⽂件系统（HDFS）提供的容错能⼒。它是 Hadoop 的⽣态系统，提供对数据的随机实时读/写访问，是 Hadoop ⽂件系统的⼀部分。
我们可以直接或通过 HBase 的存储 HDFS 数据。使⽤ HBase 在 HDFS 读取消费/随机访问数据。HBase 在 Hadoop 的⽂件系统之上，并提供了读写访问。
HBase 是⼀个⾯向列的数据库，在表中它由⾏排序。表模式定义只能列族，也就是键值对。⼀个表有多个列族以及每⼀个列族可以有任意数量的列。后续列的值连续地存储在磁盘上。
表中的每个单元格值都具有时间戳。总之，在⼀个 HBase：表是⾏的集合、⾏是列族的集合、列族是列的集合、列是键值对的集合。

关于 Hbase 你需要掌握：
- Hbase 的架构和原理
- Hbase 的读写流程
- Hbase 有没有并发问题？Hbase 如何实现⾃⼰的 MVVC 的？
- Hbase 中⼏个重要的概念：HMaster、RegionServer、WAL机制、MemStore
- Hbase 在进⾏表设计过程中如何进⾏列族和 RowKey 的设计
- Hbase 的数据热点问题发现和解决办法
- 提⾼ Hbase 的读写性能的通⽤做法
- HBase 中 RowFilter 和 BloomFilter 的原理
- Hbase API 中常⻅的⽐较器
- Hbase 的预分区
- Hbase 的 Compaction
- Hbase 集群中 HRegionServer 宕机如何解决
- Hbase中的重要数据结构：LSM树、SkipList、布隆过滤器


# Kafka
关于 Kafka 我们需要掌握：
- Kafka 的特性和使⽤场景

- Kafka 中的⼀些概念：Leader、Broker、Producer、Consumer、Topic、Group、

- Offset、Partition、ISR

- Kafka 的整体架构

- Kafka 选举策略

  > ### 前言
  >
  > https://segmentfault.com/a/1190000039972124
  >
  > 最简单最直观的方案是，leader在zk上创建一个临时节点，所有Follower对此节点注册监听，当leader宕机时，此时ISR里的所有Follower都尝试创建该节点，而创建成功者（Zookeeper保证只有一个能创建成功）即是新的Leader，其它Replica即为Follower。
  >
  > 实际上的实现思路也是这样，只是优化了下，多了个代理控制管理类（controller）。**引入的原因是，当kafka集群业务很多，partition达到成千上万时，当broker宕机时，造成集群内大量的调整，会造成大量Watch事件被触发，Zookeeper负载会过重**。zk是不适合大量写操作的。
  >
  > ### Controller职责
  >
  > 具备控制器身份的broker需要比其他普通的broker多一份职责，具体细节如下：
  >
  > 1. 监听broker相关的变化。为Zookeeper中的`/brokers/ids/`节点添加`BrokerChangeListener`，用来处理broker增减的变化。
  > 2. 监听topic相关的变化。为Zookeeper中的`/brokers/topics`节点添加`TopicChangeListener`，用来处理topic增减的变化；为Zookeeper中的`/admin/delete_topics`节点添加`TopicDeletionListener`，用来处理删除topic的动作。
  > 3. 从Zookeeper中读取获取当前所有与topic、partition以及broker有关的信息并进行相应的管理。对于所有topic所对应的Zookeeper中的`/brokers/topics/[topic]`节点添加`PartitionModificationsListener`，用来监听topic中的分区分配变化。
  > 4. 更新集群的元数据信息，同步到其他普通的broker节点中。
  >
  > ### Controller控制器的选举
  >
  > 在kafka集群启动的时候，会自动选举一台broker作为controller来管理整个集群，选举的过程是集群中每个broker都会尝试在zookeeper上创建一个`/controller`临时节点，zookeeper会保证有且仅有一个broker能创建成功，这个broker就会成为集群的总控器controller。
  > 当这个controller角色的broker宕机了，此时zookeeper临时节点会消失，集群里其他broker会一直监听这个临时节点，发现临时节点消失了，就竞争再次创建临时节点，zookeeper又会保证有一个broker成为新的controller。
  >
  > ### 分区leader的选举
  >
  > controller感知到分区leader所在的broker挂了(controller监听了很多zk节点可以感知到broker存活)，controller会从每个parititon的replicas副本列表中取出第一个broker作为leader，当然这个broker需要也同时在ISR列表里。
  >
  > ### 消费者相关的选举
  >
  > Group Coordinator是运行在Kafka集群中每一个Broker内的一个进程。它主要负责Consumer Group的管理，Offset位移管理以及Consumer Rebalance。
  >
  > 
  >
  > 组协调器GroupCoordinator需要为消费组内的消费者选举出一个消费组的leader，这个选举的算法也很简单，分两种情况分析。如果消费组内还没有leader，那么第一个加入消费组的消费者即为消费组的leader。如果某一时刻leader消费者由于某些原因退出了消费组，那么会重新选举一个新的leader，这个重新选举leader的过程又更“随意”了，相关代码如下：
  >
  > ```
  > //scala code.
  > private val members = new mutable.HashMap[String, MemberMetadata]
  > var leaderId = members.keys.head
  > ```

- Kafka 读取和写⼊消息过程中都发⽣了什么 

- Kakfa 如何进⾏数据同步（ISR）

- Kafka 实现分区消息顺序性的原理

- 消费者和消费组的关系

  > ### 消费者Rebalance分区分配策略
  >
  > 主要有三种rebalance的策略：`range`、`round-robin`、`sticky`。 Kafka提供了消费者客户端参数`partition.assignment.strategy`来设置消费者与订阅主题之间的分区分配策略。
  >
  > 默认情况为range分配策略，假设一个主题有10个分区(0-9)，现在有三个consumer消费：
  >
  > - **range策略**：按照分区序号排序，假设 `n＝分区数／消费者数量=3`，`m＝分区数%消费者数量 = 1`，那么前`m`个消费者每个分配`n+1`个分区，后面的（`消费者数量－m`）个消费者每个分配`n`个分区。比如分区0-3给一个consumer，分区4-6给一个consumer，分区7-9给一个consumer。
  >
  > - **round-robin策略**：轮询分配，比如分区0、3、6、9给一个consumer，分区1、4、7给一个consumer，分区2、5、8给一个consumer
  >
  > - **sticky策略**：在rebalance的时候，需要保证如下两个原则。
  >
  >   1. 分区的分配要尽可能均匀。
  >   2. 分区的分配尽可能与上次分配的保持相同。
  >
  >   sticky策略当两者发生冲突时，第一个目标优先于第二个目标。
  >   这样可以最大程度维持原来的分区分配的策略。比如对于第一种range情况的分配，如果第三个consumer挂了，那么重新用sticky策略分配的结果如下：
  >
  >   - consumer1除了原有的0~3，会再分配一个7
  >   - consumer2除了原有的4~6，会再分配8和9

- 消费 Kafka 消息的 Best Practice（最佳实践）是怎样的

- Kafka 如何保证消息投递的可靠性和幂等性

- Kafka 消息的事务性是如何实现的

- 如何管理 Kafka 消息的 Offset

  >以前是通过Zookeeper保存Consumer Group Offset，太过于依赖于Zookeeper这个外部系统。
  >
  >而在0.9之后，所有的offset信息都保存在了Broker上的一个名为__consumer_offsets的topic中，该topic默认有50个分区，可以自己配置。Kafka集群中offset的管理都是由Group Coordinator中的Offset Manager完成的。
  >
  >
  >
  >一条offset消息的格式为groupid-topic-partition -> offset。因此consumer poll消息时，已知groupid和topic，又通过Coordinator分配partition的方式获得了对应的partition，自然能够通过Coordinator查找__consumers_offsets的方式获得最新的offset了。
  >
  >
  >
  >前面我们已经描述过offset的存储模型，它是按照**groupid-topic-partition -> offset**的方式存储的。然而Kafka只提供了根据offset读取消息的模型，并不支持根据key读取消息的方式。那么Kafka是如何支持Offset的查询呢？
  >
  >**答案就是Offsets Cache！！**
  >
  >Consumer提交offset时，Kafka Offset Manager会首先追加一条条新的commit消息到__consumers_offsets topic中，然后更新对应的缓存。读取offset时从缓存中读取，而不是直接读取__consumers_offsets这个topic。
  >
  >同时由于Cousumer每次commit offset的时候，都会存储一条信息，因此如果只需要最新的offset，可以配置kafka定期合并删除相同key的commit消息，只保留最新的。

- Kafka 的⽂件存储机制

-  Kafka 是如何⽀持 Exactly-once 语义的

- 通常 Kafka 还会要求和 RocketMQ 等消息中间件进⾏⽐较
