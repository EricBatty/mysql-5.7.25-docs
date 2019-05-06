# pt-heartbeat

pt-heartbeat - 监控MySQL主从复制延迟。

## 用法

```angular2
pt-heartbeat [OPTIONS] [DSN] --update|--monitor|--check|--stop
```
`pt-heartbeat` 测量MySQL或PostgreSQL服务器上的复制延迟。您可以使用它来更新主服务器或监控副本。如果可能，可以从.my.cnf文件中读取MySQL连接选项。

启动守护进程以更新master上的test.heartbeat表：

```angular2
[root@node90 ~]# pt-heartbeat -D test --user root --password MyNewPass4! --create-table --update -h 192.168.0.90:3306  --daemonize
```
监视slave上的复制延迟：
```angular2
[root@node91 ~]# ./pt-heartbeat -D test -h 192.168.0.91:3306 --user root --password MyNewPass4! --monitor
0.00s [  0.00s,  0.00s,  0.00s ]
0.00s [  0.00s,  0.00s,  0.00s ]
0.00s [  0.00s,  0.00s,  0.00s ]
```
检查slave一次并退出
```angular2
[root@node91 ~]# ./pt-heartbeat -D test -h 192.168.0.91:3306 --user root --password MyNewPass4! --check
0.00
```

> 注意：test 数据库要被允许主从复制。

## 描述

**pt-heartbeat**是一个由两部分组成的MySQL和PostgreSQL复制延迟监控系统，它通过查看实际的复制数据来测量延迟。这避免了对复制机制本身的依赖，这是不可靠的，例如，在MySQL上SHOW SLAVE STATUS）。


第一部分是**pt-heartbeat --update**实例，它连接到主服务器并每秒`--interval`更新一个时间戳（“心跳记录”） 。由于心跳表可能包含来自多个主服务器的记录（请参阅“MULTI-SLAVE HIERARCHY”），因此服务器的ID（@@ server_id）用于标识记录。

第二部分是连接到从属设备的**pt-heartbeat --monitor**或 **--check**实例，从其直接主设备或指定设备 **--master-server-id**检查复制的心跳记录，并计算与当前系统时间的差异。如果从站和主站之间的复制被延迟或中断，则计算的差值将大于零，并且如果指定 **--monitor** 则可能增加。

您必须在主服务器上手动创建心跳表或使用 --create-table。

心跳表必须包含心跳行。默认情况下，如果心跳行不存在，则会插入心跳行。--[no]insert-heartbeat-row如果数据库用户没有INSERT权限，则可以使用该选项禁用此功能 。

**pt-heartbeat** 仅依赖于被复制到从属服务器的心跳记录，因此无论复制机制如何（内置复制，诸如Continuent Tungsten等系统），它都可以工作。它适用于复制层次结构中的任何深度; 例如，它将可靠地报告一个从库落后其主库的主库的主库。如果复制停止，它将继续工作并报告（准确地说！）从库进一步落后于主库。

**pt-heartbeat** 的最大分辨率为0.01秒。主服务器和从服务器上的时钟必须通过NTP紧密同步。默认情况下， --update检查发生在第二个边缘（例如00:01）， --monitor检查发生在秒的中间（例如00：01.5）。只要服务器的时钟紧密同步并且复制事件在不到半秒的时间内传播，pt-heartbeat将报告零秒的延迟。


## 多个从库

如果复制层次结构具有多个从库，这些从库是其他从库的主库，例如“master - > slave1 - > slave2”，--update则可以在从库和主库上运行实例。默认的心跳表（请参阅--create-table参考资料）是在server_id列上键入的，因此每个服务器都会更新行所在的位置server_id=@@server_id。

对于--monitor和--check，如果--master-server-id未指定，该工具会尝试发现并使用从库的直接主库。如果此操作失败，或者您希望监视器滞后于另一个主服务器，则可以指定--master-server-id使用。

例如，如果复制层次结构为“master - > slave1 - > slave2”，并且具有相应的服务器ID 1,2和3，则可以：

```angular2
pt-heartbeat --daemonize -D test --update -h master 
pt-heartbeat --daemonize -D test --update -h slave1
```
然后检查（或监视）从master到slave2的复制延迟：
```angular2
pt-heartbeat -D test --master-server-id 1 --check slave2
```
或者检查从slave1到slave2的复制延迟：
```angular2
pt-heartbeat -D test --master-server-id 2 --check slave2
```
停止一个--update实例不回影响另一个实例，比如停止slave1不会影响master。


## 选项介绍

### 必需接收的选项：
```angular2
至少一个--stop，--update，--monitor，或--check。
--update，--monitor和，--check是相互排斥的。
--daemonize并且--check是相互排斥的。
```

### --ask-pass
连接到MySQL时提示输入密码。
### --charset
简短形式：-A; type：string

默认字符集。如果值为utf8，则将STDOUT上的Perl的binmode设置为utf8，将mysql_enable_utf8选项传递给DBD :: mysql，并在连接到MySQL后运行SET NAMES UTF8。任何其他值在不带utf8层的STDOUT上设置binmode，并在连接到MySQL后运行SET NAMES。

### --check
检查从机延迟一次并退出。如果您还指定--recurse，该工具将尝试发现给定从库的从库并检查并打印它们的延迟。每个从库的主机名或IP和端口在延迟之前打印。 --recurse仅适用于MySQL

### --check-read-only
检查服务器是否已启用read_only; 如果是这样，该工具会跳过任何插入。也可以看看--read-only-interval

### --config
type：数组

阅读这个以逗号分隔的配置文件列表; 如果指定，则必须是命令行上的第一个选项。

### --create-table
--table如果心跳不存在，请创建心跳。
此选项使用以下MAGIC_create_heartbeat表定义创建由--database和指定的--table表：
```angular2
CREATE TABLE heartbeat (
  ts                    varchar(26) NOT NULL,
  server_id             int unsigned NOT NULL PRIMARY KEY,
  file                  varchar(255) DEFAULT NULL,    -- SHOW MASTER STATUS
  position              bigint unsigned DEFAULT NULL, -- SHOW MASTER STATUS
  relay_master_log_file varchar(255) DEFAULT NULL,    -- SHOW SLAVE STATUS
  exec_master_log_pos   bigint unsigned DEFAULT NULL  -- SHOW SLAVE STATUS
);
```
心跳表至少需要一行。如果手动创建心跳表，则必须通过执行以下操作来插入行：
```angular2
INSERT INTO heartbeat (ts, server_id) VALUES (NOW(), N);
or if using --utc:
INSERT INTO heartbeat (ts, server_id) VALUES (UTC_TIMESTAMP(), N);
N服务器的ID; 不要使用@@ server_id，因为它将进行复制，而且使用@@ server_id，slave将插入自己的服务器ID而不是master的服务器ID.
```

### --create-table-engine
type：string

设置要用于心跳表的引擎。默认存储引擎是从MySQL 5.5.5开始的InnoDB。

### --daemonize
后台运行

### --database
简称：-D; type：string

用于连接的数据库。

###--dbi-driver
默认值：mysql; type：string

指定连接的驱动程序; mysql并Pg得到支持。

### --defaults-file
简短形式：-F; type：string

仅从给定文件中读取mysql选项。您必须提供绝对路径名。

### --file
type：string

将最新--monitor输出打印到此文件。

当--monitor给定，打印输出到指定的文件，而不是到stdout。该文件每隔一段时间打开，截断和关闭，因此它只包含最新的统计信息。--daemonize给出时很有用。

### --frames
type：string; 默认值：1分钟，5分钟，15分钟

平均值的时间范围。

### --host
简短形式：-h; type：string

连接到主机。

### --[no]insert-heartbeat-row
默认：是的

--table如果一个心跳行不存在，请插入一个心跳行。

心跳--table需要一个心跳行，别的没有什么--update，--monitor或--check！默认情况下，如果尚未存在心跳行，该工具将插入心跳行。您可以通过指定--no-insert-heartbeat-row数据库用户没有INSERT权限来禁用此功能。

### --interval
type：float; 默认值：1.0

每隔几秒更新一次或者检查一次。

### --log
type：string

守护进程时将所有输出打印到此文件。

### --master-server-id
type：string

计算此主服务器ID的延迟--monitor或--check。如果没有给出，pt-heartbeat会尝试连接到服务器的主服务器并确定其服务器ID。

### --monitor
持续监控从机延迟。

指定pt-heartbeat应每秒检查从属的延迟并向STDOUT报告（或者如果--file给定，则报告给文件）。输出是当前延迟，然后是在给定的时间范围内的移动平均值 --frames。例如，

### --fail-successive-errors
type：int

如果指定，则在给定数量的连续DBI错误（无法连接到服务器或发出查询）后，pt-heartbeat将失败。

### --password
简短形式：-p; type：string

连接时使用的密码。如果密码包含逗号，则必须使用反斜杠进行转义：“exam，ple”

### --pid
type：string

创建给定的PID文件。如果PID文件已存在并且其包含的PID与当前PID不同，则该工具将不会启动。但是，如果PID文件存在且其包含的PID不再运行，则该工具将使用当前PID覆盖PID文件。退出工具时会自动删除PID文件。

### --port
简短形式：-P; type：int

用于连接的端口号。

### --print-master-server-id
打印自动检测或给定--master-server-id。如果--check 或--monitor指定，则指定此选项将打印自动检测到或--master-server-id在每行末尾给出。

### --read-only-interval
type：int

时--check-read-only指定，而被发现服务器是只读的间隔睡觉。如果未指定，--interval则使用。

### --recurse
type：int

在--check模式下以递归方式检查从属到此深度。

尝试以递归方式发现从属服务器到指定的深度。发现服务器后，对每个服务器运行检查并打印主机名（如果可能），然后是从属延迟。

这目前仅适用于MySQL。见--recursion-method。

### --replace
使用REPLACE而不是UPDATEfor -update。

在--update模式下运行时，请使用REPLACE而不是UPDATE设置心跳表的时间戳。该REPLACE语句是SQL的MySQL扩展。当您不知道表是否包含任何行时，此选项很有用。它必须与-update一起使用。

### --run-time
类型：时间

退出前的时间。

### --sentinel
type：string; 默认值：/ tmp / pt-heartbeat-sentinel

如果此文件存在则退出。

### --slave-user
type：string

设置用于连接从站的用户。此参数允许您使用具有较少权限的其他用户，但该用户必须存在于所有从属服务器上。

### --slave-password
type：string

设置用于连接从站的密码。它可以与-slave-user一起使用，并且用户的密码在所有从站上必须相同。

### --set-vars
type：数组

在此逗号分隔的variable=value对列表中设置MySQL变量。

默认情况下，工具集：

wait_timeout = 10000
命令行中指定的变量会覆盖这些默认值。例如，指定覆盖默认值。--set-vars wait_timeout=50010000

该工具会打印警告，并在无法设置变量时继续。

### --skew
type：float; 默认值：0.5

延迟检查多长时间。

默认是延迟检查半秒。由于更新在主设备上的第二个开始之后尽快发生，因此在报告从设备滞后主设备一秒之前，这允许复制延迟的半秒。如果你的时钟不完全准确，或者你想要或多或少地延迟奴隶，你可以调整这个值。尝试设置PTDEBUG环境变量以查看其具有的效果。

### --socket
简短形式：-S; type：string

用于连接的套接字文件。

### --table
type：string; 默认值：心跳

用于心跳的表。

不要指定database.table; 用于--database指定数据库。

见--create-table。

### --update
更新主人的心跳。

### --user
简短形式：-u; type：string

用户登录，如果不是当前用户。

### --utc
忽略系统时区并仅使用UTC。默认情况下，pt-heartbeat不会检查或调整不同的系统或MySQL时区，这可能导致工具错误地计算滞后。指定此选项是个好主意，因为它可确保工具无论时区如何都能正常工作。

如果使用，必须用于所有该选项PT-心跳实例： --update，--monitor，--check等你或许应该设置一个选项--config文件。将此选项与 不使用此选项的pt-heartbeat实例混合将导致由于不同时区导致的误报滞后读数（除非您的所有系统都设置为使用UTC，在这种情况下不需要此选项）。

### --version
显示版本并退出。


### --[no]version-check
默认：是的

检查Percona Toolkit，MySQL和其他程序的最新版本。

这是标准的“自动检查更新”功能，具有两个附加功能。首先，该工具检查自己的版本以及以下软件的版本：操作系统，Percona监控和管理（PMM），MySQL，Perl，Perl的MySQL驱动程序（DBD :: mysql）和Percona Toolkit。其次，它会检查并警告已知问题的版本。例如，MySQL 5.5.25有一个严重错误，并重新发布为5.5.25a。

与Percona的Version Check数据库服务器建立安全连接以执行这些检查。服务器记录每个请求，包括软件版本号和已检查系统的唯一ID。该ID由Percona Toolkit安装脚本生成，或者第一次完成Version Check数据库调用时生成。

在工具正常输出之前，任何更新或已知问题都会打印到STDOUT。此功能不应干扰工具的正常操作。












