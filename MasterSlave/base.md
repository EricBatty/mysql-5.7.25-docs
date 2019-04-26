#### MySQL主从同步机制
MySQL主从同步是在MySQL主从复制(Master-Slave Replication)基础上实现的，通过设置在Master MySQL上的binlog(使其处于打开状态)，Slave MySQL上通过一个I/O线程从Master MySQL上读取binlog，然后传输到Slave MySQL的中继日志中，然后Slave MySQL的SQL线程从中继日志中读取中继日志，然后应用到Slave MySQL的数据库中。这样实现了主从数据同步功能。

![主从同步机制图](../images/ms.png)

#### MySQL主从同步作用
1. 可以作为一种备份机制，相当于热备份
2. 可有用来做读写分析，均衡数据库负载

#### MySQL配置主从同步

##### 一、准备
1. 主从数据库版本一致
2. 主从数据数据一致。如果后添加从数据库需要先将主数据库数据拷贝到从数据库数据目录下，后面会详细介绍这种情况下的操作。

##### 二、主数据库 Master 修改
###### 1. 修改 MySQL 配置
```
#二进制日志文件名位置
log-bin = mysql-binlog.log
#控制binlog的写入频率。每执行多少次事务写入一次 这个参数性能消耗很大，但可减小MySQL崩溃造成的损失
sync_binlog = 5
#日志格式，建议mixed 
#statement 保存SQL语句 row 保存影响记录数据 mixed 前面两种的结合
binlog_format = mixed
#主数据库端 ID 号
server-id = 1
#如果根据需要而同步数据库master要设置binglog_format = row 才会生效。
#二进制日志记录的数据库（多数据库用逗号，隔开）,需要同步的数据库，不在内的不同步。（不添加这行表示同步所有）
#binlog-do-db = go
#二进制日志中忽略数据库 （多数据库用逗号，隔开）,从库不需要同步的数据库，比如mysql等，以确保各自权限。
#binlog-ignore-db = mysql,local
```
###### 2. 重启 mysql，创建用于同步的账户
```
#重启 mysql

#创建slave账号
mysql> create user 'slave'@'%' identified by 'MyNewPass4!';
Query OK, 0 rows affected (0.01 sec)

mysql> grant replication slave on *.* to 'slave'@'%';
Query OK, 0 rows affected (0.00 sec)
mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

#查看当前 master 状态
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000002 |      154 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```
注意：操作到这里不要在操作主数据库了，可以加写锁，防止主数据库状态值变化

##### 三、从数据库 Slave 修改
###### 1. 修改MySQL配置
```
[root@node90 mysql]# vi etc/my.cnf
#中继日志记录中继信息的文件，如果没有指定该文位于数据目录下，默认文件名 relay-log.info
#relay-log-info-file=filename
#master日志信息文件，默认文件名为master.info。文件中包含master的读位置，以及连接master和启动复制必需的所有信息。
#mater-info-file=filename
# 从数据库端ID号
server-id =2
#如果根据需要而同步数据库master要设置binglog_format = row 才会生效。
#从数据库同样可以设置需要同步的库和表以及不需要同步的库和表，但是如果主数据库设置了不同步某个库 从数据库无法干涉主数据库的配置。
#设定需要复制的数据库（多数据库使用逗号，隔开）
#replicate-do-db    
设定需要忽略的复制数据库 （多数据库使用逗号，隔开）
#replicate-ignore-db 
设定需要复制的表
#replicate-do-table  
设定需要忽略的复制表 
#replicate-ignore-table 
同replication-do-table功能一样，但是可以通配符
#replicate-wild-do-table 
同replication-ignore-table功能一样，但是可以加通配符
#replicate-wild-ignore-table 

```
###### 2. 从库重启mysql 查看slave状态 在决定是否开始设置主从

```
mysql> show master status\G
*************************** 1. row ***************************
             File: mysql-bin.000005
         Position: 154
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 
1 row in set (0.00 sec)
#发现与maste数据库的binlog日志记录大不一样
```
###### 3. 同步主从数据库的数据
**a. 查看主数据库的数据**
```
[root@node90 mysql]# mysql -u root -p
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| go                 |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
```
**b. 将maste加写锁 禁止写入数据防止状态值改变**
```
mysql> flush tables with read lock;
Query OK, 0 rows affected (0.01 sec)
```
**c. 查看从数据库的数据**
```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)
```
**d. 从库缺少go数据库，如果现在直接开始主从同步那么go数据库的历史数据从数据库上将缺少。所以把go数据库的历史数据手动同步到从数据。**
```
[root@node90 mysql]# [root@node90 ~]# mysqldump -u root -p go > go.sql
[root@node90 ~]# scp go.sql root@192.168.0.91:
[root@node91 ~]# mysql -u root -p go < go.sql
#重启从库
[root@node91 mysql]# ./support-files/mysql.server stop 
Shutting down MySQL. SUCCESS! 
[root@node91 mysql]# ./support-files/mysql.server start
Starting MySQL. SUCCESS!
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| go                 |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
```
**e. 同样拥有了go数据库,拥有了go数据库的同样数据。主数据库重置binlog日志，执行以下命令。**
```
mysql> reset master;
Query OK, 0 rows affected (0.01 sec)
#分别查看当前二进制日志偏移量，是否相同。
mysql> show master status\G
*************************** 1. row ***************************
             File: mysql-bin.000001
         Position: 154
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 
1 row in set (0.00 sec)
```
**f. 从库开始同步主库，执行同步命令。**
```
mysql> change master to master_host='192.168.0.90', master_user='slave', master_password='MyNewPass4!', master_log_file='mysql-bin.000001',master_log_pos=154;
Query OK, 0 rows affected, 2 warnings (0.02 sec)
mysql> start slave;
Query OK, 0 rows affected (0.01 sec)
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.0.90
                  Master_User: slave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 154
               Relay_Log_File: node91-relay-bin.000002
                Relay_Log_Pos: 320
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: go
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 154
              Relay_Log_Space: 528
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: c578711a-663b-11e9-8247-000c292cf1a3
             Master_Info_File: /usr/local/mysql/data/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)
```
**g. 释放 master 的全局锁**
```
mysql> unlock tables;
Query OK, 0 rows affected (0.00 sec)
```

##### 测试
###### 测试代码
```
package main

import (
	"database/sql"
	"fmt"
	"reflect"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	db, err := sql.Open("mysql", "go:MyNewPass4!@tcp(192.168.0.90:3306)/?charset=utf8")
	checkErr(err)
	db.Query("use go ")
	//db.Query("create table go.temtab(c1 int, c2 varchar(20), c3 varchar(30))")
	//db.Query("insert into go.temtab values (101, '张金晓', '192.168.0.254'), (102, '张志伟', '192.168.0.81')")
	db.Query("insert into go.temtab values (103, '张三', '192.168.0.253'), (104, '李四', '192.168.0.82')")

	query, err := db.Query("select * from go.temtab")
	checkErr(err)
	v := reflect.ValueOf(query)
	fmt.Println(v)
	printResult(query)
	db.Close()

}


func checkErr(errMasg error)  {
	if errMasg != nil {
		panic(errMasg)
	}

	
}
func printResult(query *sql.Rows) {
	column, _ := query.Columns()              //读出查询出的列字段名
	values := make([][]byte, len(column))     //values是每个列的值，这里获取到byte里
	scans := make([]interface{}, len(column)) //因为每次查询出来的列是不定长的，用len(column)定住当次查询的长度
	for i := range values {                   //让每一行数据都填充到[][]byte里面
		scans[i] = &values[i]
	}
	results := make(map[int]map[string]string) //最后得到的map
	i := 0
	for query.Next() { //循环，让游标往下移动
		if err := query.Scan(scans...); err != nil { //query.Scan查询出来的不定长值放到scans[i] = &values[i],也就是每行都放在values里
			fmt.Println(err)
			return
		}
		row := make(map[string]string) //每行数据
		for k, v := range values {     //每行数据是放在values里面，现在把它挪到row里
			key := column[k]
			row[key] = string(v)
		}
		results[i] = row //装入结果集中
		i++
	}
	for k, v := range results { //查询出来的数组
		fmt.Println(k, v)
	}
}
```
###### 登录从库服务器查看数据
