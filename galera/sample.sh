cat >/bootstrap_local.sql <<EOF
CREATE USER 'xtrabackup'@'localhost' IDENTIFIED BY '$XTRABACKUP_PASSWORD';
GRANT RELOAD,LOCK TABLES,REPLICATION CLIENT ON *.* TO 'xtrabackup'@'localhost';
CREATE USER 'clustercheck'@'localhost' IDENTIFIED BY '$CLUSTERCHECK_PASSWORD';
GRANT PROCESS ON *.* TO 'clustercheck'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
CREATE DATABASE $MYSQL_DATABASE;
UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
UPDATE mysql.user SET Password=PASSWORD('rfsiROmlu2luB74e') WHERE User='debian-sys-maint';
GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'%' IDENTIFIED BY 'rfsiROmlu2luB74e' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF


cat >/bootstrap_master.sql <<EOF
CREATE USER 'xtrabackup'@'localhost' IDENTIFIED BY '$XTRABACKUP_PASSWORD';
GRANT RELOAD,LOCK TABLES,REPLICATION CLIENT ON *.* TO 'xtrabackup'@'localhost';
CREATE USER 'clustercheck'@'localhost' IDENTIFIED BY '$CLUSTERCHECK_PASSWORD';
GRANT PROCESS ON *.* TO 'clustercheck'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
CREATE DATABASE $MYSQL_DATABASE;
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
UPDATE mysql.user SET Password=PASSWORD('rfsiROmlu2luB74e') WHERE User='debian-sys-maint';
GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'%' IDENTIFIED BY 'rfsiROmlu2luB74e' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF



cat >/bootstrap_slave.sql <<EOF
CREATE USER 'xtrabackup'@'localhost' IDENTIFIED BY '$XTRABACKUP_PASSWORD';
GRANT RELOAD,LOCK TABLES,REPLICATION CLIENT ON *.* TO 'xtrabackup'@'localhost';
CREATE USER 'clustercheck'@'localhost' IDENTIFIED BY '$CLUSTERCHECK_PASSWORD';
GRANT PROCESS ON *.* TO 'clustercheck'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
UPDATE mysql.user SET Password=PASSWORD('rfsiROmlu2luB74e') WHERE User='debian-sys-maint';
GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'%' IDENTIFIED BY 'rfsiROmlu2luB74e' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
