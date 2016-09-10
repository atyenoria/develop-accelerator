#cluster health check
mysql -h l1.com -u root -proot -e "show status like 'wsrep%';"
mysql -h l1.com -u root -proot -e "show status like '%';"




GRANT ALL PRIVILEGES ON *.* TO root@'192.168.%' IDENTIFIED BY 'root' WITH GRANT OPTION;




mysqld_safe --wsrep-new-cluster --init-file=/tmp/bootstrap.sql

service mysql start --wsrep-new-cluster --init-file=/tmp/bootstrap.sql
service mysql start --init-file=/tmp/bootstrap.sql


show status like 'wsrep_%';

mysql -h l1.com -u root -proot -e "show status like 'wsrep_%';"
mysql -h l1.com -u root -p



mysql -h l1.com -u root -pmariadb_admin_password -e 'CREATE TABLE playground.equipment ( id INT NOT NULL AUTO_INCREMENT, type VARCHAR(50), quant INT, color VARCHAR(25), PRIMARY KEY(id));'

mysql -h l2.com -u root -pmariadb_admin_password -e 'CREATE TABLE playground.equipment ( id INT NOT NULL AUTO_INCREMENT, type VARCHAR(50), quant INT, color VARCHAR(25), PRIMARY KEY(id));'





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
 -u root -proot


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
 -u root -p

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
  -u root -proot

#read primary key
 mysqlslap \
 --no-defaults --auto-generate-sql --engine=innodb --auto-generate-sql-add-autoincrement \
 --host=localhost --port=3306 -u root \
 --number-int-cols=10 \
 --number-char-cols=10 \
 --iterations=1 \
 --concurrency=50 \
 --auto-generate-sql-write-number=3000 \
 --number-of-queries=3000 \
 --auto-generate-sql-load-type=key \
   -u root -proot