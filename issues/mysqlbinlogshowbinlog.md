# 问题: mysqlbinlog 查看binlog时报错unknown variable 'default-character-set=utf8'


binlog 二进制文件无法直接查看内容，需要借助mysqlbinlog工具，将binlog文件转换成可读的内容。

## 出现的报错
```angular2
[root@node90 mysql]# bin/mysqlbinlog data/mysql-bin.00001
mysqlbinlog: [ERROR] unknown variable 'default-character-set=utf8mb4'
```

## 报错原因

原因是mysqlbinlog这个工具无法识别binlog中的配置中的default-character-set=utf8mb4这个指令。

## 解决报错

### 方法一

在MySQL配置my.cnf文件中将`default-character-set=utf8mb`修改为`character-set-server = utf8`，但是需要重新启动MySQL服务。

### 方法二

使用--no-defaults参数

```
mysqlbinlog --no-defaults mysql-bin.000004
```
