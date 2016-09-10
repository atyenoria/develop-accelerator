- use mysql -u root -h "docker network"dke  after copntainer login


# performance comparison result 20160203

#read
mysqlslap \
 --no-defaults --auto-generate-sql --engine=innodb --auto-generate-sql-add-autoincrement \
 --host=localhost --port=3306 -u root \
 --number-int-cols=10 \
 --number-char-cols=10 \
 --iterations=1 \
 --concurrency=50 \
 --auto-generate-sql-write-number=3000 \
 --number-of-queries=3000 \
 --auto-generate-sql-load-type=read \
 -u root -proot -h 172.17.0.2

#write
 mysqlslap \
 --no-defaults --auto-generate-sql --engine=innodb --auto-generate-sql-add-autoincrement \
 --host=localhost --port=3306 -u root \
 --number-int-cols=10 \
 --number-char-cols=10 \
 --iterations=1 \
 --concurrency=50 \
 --auto-generate-sql-write-number=3000 \
 --number-of-queries=3000 \
 --auto-generate-sql-load-type=write \
-u root -proot -h 172.17.0.2

##  one master- one sløave in mysql container only(not multihost)  benchmark

root@43f297263a65:/# mysqlslap \
<e-sql --engine=innodb --auto-generate-sql-add-autoincrement \
>  --host=localhost --port=3306 -u root \
>  --number-int-cols=10 \
>  --number-char-cols=10 \
>  --iterations=1 \
>  --concurrency=50 \
>  --auto-generate-sql-write-number=3000 \
>  --number-of-queries=3000 \
>  --auto-generate-sql-load-type=read \
>  -u root -proot -h 172.17.0.2
Warning: Using a password on the command line interface can be insecure.
Benchmark
    Running for engine innodb
    Average number of seconds to run all queries: 8.755 seconds
    Minimum number of seconds to run all queries: 8.755 seconds
    Maximum number of seconds to run all queries: 8.755 seconds
    Number of clients running queries: 50
    Average number of queries per client: 60


root@43f297263a65:/# mysqlslap \
<e-sql --engine=innodb --auto-generate-sql-add-autoincrement \
>  --host=localhost --port=3306 -u root \
>  --number-int-cols=10 \
>  --number-char-cols=10 \
>  --iterations=1 \
>  --concurrency=50 \
>  --auto-generate-sql-write-number=3000 \
>  --number-of-queries=3000 \
>  --auto-generate-sql-load-type=write \
> -u root -proot -h 172.17.0.2
Warning: Using a password on the command line interface can be insecure.

Benchmark
    Running for engine innodb
    Average number of seconds to run all queries: 0.414 seconds
    Minimum number of seconds to run all queries: 0.414 seconds
    Maximum number of seconds to run all queries: 0.414 seconds
    Number of clients running queries: 50
    Average number of queries per client: 60


## galera cluster 3 node


root@027b0bd3259e:/etc/mysql# mysqlslap \
<e-sql --engine=innodb --auto-generate-sql-add-autoincrement \
>  --host=localhost --port=3306 -u root \
>  --number-int-cols=10 \
>  --number-char-cols=10 \
>  --iterations=1 \
>  --concurrency=50 \
>  --auto-generate-sql-write-number=3000 \
>  --number-of-queries=3000 \
>  --auto-generate-sql-load-type=read \
>  -u root -proot -h 172.17.0.2
Benchmark
    Running for engine innodb
    Average number of seconds to run all queries: 8.976 seconds
    Minimum number of seconds to run all queries: 8.976 seconds
    Maximum number of seconds to run all queries: 8.976 seconds
    Number of clients running queries: 50
    Average number of queries per client: 60




root@027b0bd3259e:/etc/mysql#  mysqlslap \
<e-sql --engine=innodb --auto-generate-sql-add-autoincrement \
>  --host=localhost --port=3306 -u root \
>  --number-int-cols=10 \
>  --number-char-cols=10 \
>  --iterations=1 \
>  --concurrency=50 \
>  --auto-generate-sql-write-number=3000 \
>  --number-of-queries=3000 \
>  --auto-generate-sql-load-type=write \
> -u root -proot -h 172.17.0.2
Benchmark
    Running for engine innodb
    Average number of seconds to run all queries: 2.822 seconds
    Minimum number of seconds to run all queries: 2.822 seconds
    Maximum number of seconds to run all queries: 2.822 seconds
    Number of clients running queries: 50
    Average number of queries per client: 60




##  one master- two slave in multi host benchmark
root@be6d0cda3805:/var/lib/mysql# mysqlslap \
<e-sql --engine=innodb --auto-generate-sql-add-autoincrement \
>  --host=localhost --port=3306 -u root \
>  --number-int-cols=10 \
>  --number-char-cols=10 \
>  --iterations=1 \
>  --concurrency=50 \
>  --auto-generate-sql-write-number=3000 \
>  --number-of-queries=3000 \
>  --auto-generate-sql-load-type=read \
>  -u root -proot -h 172.17.0.2
Warning: Using a password on the command line interface can be insecure.
Benchmark
    Running for engine innodb
    Average number of seconds to run all queries: 8.809 seconds
    Minimum number of seconds to run all queries: 8.809 seconds
    Maximum number of seconds to run all queries: 8.809 seconds
    Number of clients running queries: 50
    Average number of queries per client: 60

root@be6d0cda3805:/var/lib/mysql# mysqlslap \
<e-sql --engine=innodb --auto-generate-sql-add-autoincrement \
>  --host=localhost --port=3306 -u root \
>  --number-int-cols=10 \
>  --number-char-cols=10 \
>  --iterations=1 \
>  --concurrency=50 \
>  --auto-generate-sql-write-number=3000 \
>  --number-of-queries=3000 \
>  --auto-generate-sql-load-type=write \
> -u root -proot -h 172.17.0.2
Warning: Using a password on the command line interface can be insecure.
Benchmark
    Running for engine innodb
    Average number of seconds to run all queries: 0.581 seconds
    Minimum number of seconds to run all queries: 0.581 seconds
    Maximum number of seconds to run all queries: 0.581 seconds
    Number of clients running queries: 50
    Average number of queries per client: 60