# 安装: CentOS7.X install MySQL5.7.25 示例
#### 在 CentOS7.6 安装 MySQL5.7.25
##### 1. 下载 [MySQL-5.7.25.tar.gz](https://dev.mysql.com/downloads/file/?id=482768)   添加Mysql用户
```
[root@node90 ~]# useradd -s /sbin/nologin -c "MySQL" -M mysql
```
##### 2. 编译安装依赖编译器 安装依赖库
```
[root@node90 ~]# yum -y install gcc gcc-c++ ncurses ncurses-devel bison bison-devel wget
注意：cmake-3.14.3 需要c++11版本的支持
[root@node90 ~]# wget https://github.com/Kitware/CMake/releases/download/v3.14.3/cmake-3.14.3.tar.gz
[root@node90 cmake-3.14.3]# ./configure
[root@node90 cmake-3.14.3]# make -j `grep processor /proc/cpuinfo | wc -l`
[root@node90 cmake-3.14.3]# make install
```
##### 3. 安装boost 1.59.0
```
[root@node90 ~]# wget https://jaist.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz
[root@node90 ~]# tar xzvf boost_1_59_0.tar.gz
[root@node90 ~]# mv boost_1_59_0 /usr/local/
或者使用
#boost根据你使用的mysql的版本改变而改变版本 下载指定版本连接修改连接版本号即可。
[root@node90 ~]# wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.25.tar.gz 

```
##### 4. 预编译配置项 [配置项详细信息](https://dev.mysql.com/doc/mysql-installation-excerpt/5.7/en/source-configuration-options.html)
```
[root@node90 mysql-5.7.25]# cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/usr/local/mysql/etc \
-DMYSQL_UNIX_ADDR=/usr/local/mysql/logs/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DWITH_BOOST=/usr/local/boost_1_59_0 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
-DWITH_EMBEDDED_SERVER=OFF
```
##### 5. 编译
```
[root@node90 mysql-5.7.25]# make -j `grep processor /proc/cpuinfo|wc -l`
```
##### 6. 安装
```
[root@node90 mysql-5.7.25]# make install
```
##### 7. 创建所需要的目录、文件
```
[root@node90 mysql]# mkdir data logs etc
[root@nbzhiwei mysql]# touch /usr/local/mysql/logs/mysql-error.log
```
##### 8. 初始化数据库
修改MySQL目录权限
```
chown mysql.mysql -R /usr/local/mysql/
```
将mysql命令添加到环境变量中
```
[root@node90 mysql]# vi /etc/profile.d/mysql.sh
export MYSQL_HOME=/usr/local/mysql
export PATH=$MYSQL_HOME/bin:$PATH
[root@node90 mysql]# source /etc/profile
[root@node90 mysql]# mysqld --version
mysqld  Ver 5.7.25 for Linux on x86_64 (Source distribution)
```
初始化MySQL数据库，如果不想生成随机密码使用--initialize-insecure 选项代替 --initalize 选项初始化
```
[root@node90 mysql]# mysqld --initialize   --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/
```
##### 9. 设置服务器配置文件
```
[root@node90 mysql]# vi etc/my.cnf
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4
 
[mysqld]
port = 3306
socket = /tmp/mysql.sock
 
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
pid-file = /usr/local/mysql/data/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1
 
init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4
 
#skip-name-resolve
#skip-networking
back_log = 300
 
max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 4M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M
 
read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M
 
thread_cache_size = 8
 
query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M
 
ft_min_word_len = 4
 
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 30
 
log_error = /usr/local/mysql/logs/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /usr/local/mysql/logs//mysql-slow.log
 
performance_schema = 0
explicit_defaults_for_timestamp
 
#lower_case_table_names = 1
 
skip-external-locking
 
default_storage_engine = InnoDB
#default-storage-engine = MyISAM
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
 
bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
 
interactive_timeout = 28800
wait_timeout = 28800
 
[mysqldump]
quick
max_allowed_packet = 16M
 
[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
[mysqld_safe]
log_error = /usr/local/mysql/logs/mysql-error.log
pid-file = /usr/local/mysql/logs/mysql.pid
```
##### 10. 启动MySQL
```
[root@node90 mysql]# touch logs/mysql-error.log
[root@node90 mysql]# chown -R mysql.mysql /usr/local/mysql/
[root@node90 mysql]# ./support-files/mysql.server start
```
##### 11. 登录MySQL 并修改root用户密码
```
[root@node90 mysql]# mysql -u root -p 
mysql>  ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
Query OK, 0 rows affected (0.01 sec)
```
