# 安装及简介

`percona-toolkit` 是一组高级命令行工具的集合，可以查看当前服务的摘要信息，磁盘检测，分析慢查询日志，查找重复索引，实现表同步等等。

## 1、percona-toolkit的主要功能

- Verify MySQL replication integrity by checking master and replica data consistency
- Efficiently archive rows
- Find duplicate indexes
- Summarize MySQL servers
- Analyze queries from logs and tcpdump
- Collect vital system information when problems occur

## 2、安装需求及步骤

下载连接：[http://www.percona.com/software/percona-toolkit](http://www.percona.com/software/percona-toolkit)

需求
- Perl v5.8 or newer
- Bash v3 or newer
- Core Perl modules like Time::HiRes
```
perl --version |head -2 #检查perl版本
bash --version          #检查bash版本
```

快速安装步骤(缺省/usr/local/bin路径下，过程略)

```angular2
# tar zxvf percona-toolkit-<version>.tar.gz
# cd percona-toolkit-<version>
# perl Makefile.PL   (安装到非缺省目录 perl Makefile.PL PREFIX=${HOME})
# make
# make test
# make install
```

## 3、主要工具介绍

如果是非源码安装或源码安装是未指定路径，缺省情况下所有的pt相关的工具位于/usr/bin目录下，以pt-开头。
获取有关命令行的帮助信息，直接在shell提示符下输入命令行与--hlep即可。如： `/usr/bin/pt-upgrade --help`

`# ls -hltr /usr/bin/pt-*`

### pt-upgrade 

    该命令主要用于对比不同mysql版本下SQL执行的差异，通常用于升级前进行对比。
    会生成SQL文件或单独的SQL语句在每个服务器上执行的结果、错误和警告信息等。 

### pt-online-schema-change

    功能为支持在线变更表构，且不锁定原表，不阻塞原表的DML操作。
    该特性与Oracle的dbms_redefinition在线重定义表原理基本类似。

### pt-mysql-summary
    
    对连接的mysql服务器生成一份详细的配置情况以及sataus信息
    在尾部也提供当前实例的的配置文件的信息
    
### pt-mext
    
    并行查看SHOW GLOBAL STATUS的多个样本的信息。
    pt-mext会执行你指定的COMMAND，并每次读取一行结果，把空行分割的内容保存到一个一个的临时文件中，最后结合这些临时文件并行查看结果。

### pt-kill
    
    Kill掉符合指定条件mysql语句
    
### pt-ioprofile

    pt-ioprofile的原理是对某个pid附加一个strace进程进行IO分析
    
### pt-fingerprint
    
    用于生成查询指纹。主要将将sql查询生成queryID，pt-query-digest中的ID即是通过此工具来完成的。
    类似于Oracle中的SQL_ID，涉及绑定变量，字面量等

### pt-find

    用与查找mysql表并执行指定的命令，类似于find命令
    
### pt-fifo-split

    模拟切割文件并通过管道传递给先入先出队列而不用真正的切割文件
    
### pt-deadlock-logger

    用于监控mysql服务器上死锁并输出到日志文件，日志包含发生死锁的时间、死锁线程id、死锁的事务id、发生死锁时事务执行时间等详细信息。
    
### pt-archiver
    
    将mysql数据库中表的记录归档到另外一个表或者文件
    该工具具只是归档旧的数据，对线上数据的OLTP查询几乎没有影响。
    可以将数据插入另外一台服务器的其他表中，也可以写入到一个文件中，方便使用load data infile命令导入数据。

### pt-agent

    基于Percona Cloud的一个客户端代理工具
    
### pt-visual-explain

    用于格式化explain的输出
    
### pt-variable-advisor
    
    用于分析mysql系统变量可能存在的一些问题，可以据此评估有关参数的设置正确与否。

### pt-stalk

    用于收集mysql数据库故障时的相关信息便于后续诊断处理。
    
### pt-slave-delay

    用于设定从服务器落后于主服务器的时间间隔。
    该命令行通过启动和停止复制sql线程来设置从落后于主指定时间。
    
### pt-sift

    用于浏览pt-stalk生成的文件。
    
### pt-show-grants
    将当前实例的用户权限全部输出，可以用于迁移数据库过程中重建用户。
    
### pt-query-digest
    用于分析mysql服务器的慢查询日志，并格式化输出以便于查看和分析。
  
### pt-pmp
    为查询程序执行聚合的GDB堆栈跟踪，先进性堆栈跟踪，然后将跟踪信息汇总。 
    
### pt-index-usage
    从log文件中读取查询语句，并用分析当前索引如何被使用。
    完成分析之后会生成一份关于索引没有被查询使用过的报告，可以用于分析报告考虑剔除无用的索引。
    
### pt-heartbeat
    用于监控mysql复制架构的延迟。
    主要是通过在主库上的--update线程持续更新指定表上的一个时间戳，从库上--monitor线程或者--check线程检查主库更新的时间戳并与当前系统时间对比，得到延迟值。

### pt-fk-error-logger
    将外键相关的错误信息记录到日志或表。
  
### pt-duplicate-key-checker 
    功能为从mysql表中找出重复的索引和外键，这个工具会将重复的索引和外键都列出来
    同时也可以生成相应的drop index的语句
     
### pt-diskstats
    类似于iostat，打印磁盘io统计信息，但是这个工具是交互式并且比iostat更详细。可以分析从远程机器收集的数据。
  
### pt-config-diff
    用于比较mysql配置文件和服务器变量
    至少2个配置源需要指定，可以用于迁移或升级前后配置文件进行对比
    
### pt-align
    格式化输出
    
### pt-slave-find
    连接mysql主服务器并查找其所有的从，然后打印出所有从服务器的层级关系。
    
###  pt-table-checksum
    用于校验mysql复制的一致性。
    该工具主要是高效的查找数据差异，如果存在差异性，可以通过pt-table-sync来解决。

    
    
    
    
    
    
    
    




