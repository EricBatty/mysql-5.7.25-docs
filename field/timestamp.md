# 字段: 表timestamp字段





## TIMESTAMP设置默认值的几个应用实例

### 1、创建表 dj1，b列有个属性ON UPDATE CURRENT_TIMESTAMP，导致更新数据时，即便未涉及到该列，该列数据也被自动更新。c列为零值，新插入数据时依然是零值不会改变。

```angular2
CREATE TABLE `dj1` (
  `a` char(1) COLLATE utf8_bin DEFAULT NULL,
  `b` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `c` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  UNIQUE KEY `dj1_idx_u1` (`b`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
mysql> select * from dj1;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 7    | 2019-05-06 10:42:05 | 0000-00-00 00:00:00 |
| 4    | 2019-05-06 10:42:30 | 0000-00-00 00:00:00 |
| 1    | 2019-05-06 11:02:33 | 0000-00-00 00:00:00 |
+------+---------------------+---------------------+
3 rows in set (0.00 sec)
mysql> update dj1 set a=8 where a=7;
Query OK, 1 row affected (0.03 sec)
Rows matched: 1  Changed: 1  Warnings: 0
mysql> select * from dj1;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 4    | 2019-05-06 10:42:30 | 0000-00-00 00:00:00 |
| 1    | 2019-05-06 11:02:33 | 0000-00-00 00:00:00 |
| 8    | 2019-05-06 11:07:42 | 0000-00-00 00:00:00 |
+------+---------------------+---------------------+
3 rows in set (0.00 sec)
```


### 2、创建表 dj2，b 列 c 列不带属性.不带属性默认创建就是这样。
```angular2
CREATE TABLE `dj2` (
  `a` char(1) DEFAULT NULL,
  `b` timestamp NULL DEFAULT NULL,
  `c` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
mysql> select * from dj2;
+------+------+------+
| a    | b    | c    |
+------+------+------+
| 1    | NULL | NULL |
| 2    | NULL | NULL |
| 1    | NULL | NULL |
+------+------+------+
3 rows in set (0.00 sec)
```

### 3、创建表 dj3，b列默认值为CURRENT_TIMESTAMP不带自动更新属性，c列为零值，测试可用

```angular2
CREATE TABLE `dj3` (
  `a` char(1) COLLATE utf8_bin DEFAULT NULL,
  `b` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `c` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  UNIQUE KEY `dj1_idx_u1` (`b`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
mysql> select * from dj3;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 4    | 2019-05-06 10:41:10 | 0000-00-00 00:00:00 |
+------+---------------------+---------------------+
1 row in set (0.00 sec)
mysql> update dj3 set a=5 where a=4;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
mysql> select * from dj3;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 5    | 2019-05-06 10:41:10 | 0000-00-00 00:00:00 |
+------+---------------------+---------------------+
1 row in set (0.00 sec)

```


### 4、创建表 dj4，b列默认值为CURRENT_TIMESTAMP，c列默认值为CURRENT_TIMESTAMP带自动更新属性，测试可用。
```angular2
CREATE TABLE `dj4` (  
`a` char(1) COLLATE utf8_bin DEFAULT NULL,  
`b` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ,  
`c` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  
UNIQUE KEY `dj1_idx_u1` (`b`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;  
mysql> select * from dj4;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 2    | 2019-05-06 10:49:17 | 2019-05-06 10:49:22 |
+------+---------------------+---------------------+
1 row in set (0.00 sec)
mysql> update dj4 set a=4 where a=2;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
mysql> select * from dj4;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 4    | 2019-05-06 10:49:17 | 2019-05-06 11:12:09 |
+------+---------------------+---------------------+
1 row in set (0.00 sec)

```


### 5、创建表dj5，b列默认值为CURRENT_TIMESTAMP，c列默认值为'0000-00-00 00:00:00'带自动更新属性，测试后可以使用。

```angular2
CREATE TABLE `dj5` (  
 `a` CHAR(1) COLLATE utf8_bin DEFAULT NULL,  
 `b` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,  
 `c` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,  
 UNIQUE KEY `dj1_idx_u1` (`b`)  
 ) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;  
mysql> select * from dj5;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 2    | 2019-05-06 10:51:18 | 2019-05-06 10:51:25 |
| 3    | 2019-05-06 11:12:58 | 0000-00-00 00:00:00 |
+------+---------------------+---------------------+
2 rows in set (0.00 sec)
mysql> update dj5 set a=4 where a=3;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
mysql> select * from dj5;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 2    | 2019-05-06 10:51:18 | 2019-05-06 10:51:25 |
| 4    | 2019-05-06 11:12:58 | 2019-05-06 11:13:31 |
+------+---------------------+---------------------+
2 rows in set (0.00 sec)

```


### 6、创建表dj6，b列默认值为CURRENT_TIMESTAMP带自动更新属性，c列默认值为CURRENT_TIMESTAMP，测试可用。

```angular2
CREATE TABLE `dj6` (  
 `a` char(1) COLLATE utf8_bin DEFAULT NULL,  
 `b` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  
 `c` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ,  
 UNIQUE KEY `dj1_idx_u1` (`b`)  
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;  
mysql> select * from dj6;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 1    | 2019-05-06 11:14:16 | 2019-05-06 11:14:16 |
+------+---------------------+---------------------+
1 row in set (0.00 sec) 
mysql> update dj6 set a=2 where a=1;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0
mysql> select * from dj6;
+------+---------------------+---------------------+
| a    | b                   | c                   |
+------+---------------------+---------------------+
| 2    | 2019-05-06 11:15:17 | 2019-05-06 11:14:16 |
+------+---------------------+---------------------+
1 row in set (0.00 sec)
```