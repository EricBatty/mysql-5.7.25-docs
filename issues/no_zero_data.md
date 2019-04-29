# 问题: MySQL使用零值时间所出现的问题

MySQL版本 5.7.25
MySQL不正确的日期时间值：'0000-00-00 00:00:00'问题。 
参考地址：[https://stackoverflow.com/questions/35565128/mysql-incorrect-datetime-value-0000-00-00-000000/35565866](https://stackoverflow.com/questions/35565128/mysql-incorrect-datetime-value-0000-00-00-000000/35565866)
#### 如以下表结构
```
  CREATE TABLE `users` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `first_name` varchar(45) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL,
    `last_name` varchar(45) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL,
    `username` varchar(127) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
    `email` varchar(127) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
    `pass` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
    `active` char(1) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
    `created` datetime NOT NULL,
    `last_login` datetime DEFAULT NULL,
    `author` varchar(1) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT 'N',
    `locked_at` datetime DEFAULT NULL,
    `created_at` datetime DEFAULT NULL,
    `updated_at` datetime DEFAULT NULL,
    `ripple_token` varchar(36) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL,
    `ripple_token_expires` datetime DEFAULT '2014-10-31 08:03:55',
    `authentication_token` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
    UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
    UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`),
    KEY `users_active` (`active`),
    KEY `users_username` (`username`),
    KEY `index_users_on_email` (`email`)
  ) ENGINE=InnoDB AUTO_INCREMENT=1677 DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC
```
执行以下操作，一直收到一个错误：
```
UPDATE users SET created = NULL WHERE created = '0000-00-00 00:00:00';
一直收到Incorrect datetime value: '0000-00-00 00:00:00'错误。
#但是，使用以下语句可以查询出内容
SELECT * FROM users WHERE created = '0000-00-00 00:00:00'；
```

#### 遇到错误的原因：
sql_mode会话设置可能包括NO_ZERO_DATE。参考：[http：//dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_date](http：//dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_date)

##### 1. 查看sql_mode设置：
```
mysql> SHOW VARIABLES LIKE 'sql_mode' ;
+---------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name | Value                                                                                                                                     |
+---------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| sql_mode      | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
+---------------+-------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)
或者：
mysql> SELECT @@sql_mode ;
+-------------------------------------------------------------------------------------------------------------------------------------------+
| @@sql_mode                                                                                                                                |
+-------------------------------------------------------------------------------------------------------------------------------------------+
| ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
+-------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

```

#### 修复当前问题，以便在运行ALTER TABLE等语句时不会抛出错误。

##### 几个修复方法：
##### 1. sql_mode通过删除 `NO_ZERO_DATE` 和更改允许零日期 `NO_ZERO_IN_DATE`。更改可以通过命令行临时修改也可以通过my.cnf永久更改。

###### a. 对于临时更改，我们可以使用单个会话修改设置，而无需进行全局更改。

```
-- save current setting of sql_mode
SET @old_sql_mode := @@sql_mode ;

-- derive a new value by removing NO_ZERO_DATE and NO_ZERO_IN_DATE
SET @new_sql_mode := @old_sql_mode ;
SET @new_sql_mode := TRIM(BOTH ',' FROM REPLACE(CONCAT(',',@new_sql_mode,','),',NO_ZERO_DATE,'  ,','));
SET @new_sql_mode := TRIM(BOTH ',' FROM REPLACE(CONCAT(',',@new_sql_mode,','),',NO_ZERO_IN_DATE,',','));
SET @@sql_mode := @new_sql_mode ;

-- perform the operation that errors due to "zero dates"

-- when we are done with required operations, we can revert back
-- to the original sql_mode setting, from the value we saved
SET @@sql_mode := @old_sql_mode ;
```

###### b. 对于全局修改my.cnf

```
在 my.cnf 文件中 mysqld 区域添加
[mysqld]
...
sql_mode=STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
...
```

##### 2. 更改created列以允许NULL值，并更新现有行以将零日期更改为空值

```
UPDATE  `users` SET `created` = NULL WHERE `created` = '0000-00-00 00:00:00'
```

##### 3. 更新现有行以将零日期更改为有效日期

```
UPDATE  `users` SET `created` = '1970-01-02' WHERE `created` = '0000-00-00 00:00:00' 
```
>注意：请注意，午夜1970年1月1日（日期时间值'1970-01-01 00:00:00'）是一个“零日”，这将被评定为'0000-00-00 00:00:00'
