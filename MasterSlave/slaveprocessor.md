# 主从: MySQL 从节点设置多线程复制

Mysql 采用多线程进行复制是从 Mysql 5.6 开始支持的内容，但是 5.6 版本下有缺陷，虽然支持多线程，但是每个数据库只能一个线程，也就是说如果我们只有一个数据库，则主从复制时也只有一个线程在工作。相当于还是以前的单线程。 从 Mysql 5.7 开始支持同一数据库下并行主从复制。不过默认情况下，还是单数据库单个线程，如果需要使用多线程，需要在从节点进行配置。

Mysql 5.7 对主从复制增加了类型，共有两种类型，如下：
    
- DATABASE 基于库的并行复制 ， 每个数据库对应一个复制线程
- LOGICAL_CLOCK 基于组提交的并行复制方式，同一个数据库下可以有多个线程

## 下面的步骤，在从节点上进行配置。
### 查看当前配置
#### 1、当前配置下的主从复制的进程数。

```angular2
mysql> show processlist;
+----+-------------+-----------+------+---------+-------+--------------------------------------------------------+------------------+
| Id | User        | Host      | db   | Command | Time  | State                                                  | Info             |
+----+-------------+-----------+------+---------+-------+--------------------------------------------------------+------------------+
|  1 | system user |           | NULL | Connect | 81687 | Waiting for master to send event                       | NULL             |
|  2 | system user |           | NULL | Connect | 65391 | Slave has read all relay log; waiting for more updates | NULL             |
| 12 | root        | localhost | NULL | Query   |     0 | starting                                               | show processlist |
+----+-------------+-----------+------+---------+-------+--------------------------------------------------------+------------------+
3 rows in set (0.00 sec)
```
从上面看出只有一个主进程在等待同步。
#### 2、 查看当前复制类型和并行数量配置
```angular2
mysql> show variables like 'slave_parallel_type';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| slave_parallel_type | DATABASE |
+---------------------+----------+
1 row in set (0.01 sec)
#当前的复制类型是 DATABASE，也就是统一数据库下只有一个线程进行复制，不能并行复制。
mysql> show variables like 'slave_parallel_workers';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| slave_parallel_workers | 0     |
+------------------------+-------+
1 row in set (0.00 sec)
#当前工作进程为0
```

### 配置多线程
#### 1、停止从节点复制
```angular2
mysql> stop slave;
Query OK, 0 rows affected (0.01 sec)

```
#### 2、设置复制类型为  LOGICAL_CLOCK
```angular2
mysql> set global slave_parallel_type='logical_clock';
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'slave_parallel_type';
+---------------------+---------------+
| Variable_name       | Value         |
+---------------------+---------------+
| slave_parallel_type | LOGICAL_CLOCK |
+---------------------+---------------+
1 row in set (0.01 sec)

```
#### 3、设置并行数量为 4
```angular2
mysql> set global slave_parallel_workers=4;
Query OK, 0 rows affected (0.00 sec)


mysql> show variables like 'slave_parallel_workers';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| slave_parallel_workers | 4     |
+------------------------+-------+
1 row in set (0.00 sec)
```
#### 4、启动从复制
```angular2
mysql> start slave;
Query OK, 0 rows affected (0.02 sec)
```
#### 5、查看一下当前工作的线程数
```
mysql> show processlist;
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
| Id | User        | Host      | db   | Command | Time | State                                                  | Info             |
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
| 37 | root        | localhost | NULL | Query   |    0 | starting                                               | show processlist |
| 38 | system user |           | NULL | Connect |    8 | Waiting for master to send event                       | NULL             |
| 39 | system user |           | NULL | Connect |    7 | Slave has read all relay log; waiting for more updates | NULL             |
| 40 | system user |           | NULL | Connect |    8 | Waiting for an event from Coordinator                  | NULL             |
| 41 | system user |           | NULL | Connect |    8 | Waiting for an event from Coordinator                  | NULL             |
| 42 | system user |           | NULL | Connect |    8 | Waiting for an event from Coordinator                  | NULL             |
| 43 | system user |           | NULL | Connect |    8 | Waiting for an event from Coordinator                  | NULL             |
+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
7 rows in set (0.00 sec)
```

最后说一下为什么需要多线程复制？因为主从之间的同步会有延时，多线程的目的是为了尽量减少这个延时时间。虽然如何优化主从是一个系统的功能，不同的场景需要不同的解决方案，但是多线程至少从基础上能减少延迟时间。另外根据数据库的实际情况，能否真正减少延时，以及配置多少线程，则需要反复的测试得出适合自己的数据。