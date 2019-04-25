# 主从: 有关主从设置的一些命令
查看主服务器运行状态
```
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000005 |      407 | go           | mysql            |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```
查看从服务器主机列表
```
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|         2 |      | 3306 |         1 | e8cfd148-665e-11e9-ac44-000c294a58de |
+-----------+------+------+-----------+--------------------------------------+
1 row in set (0.00 sec)
```
获取binlog文件列表
```
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |      6155 |
| mysql-bin.000002 |       839 |
| mysql-bin.000003 |       753 |
| mysql-bin.000004 |       668 |
| mysql-bin.000005 |       407 |
+------------------+-----------+
5 rows in set (0.00 sec)
```
只查看第一个binlog文件的内容
```
mysql> show binlog events;
+------------------+------+----------------+-----------+-------------+----------------------------------------------------------------------------------------------------------+
| Log_name         | Pos  | Event_type     | Server_id | End_log_pos | Info                                                                                                     |
+------------------+------+----------------+-----------+-------------+----------------------------------------------------------------------------------------------------------+
| mysql-bin.000001 |    4 | Format_desc    |         1 |         123 | Server ver: 5.7.25-log, Binlog ver: 4                                                                    |
| mysql-bin.000001 |  123 | Previous_gtids |         1 |         154 |                                                                                                          |
| mysql-bin.000001 |  154 | Anonymous_Gtid |         1 |         219 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 |  219 | Query          |         1 |         292 | BEGIN                                                                                                    |
| mysql-bin.000001 |  292 | Query          |         1 |         454 | insert into go.temtab values (107, '老三', '192.168.0.252'), (108, '老四', '192.168.0.83')               |
| mysql-bin.000001 |  454 | Xid            |         1 |         485 | COMMIT /* xid=177 */                                                                                     |
| mysql-bin.000001 |  485 | Anonymous_Gtid |         1 |         550 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 |  550 | Query          |         1 |         623 | BEGIN                                                                                                    |
| mysql-bin.000001 |  623 | Query          |         1 |         785 | insert into go.temtab values (107, '老三', '192.168.0.252'), (108, '老四', '192.168.0.83')               |
| mysql-bin.000001 |  785 | Xid            |         1 |         816 | COMMIT /* xid=185 */                                                                                     |
| mysql-bin.000001 |  816 | Anonymous_Gtid |         1 |         881 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 |  881 | Query          |         1 |         954 | BEGIN                                                                                                    |
| mysql-bin.000001 |  954 | Query          |         1 |        1116 | insert into go.temtab values (107, '老五', '192.168.0.252'), (108, '老六', '192.168.0.83')               |
| mysql-bin.000001 | 1116 | Xid            |         1 |        1147 | COMMIT /* xid=195 */                                                                                     |
| mysql-bin.000001 | 1147 | Anonymous_Gtid |         1 |        1212 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 1212 | Query          |         1 |        1287 | BEGIN                                                                                                    |
| mysql-bin.000001 | 1287 | Query          |         1 |        1451 | use `go`; insert into go.temtab values (107, '老五', '192.168.0.252'), (108, '老六', '192.168.0.83')     |
| mysql-bin.000001 | 1451 | Xid            |         1 |        1482 | COMMIT /* xid=214 */                                                                                     |
| mysql-bin.000001 | 1482 | Anonymous_Gtid |         1 |        1547 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 1547 | Query          |         1 |        1622 | BEGIN                                                                                                    |
| mysql-bin.000001 | 1622 | Query          |         1 |        1786 | use `go`; insert into go.temtab values (107, '老五', '192.168.0.252'), (108, '老六', '192.168.0.83')     |
| mysql-bin.000001 | 1786 | Xid            |         1 |        1817 | COMMIT /* xid=215 */                                                                                     |
| mysql-bin.000001 | 1817 | Anonymous_Gtid |         1 |        1882 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 1882 | Query          |         1 |        1957 | BEGIN                                                                                                    |
| mysql-bin.000001 | 1957 | Query          |         1 |        2121 | use `go`; insert into go.temtab values (107, '老五', '192.168.0.252'), (108, '老六', '192.168.0.83')     |
| mysql-bin.000001 | 2121 | Xid            |         1 |        2152 | COMMIT /* xid=216 */                                                                                     |
| mysql-bin.000001 | 2152 | Anonymous_Gtid |         1 |        2217 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 2217 | Query          |         1 |        2292 | BEGIN                                                                                                    |
| mysql-bin.000001 | 2292 | Query          |         1 |        2456 | use `go`; insert into go.temtab values (107, '老五', '192.168.0.252'), (108, '老六', '192.168.0.83')     |
| mysql-bin.000001 | 2456 | Xid            |         1 |        2487 | COMMIT /* xid=217 */                                                                                     |
| mysql-bin.000001 | 2487 | Anonymous_Gtid |         1 |        2552 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 2552 | Query          |         1 |        2625 | BEGIN                                                                                                    |
| mysql-bin.000001 | 2625 | Query          |         1 |        2787 | insert into go.temtab values (107, '老五', '192.168.0.252'), (108, '老六', '192.168.0.83')               |
| mysql-bin.000001 | 2787 | Xid            |         1 |        2818 | COMMIT /* xid=223 */                                                                                     |
| mysql-bin.000001 | 2818 | Anonymous_Gtid |         1 |        2883 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 2883 | Query          |         1 |        2958 | BEGIN                                                                                                    |
| mysql-bin.000001 | 2958 | Query          |         1 |        3122 | use `go`; insert into go.temtab values (107, '老七', '192.168.0.252'), (108, '老八', '192.168.0.83')     |
| mysql-bin.000001 | 3122 | Xid            |         1 |        3153 | COMMIT /* xid=228 */                                                                                     |
| mysql-bin.000001 | 3153 | Anonymous_Gtid |         1 |        3218 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 3218 | Query          |         1 |        3291 | BEGIN                                                                                                    |
| mysql-bin.000001 | 3291 | Query          |         1 |        3453 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 3453 | Xid            |         1 |        3484 | COMMIT /* xid=234 */                                                                                     |
| mysql-bin.000001 | 3484 | Anonymous_Gtid |         1 |        3549 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 3549 | Query          |         1 |        3622 | BEGIN                                                                                                    |
| mysql-bin.000001 | 3622 | Query          |         1 |        3784 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 3784 | Xid            |         1 |        3815 | COMMIT /* xid=246 */                                                                                     |
| mysql-bin.000001 | 3815 | Anonymous_Gtid |         1 |        3880 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 3880 | Query          |         1 |        3953 | BEGIN                                                                                                    |
| mysql-bin.000001 | 3953 | Query          |         1 |        4115 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 4115 | Xid            |         1 |        4146 | COMMIT /* xid=256 */                                                                                     |
| mysql-bin.000001 | 4146 | Anonymous_Gtid |         1 |        4211 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 4211 | Query          |         1 |        4284 | BEGIN                                                                                                    |
| mysql-bin.000001 | 4284 | Query          |         1 |        4446 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 4446 | Xid            |         1 |        4477 | COMMIT /* xid=266 */                                                                                     |
| mysql-bin.000001 | 4477 | Anonymous_Gtid |         1 |        4542 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 4542 | Query          |         1 |        4615 | BEGIN                                                                                                    |
| mysql-bin.000001 | 4615 | Query          |         1 |        4777 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 4777 | Xid            |         1 |        4808 | COMMIT /* xid=276 */                                                                                     |
| mysql-bin.000001 | 4808 | Anonymous_Gtid |         1 |        4873 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 4873 | Query          |         1 |        4946 | BEGIN                                                                                                    |
| mysql-bin.000001 | 4946 | Query          |         1 |        5108 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 5108 | Xid            |         1 |        5139 | COMMIT /* xid=286 */                                                                                     |
| mysql-bin.000001 | 5139 | Anonymous_Gtid |         1 |        5204 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 5204 | Query          |         1 |        5277 | BEGIN                                                                                                    |
| mysql-bin.000001 | 5277 | Query          |         1 |        5439 | insert into go.temtab values (107, '老九', '192.168.0.252'), (108, '老十', '192.168.0.83')               |
| mysql-bin.000001 | 5439 | Xid            |         1 |        5470 | COMMIT /* xid=296 */                                                                                     |
| mysql-bin.000001 | 5470 | Anonymous_Gtid |         1 |        5535 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 5535 | Query          |         1 |        5608 | BEGIN                                                                                                    |
| mysql-bin.000001 | 5608 | Query          |         1 |        5770 | insert into go.temtab values (107, '十一', '192.168.0.252'), (108, '十二', '192.168.0.83')               |
| mysql-bin.000001 | 5770 | Xid            |         1 |        5801 | COMMIT /* xid=317 */                                                                                     |
| mysql-bin.000001 | 5801 | Anonymous_Gtid |         1 |        5866 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'                                                                     |
| mysql-bin.000001 | 5866 | Query          |         1 |        5939 | BEGIN                                                                                                    |
| mysql-bin.000001 | 5939 | Query          |         1 |        6101 | insert into go.temtab values (107, '十一', '192.168.0.252'), (108, '十二', '192.168.0.83')               |
| mysql-bin.000001 | 6101 | Xid            |         1 |        6132 | COMMIT /* xid=327 */                                                                                     |
| mysql-bin.000001 | 6132 | Stop           |         1 |        6155 |                                                                                                          |
+------------------+------+----------------+-----------+-------------+----------------------------------------------------------------------------------------------------------+
75 rows in set (0.00 sec)

```
查看指定binlog的文件的内容
```
mysql> show binlog events in 'mysql-bin.000001';
```
启动从库复制线程
```
mysql> START SLAVE;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
停止从库复制线程
```
mysql> STOP SLAVE;
Query OK, 0 rows affected (0.00 sec)
```
查看从服务器状态
```
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.0.90
                  Master_User: slave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000005
          Read_Master_Log_Pos: 407
               Relay_Log_File: node91-relay-bin.000016
                Relay_Log_Pos: 620
        Relay_Master_Log_File: mysql-bin.000005
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 407
              Relay_Log_Space: 994
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
查看mysql的线程信息
```
mysql> SHOW PROCESSLIST\G
```






