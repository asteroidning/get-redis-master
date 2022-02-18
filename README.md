# get-redis-master

获取哨兵模式redis集群的master

### ENV

定义以下环境变量：

`REDIS_SVC`： redis的service地址。==必须的==

`NAMESPACE`： redis所在的名称空间。==必须的==

`MASTER_GROUP_NAME`：即slave和哨兵连接master时的密码。==必须的==

`RELEASE`：创建redis集群时的release名。==必须的==

`SLEEP_TIME`：循环的睡眠时间，默认30s