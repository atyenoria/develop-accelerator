```bash
$ docker run -d -v /data:/var/lib/mysql -p 3306 -p 8080 \
    -e XTRABACKUP_PASSWORD=abc -e MYSQL_ROOT_PASSWORD=secret \
    sttts/galera-mariadb-10.0-xtrabackup seed

$ docker run -d -v /data:/var/lib/mysql -p 3306 -p 8080 \
    sttts/galera-mariadb-10.0-xtrabackup \
    -e XTRABACKUP_PASSWORD=abc \
    node 172.17.0.81,172.17.0.97

$ docker run -d -v /data:/var/lib/mysql -p 3306 -p 8080 \
    sttts/galera-mariadb-10.0-xtrabackup \
    -e XTRABACKUP_PASSWORD=abc \
    node 172.17.0.81 --any-mysql-argument-you-like
```

#makefile
all: build

.PHONY: build push master node

build:
    docker build -t "sttts/galera-mariadb-10.0-xtrabackup:$$(git rev-parse HEAD)" .

push:
    docker push "sttts/galera-mariadb-10.0-xtrabackup:$$(git rev-parse HEAD)"

master:
    docker run -it -e XTRABACKUP_PASSWORD=geheim -e MYSQL_ROOT_PASSWORD=geheim -p 8080:8080 -p 3306:3306 --name master --rm sttts/galera-mariadb-10.0-xtrabackup:$$(git rev-parse HEAD) master

node:
    docker run -it -e XTRABACKUP_PASSWORD=geheim -e MYSQL_ROOT_PASSWORD=geheim -p 8081:8080 --name node --rm sttts/galera-mariadb-10.0-xtrabackup:$$(git rev-parse HEAD) node 1.2.3.4




root@92adb687bf86:/var/lib/mysql# mysql_install_db --help
Usage: /usr/bin/mysql_install_db [OPTIONS]
  --basedir=path       The path to the MariaDB installation directory.
  --builddir=path      If using --srcdir with out-of-directory builds, you
                       will need to set this to the location of the build
                       directory where built files reside.
  --cross-bootstrap    For internal use.  Used when building the MariaDB system
                       tables on a different host than the target.
  --datadir=path       The path to the MariaDB data directory.
  --defaults-extra-file=name
                       Read this file after the global files are read.
  --defaults-file=name Only read default options from the given file name.
  --force              Causes mysql_install_db to run even if DNS does not
                       work.  In that case, grant table entries that
                       normally use hostnames will use IP addresses.
  --help               Display this help and exit.
  --ldata=path         The path to the MariaDB data directory. Same as
                       --datadir.
  --no-defaults        Don't read default options from any option file.
  --defaults-file=path Read only this configuration file.
  --rpm                For internal use.  This option is used by RPM files
                       during the MariaDB installation process.
  --skip-name-resolve  Use IP addresses rather than hostnames when creating
                       grant table entries.  This option can be useful if
                       your DNS does not work.
  --srcdir=path        The path to the MariaDB source directory.  This option
                       uses the compiled binaries and support files within the
                       source tree, useful for if you don't want to install
                       MariaDB yet and just want to create the system tables.
  --user=user_name     The login username to use for running mysqld.  Files
                       and directories created by mysqld will be owned by this
                       user.  You must be root to use this option.  By default
                       mysqld runs using your current login name and files and
                       directories that it creates will be owned by you.

All other options are passed to the mysqld program






















root@92adb687bf86:/var/lib/mysql# mysql --help
mysql  Ver 15.1 Distrib 10.0.23-MariaDB, for debian-linux-gnu (x86_64) using readline 5.2
Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Usage: mysql [OPTIONS] [database]

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf
The following groups are read: mysql client client-server client-mariadb
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.

  -?, --help          Display this help and exit.
  -I, --help          Synonym for -?
  --abort-source-on-error
                      Abort 'source filename' operations in case of errors
  --auto-rehash       Enable automatic rehashing. One doesn't need to use
                      'rehash' to get table and field completion, but startup
                      and reconnecting may take a longer time. Disable with
                      --disable-auto-rehash.
                      (Defaults to on; use --skip-auto-rehash to disable.)
  -A, --no-auto-rehash
                      No automatic rehashing. One has to use 'rehash' to get
                      table and field completion. This gives a quicker start of
                      mysql and disables rehashing on reconnect.
  --auto-vertical-output
                      Automatically switch to vertical output mode if the
                      result is wider than the terminal width.
  -B, --batch         Don't use history file. Disable interactive behavior.
                      (Enables --silent.)
  --character-sets-dir=name
                      Directory for character set files.
  --column-type-info  Display column type information.
  -c, --comments      Preserve comments. Send comments to the server. The
                      default is --skip-comments (discard comments), enable
                      with --comments.
  -C, --compress      Use compression in server/client protocol.
  -#, --debug[=#]     This is a non-debug version. Catch this and exit.
  --debug-check       Check memory and open file usage at exit.
  -T, --debug-info    Print some debug info at exit.
  -D, --database=name Database to use.
  --default-character-set=name
                      Set the default character set.
  --delimiter=name    Delimiter to be used.
  -e, --execute=name  Execute command and quit. (Disables --force and history
                      file.)
  -E, --vertical      Print the output of a query (rows) vertically.
  -f, --force         Continue even if we get an SQL error. Sets
                      abort-source-on-error to 0
  -G, --named-commands
                      Enable named commands. Named commands mean this program's
                      internal commands; see mysql> help . When enabled, the
                      named commands can be used from any line of the query,
                      otherwise only from the first line, before an enter.
                      Disable with --disable-named-commands. This option is
                      disabled by default.
  -i, --ignore-spaces Ignore space after function names.
  --init-command=name SQL Command to execute when connecting to MySQL server.
                      Will automatically be re-executed when reconnecting.
  --local-infile      Enable/disable LOAD DATA LOCAL INFILE.
  -b, --no-beep       Turn off beep on error.
  -h, --host=name     Connect to host.
  -H, --html          Produce HTML output.
  -X, --xml           Produce XML output.
  --line-numbers      Write line numbers for errors.
                      (Defaults to on; use --skip-line-numbers to disable.)
  -L, --skip-line-numbers
                      Don't write line number for errors.
  -n, --unbuffered    Flush buffer after each query.
  --column-names      Write column names in results.
                      (Defaults to on; use --skip-column-names to disable.)
  -N, --skip-column-names
                      Don't write column names in results.
  --sigint-ignore     Ignore SIGINT (CTRL-C).
  -o, --one-database  Ignore statements except those that occur while the
                      default database is the one named at the command line.
  --pager[=name]      Pager to use to display results. If you don't supply an
                      option, the default pager is taken from your ENV variable
                      PAGER. Valid pagers are less, more, cat [> filename],
                      etc. See interactive help (\h) also. This option does not
                      work in batch mode. Disable with --disable-pager. This
                      option is disabled by default.
  -p, --password[=name]
                      Password to use when connecting to server. If password is
                      not given it's asked from the tty.
  -P, --port=#        Port number to use for connection or 0 for default to, in
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
                      /etc/services, built-in default (3306).
  --progress-reports  Get progress reports for long running commands (like
                      ALTER TABLE)
                      (Defaults to on; use --skip-progress-reports to disable.)
  --prompt=name       Set the mysql prompt to this value.
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -q, --quick         Don't cache result, print it row by row. This may slow
                      down the server if the output is suspended. Doesn't use
                      history file.
  -r, --raw           Write fields without conversion. Used with --batch.
  --reconnect         Reconnect if the connection is lost. Disable with
                      --disable-reconnect. This option is enabled by default.
                      (Defaults to on; use --skip-reconnect to disable.)
  -s, --silent        Be more silent. Print results with a tab as separator,
                      each row on new line.
  -S, --socket=name   The socket file to use for connection.
  --ssl               Enable SSL for connection (automatically enabled with
                      other flags).
  --ssl-ca=name       CA file in PEM format (check OpenSSL docs, implies
                      --ssl).
  --ssl-capath=name   CA directory (check OpenSSL docs, implies --ssl).
  --ssl-cert=name     X509 cert in PEM format (implies --ssl).
  --ssl-cipher=name   SSL cipher to use (implies --ssl).
  --ssl-key=name      X509 key in PEM format (implies --ssl).
  --ssl-crl=name      Certificate revocation list (implies --ssl).
  --ssl-crlpath=name  Certificate revocation list path (implies --ssl).
  --ssl-verify-server-cert
                      Verify server's "Common Name" in its cert against
                      hostname used when connecting. This option is disabled by
                      default.
  -t, --table         Output in table format.
  --tee=name          Append everything into outfile. See interactive help (\h)
                      also. Does not work in batch mode. Disable with
                      --disable-tee. This option is disabled by default.
  -u, --user=name     User for login if not current user.
  -U, --safe-updates  Only allow UPDATE and DELETE that uses keys.
  -U, --i-am-a-dummy  Synonym for option --safe-updates, -U.
  -v, --verbose       Write more. (-v -v -v gives the table output format).
  -V, --version       Output version information and exit.
  -w, --wait          Wait and retry if connection is down.
  --connect-timeout=# Number of seconds before connection timeout.
  --max-allowed-packet=#
                      The maximum packet length to send to or receive from
                      server.
  --net-buffer-length=#
                      The buffer size for TCP/IP and socket communication.
  --select-limit=#    Automatic limit for SELECT when using --safe-updates.
  --max-join-size=#   Automatic limit for rows in a join when using
                      --safe-updates.
  --secure-auth       Refuse client connecting to server if it uses old
                      (pre-4.1.1) protocol.
  --server-arg=name   Send embedded server this as a parameter.
  --show-warnings     Show warnings after every statement.
  --plugin-dir=name   Directory for client-side plugins.
  --default-auth=name Default authentication client-side plugin to use.
  --binary-mode       By default, ASCII '\0' is disallowed and '\r\n' is
                      translated to '\n'. This switch turns off both features,
                      and also turns off parsing of all clientcommands except
                      \C and DELIMITER, in non-interactive mode (for input
                      piped to mysql or loaded using the 'source' command).
                      This is necessary when processing output from mysqlbinlog
                      that may contain blobs.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- ----------------------------------------
abort-source-on-error             FALSE
auto-rehash                       TRUE
auto-vertical-output              FALSE
character-sets-dir                (No default value)
column-type-info                  FALSE
comments                          FALSE
compress                          FALSE
debug-check                       FALSE
debug-info                        FALSE
database                          (No default value)
default-character-set             utf8
delimiter                         ;
vertical                          FALSE
force                             FALSE
named-commands                    FALSE
ignore-spaces                     FALSE
init-command                      (No default value)
local-infile                      FALSE
no-beep                           FALSE
host                              (No default value)
html                              FALSE
xml                               FALSE
line-numbers                      TRUE
unbuffered                        FALSE
column-names                      TRUE
sigint-ignore                     FALSE
port                              3306
progress-reports                  TRUE
prompt                            \N [\d]>
quick                             FALSE
raw                               FALSE
reconnect                         TRUE
socket                            /var/run/mysqld/mysqld.sock
ssl                               FALSE
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-crl                           (No default value)
ssl-crlpath                       (No default value)
ssl-verify-server-cert            FALSE
table                             FALSE
user                              (No default value)
safe-updates                      FALSE
i-am-a-dummy                      FALSE
connect-timeout                   0
max-allowed-packet                16777216
net-buffer-length                 16384
select-limit                      1000
max-join-size                     1000000
secure-auth                       FALSE
show-warnings                     FALSE
plugin-dir                        (No default value)
default-auth                      (No default value)
binary-mode                       FALSE



























root@92adb687bf86:/var/lib/mysql# mysqladmin --help
mysqladmin  Ver 9.1 Distrib 10.0.23-MariaDB, for debian-linux-gnu on x86_64
Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Administration program for the mysqld daemon.
Usage: mysqladmin [OPTIONS] command command....

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf
The following groups are read: mysqladmin client client-server client-mariadb
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.

  -c, --count=#       Number of iterations to make. This works with -i
                      (--sleep) only.
  --debug-check       Check memory and open file usage at exit.
  --debug-info        Print some debug info at exit.
  -f, --force         Don't ask for confirmation on drop database; with
                      multiple commands, continue even if an error occurs.
  -C, --compress      Use compression in server/client protocol.
  --character-sets-dir=name
                      Directory for character set files.
  --default-character-set=name
                      Set the default character set.
  -?, --help          Display this help and exit.
  -h, --host=name     Connect to host.
  -b, --no-beep       Turn off beep on error.
  -p, --password[=name]
                      Password to use when connecting to server. If password is
                      not given it's asked from the tty.
  -P, --port=#        Port number to use for connection or 0 for default to, in
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
                      /etc/services, built-in default (3306).
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -r, --relative      Show difference between current and previous values when
                      used with -i. Currently only works with extended-status.
  -s, --silent        Silently exit if one can't connect to server.
  -S, --socket=name   The socket file to use for connection.
  -i, --sleep=#       Execute commands repeatedly with a sleep between.
  --ssl               Enable SSL for connection (automatically enabled with
                      other flags).
  --ssl-ca=name       CA file in PEM format (check OpenSSL docs, implies
                      --ssl).
  --ssl-capath=name   CA directory (check OpenSSL docs, implies --ssl).
  --ssl-cert=name     X509 cert in PEM format (implies --ssl).
  --ssl-cipher=name   SSL cipher to use (implies --ssl).
  --ssl-key=name      X509 key in PEM format (implies --ssl).
  --ssl-crl=name      Certificate revocation list (implies --ssl).
  --ssl-crlpath=name  Certificate revocation list path (implies --ssl).
  --ssl-verify-server-cert
                      Verify server's "Common Name" in its cert against
                      hostname used when connecting. This option is disabled by
                      default.
  -u, --user=name     User for login if not current user.
  -v, --verbose       Write more information.
  -V, --version       Output version information and exit.
  -E, --vertical      Print output vertically. Is similar to --relative, but
                      prints output vertically.
  -w, --wait[=#]      Wait and retry if connection is down.
  --connect-timeout=#
  --shutdown-timeout=#
  --plugin-dir=name   Directory for client-side plugins.
  --default-auth=name Default authentication client-side plugin to use.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- ----------------------------------------
count                             0
debug-check                       FALSE
debug-info                        FALSE
force                             FALSE
compress                          FALSE
character-sets-dir                (No default value)
default-character-set             utf8
host                              (No default value)
no-beep                           FALSE
port                              3306
relative                          FALSE
socket                            /var/run/mysqld/mysqld.sock
sleep                             0
ssl                               FALSE
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-crl                           (No default value)
ssl-crlpath                       (No default value)
ssl-verify-server-cert            FALSE
user                              (No default value)
verbose                           FALSE
vertical                          FALSE
connect-timeout                   43200
shutdown-timeout                  3600
plugin-dir                        (No default value)
default-auth                      (No default value)

Where command is a one or more of: (Commands may be shortened)
  create databasename     Create a new database
  debug           Instruct server to write debug information to log
  drop databasename   Delete a database and all its tables
  extended-status         Gives an extended status message from the server
  flush-all-statistics    Flush all statistics tables
  flush-all-status        Flush status and statistics
  flush-client-statistics Flush client statistics
  flush-hosts             Flush all cached hosts
  flush-index-statistics  Flush index statistics
  flush-logs              Flush all logs
  flush-privileges        Reload grant tables (same as reload)
  flush-slow-log          Flush slow query log
  flush-status        Clear status variables
  flush-table-statistics  Clear table statistics
  flush-tables            Flush all tables
  flush-threads           Flush the thread cache
  flush-user-statistics   Flush user statistics
  kill id,id,...    Kill mysql threads
  password [new-password] Change old password to new-password in current format
  old-password [new-password] Change old password to new-password in old format
  ping          Check if mysqld is alive
  processlist       Show list of active threads in server
  reload        Reload grant tables
  refresh       Flush all tables and close and open logfiles
  shutdown      Take server down
  status        Gives a short status message from the server
  start-slave       Start slave
  stop-slave        Stop slave
  variables             Prints variables available
  version       Get version info from server























root@92adb687bf86:/var/lib/mysql# mysqld_safe --help
Usage: /usr/bin/mysqld_safe [OPTIONS]
  --no-defaults              Don't read the system defaults file
  --core-file-size=LIMIT     Limit core files to the specified size
  --defaults-file=FILE       Use the specified defaults file
  --defaults-extra-file=FILE Also use defaults from the specified file
  --ledir=DIRECTORY          Look for mysqld in the specified directory
  --open-files-limit=LIMIT   Limit the number of open files
  --crash-script=FILE        Script to call when mysqld crashes
  --timezone=TZ              Set the system timezone
  --malloc-lib=LIB           Preload shared library LIB if available
  --mysqld=FILE              Use the specified file as mysqld
  --mysqld-version=VERSION   Use "mysqld-VERSION" as mysqld
  --nice=NICE                Set the scheduling priority of mysqld
  --no-auto-restart          Exit after starting mysqld
  --nowatch                  Exit after starting mysqld
  --plugin-dir=DIR           Plugins are under DIR or DIR/VERSION, if
                             VERSION is given
  --skip-kill-mysqld         Don't try to kill stray mysqld processes
  --syslog                   Log messages to syslog with 'logger'
  --skip-syslog              Log messages to error log (default)
  --syslog-tag=TAG           Pass -t "mysqld-TAG" to 'logger'
  --flush-caches             Flush and purge buffers/caches before
                             starting the server
  --numa-interleave          Run mysqld with its memory interleaved
                             on all NUMA nodes

All other options are passed to the mysqld program.


















root@92adb687bf86:/var/lib/mysql# mysqlshow --help
mysqlshow  Ver 9.10 Distrib 10.0.23-MariaDB, for debian-linux-gnu (x86_64)
Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Shows the structure of a MySQL database (databases, tables, and columns).

Usage: mysqlshow [OPTIONS] [database [table [column]]]

If last argument contains a shell or SQL wildcard (*,?,% or _) then only
what's matched by the wildcard is shown.
If no database is given then all matching databases are shown.
If no table is given, then all matching tables in database are shown.
If no column is given, then all matching columns and column types in table
are shown.

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf
The following groups are read: mysqlshow client client-server client-mariadb
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.

  -c, --character-sets-dir=name
                      Directory for character set files.
  --default-character-set=name
                      Set the default character set.
  --count             Show number of rows per table (may be slow for non-MyISAM
                      tables).
  -C, --compress      Use compression in server/client protocol.
  -#, --debug[=name]  Output debug log. Often this is 'd:t:o,filename'.
  --debug-check       Check memory and open file usage at exit.
  --debug-info        Print some debug info at exit.
  --default-auth=name Default authentication client-side plugin to use.
  -?, --help          Display this help and exit.
  -h, --host=name     Connect to host.
  -i, --status        Shows a lot of extra information about each table.
  -k, --keys          Show keys for table.
  -p, --password[=name]
                      Password to use when connecting to server. If password is
                      not given, it's solicited on the tty.
  --plugin-dir=name   Directory for client-side plugins.
  -P, --port=#        Port number to use for connection or 0 for default to, in
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
                      /etc/services, built-in default (3306).
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -t, --show-table-type
                      Show table type column.
  -S, --socket=name   The socket file to use for connection.
  --ssl               Enable SSL for connection (automatically enabled with
                      other flags).
  --ssl-ca=name       CA file in PEM format (check OpenSSL docs, implies
                      --ssl).
  --ssl-capath=name   CA directory (check OpenSSL docs, implies --ssl).
  --ssl-cert=name     X509 cert in PEM format (implies --ssl).
  --ssl-cipher=name   SSL cipher to use (implies --ssl).
  --ssl-key=name      X509 key in PEM format (implies --ssl).
  --ssl-crl=name      Certificate revocation list (implies --ssl).
  --ssl-crlpath=name  Certificate revocation list path (implies --ssl).
  --ssl-verify-server-cert
                      Verify server's "Common Name" in its cert against
                      hostname used when connecting. This option is disabled by
                      default.
  -u, --user=name     User for login if not current user.
  -v, --verbose       More verbose output; you can use this multiple times to
                      get even more verbose output.
  -V, --version       Output version information and exit.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- ----------------------------------------
character-sets-dir                (No default value)
default-character-set             utf8
count                             FALSE
compress                          FALSE
debug-check                       FALSE
debug-info                        FALSE
default-auth                      (No default value)
host                              (No default value)
status                            FALSE
keys                              FALSE
plugin-dir                        (No default value)
port                              3306
show-table-type                   FALSE
socket                            /var/run/mysqld/mysqld.sock
ssl                               FALSE
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-crl                           (No default value)
ssl-crlpath                       (No default value)
ssl-verify-server-cert            FALSE
user                              (No default value)
























root@92adb687bf86:/var/lib/mysql# xtrabackup --help
xtrabackup version 2.1.8 for Percona Server 5.1.73 unknown-linux-gnu (x86_64) (revision id: undefined)
Open source backup tool for InnoDB and XtraDB

Copyright (C) 2009-2013 Percona LLC and/or its affiliates.
Portions Copyright (C) 2000, 2011, MySQL AB & Innobase Oy. All Rights Reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 2
of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You can download full text of the license on http://www.gnu.org/licenses/gpl-2.0.txt

Usage: [xtrabackup [--defaults-file=#] --backup | xtrabackup [--defaults-file=#] --prepare] [OPTIONS]

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
The following groups are read: mysqld xtrabackup
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.
  -v, --version       print xtrabackup version information
  --target-dir=name   destination directory
  --backup            take backup to target-dir
  --stats             calc statistic of datadir (offline mysqld is recommended)
  --prepare           prepare a backup for starting mysql server on the backup.
  --export            create files to import to another database when prepare.
  --apply-log-only    stop recovery process not to progress LSN after applying
                      log when prepare.
  --print-param       print parameter of mysqld needed for copyback.
  --use-memory=#      The value is used instead of buffer_pool_size
  --suspend-at-start  creates a file 'xtrabackup_suspended_1' and waits until
                      the user deletes that file after the background log
                      copying thread is started during backup
  --suspend-at-end    creates a file 'xtrabackup_suspended_2' and waits until
                      the user deletes that file at the end of '--backup'
  --throttle=#        limit count of IO operations (pairs of read&write) per
                      second to IOS values (for '--backup')
  --log-copy-interval=#
                      time interval between checks done by log copying thread
                      in milliseconds (default is 1 second).
  --extra-lsndir=name (for --backup): save an extra copy of the
                      xtrabackup_checkpoints file in this directory.
  --incremental-lsn=name
                      (for --backup): copy only .ibd pages newer than specified
                      LSN 'high:low'. ##ATTENTION##: If a wrong LSN value is
                      specified, it is impossible to diagnose this, causing the
                      backup to be unusable. Be careful!
  --incremental-basedir=name
                      (for --backup): copy only .ibd pages newer than backup at
                      specified directory.
  --incremental-dir=name
                      (for --prepare): apply .delta files and logfile in the
                      specified directory.
  --tables=name       filtering by regexp for table names.
  --tables_file=name  filtering by list of the exact database.table name in the
                      file.
  --create-ib-logfile ** not work for now** creates ib_logfile* also after
                      '--prepare'. ### If you want create ib_logfile*, only
                      re-execute this command in same options. ###
  -h, --datadir=name  Path to the database root.
  -t, --tmpdir=name   Path for temporary files. Several paths may be specified,
                      separated by a colon (:), in this case they are used in a
                      round-robin fashion.
  --parallel=#        Number of threads to use for parallel datafiles transfer.
                      Does not have any effect in the stream mode. The default
                      value is 1.
  --stream=name       Stream all backup files to the standard output in the
                      specified format. Currently the only supported format is
                      'tar'.
  --compress[=name]   Compress individual backup files using the specified
                      compression algorithm. Currently the only supported
                      algorithm is 'quicklz'. It is also the default algorithm,
                      i.e. the one used when --compress is used without an
                      argument.
  --compress-threads=#
                      Number of threads for parallel data compression. The
                      default value is 1.
  --compress-chunk-size=#
                      Size of working buffer(s) for compression threads in
                      bytes. The default value is 64K.
  --encrypt=#         Encrypt individual backup files using the specified
                      encryption algorithm.
  --encrypt-key=name  Encryption key to use.
  --encrypt-key-file=name
                      File which contains encryption key to use.
  --encrypt-threads=# Number of threads for parallel data encryption. The
                      default value is 1.
  --encrypt-chunk-size=#
                      Size of working buffer(S) for encryption threads in
                      bytes. The default value is 64K.
  --innodb[=name]     Ignored option for MySQL option compatibility
  --innodb_adaptive_hash_index
                      Enable InnoDB adaptive hash index (enabled by default).
                      Disable with --skip-innodb-adaptive-hash-index.
  --innodb_additional_mem_pool_size=#
                      Size of a memory pool InnoDB uses to store data
                      dictionary information and other internal data
                      structures.
  --innodb_autoextend_increment=#
                      Data file autoextend increment in megabytes
  --innodb_buffer_pool_size=#
                      The size of the memory buffer InnoDB uses to cache data
                      and indexes of its tables.
  --innodb_checksums  Enable InnoDB checksums validation (enabled by default).
                      Disable with --skip-innodb-checksums.
  --innodb_data_file_path=name
                      Path to individual files and their sizes.
  --innodb_data_home_dir=name
                      The common part for InnoDB table spaces.
  --innodb_doublewrite
                      Enable InnoDB doublewrite buffer (enabled by default).
                      Disable with --skip-innodb-doublewrite.
  --innodb_io_capacity[=#]
                      Number of IOPs the server can do. Tunes the background IO
                      rate
  --innodb_file_io_threads=#
                      Number of file I/O threads in InnoDB.
  --innodb_read_io_threads=#
                      Number of background read I/O threads in InnoDB.
  --innodb_write_io_threads=#
                      Number of background write I/O threads in InnoDB.
  --innodb_file_per_table
                      Stores each InnoDB table to an .ibd file in the database
                      dir.
  --innodb_flush_log_at_trx_commit[=#]
                      Set to 0 (write and flush once per second), 1 (write and
                      flush at each commit) or 2 (write at commit, flush once
                      per second).
  --innodb_flush_method=name
                      With which method to flush data.
  --innodb_force_recovery=#
                      Helps to save your data in case the disk image of the
                      database becomes corrupt.
  --innodb_lock_wait_timeout=#
                      Timeout in seconds an InnoDB transaction may wait for a
                      lock before being rolled back.
  --innodb_log_buffer_size=#
                      The size of the buffer which InnoDB uses to write log to
                      the log files on disk.
  --innodb_log_file_size=#
                      Size of each log file in a log group.
  --innodb_log_files_in_group=#
                      Number of log files in the log group. InnoDB writes to
                      the files in a circular fashion. Value 3 is recommended
                      here.
  --innodb_log_group_home_dir=name
                      Path to InnoDB log files.
  --innodb_max_dirty_pages_pct=#
                      Percentage of dirty pages allowed in bufferpool.
  --innodb_open_files=#
                      How many files at the maximum InnoDB keeps open at the
                      same time.
  --innodb_page_size=#
                      The universal page size of the database.
  --innodb_log_block_size=#
                      The log block size of the transaction log file. Changing
                      for created log file is not supported. Use on your own
                      risk!
  --innodb_fast_checksum
                      Change the algorithm of checksum for the whole of
                      datapage to 4-bytes word based.
  --innodb_extra_undoslots
                      Enable to use about 4000 undo slots instead of default
                      1024. Not recommended to use, Because it is not change
                      back to disable, once it is used.
  --innodb_doublewrite_file=name
                      Path to special datafile for doublewrite buffer. (default
                      is : not used)
  --innodb_buffer_pool_filename=name
                      Filename to/from which to dump/load the InnoDB buffer
                      pool
  --debug-sync=name   Debug sync point. This is only used by the xtrabackup
                      test suite
  --compact           Create a compact backup by skipping secondary index
                      pages.
  --rebuild_indexes   Rebuild secondary indexes in InnoDB tables after applying
                      the log. Only has effect with --prepare.
  --rebuild_threads=# Use this number of threads to rebuild indexes in a
                      compact backup. Only has effect with --prepare and
                      --rebuild-indexes.
  --incremental-force-scan
                      Perform a full-scan incremental backup even in the
                      presence of changed page bitmap data
  --defaults_group=name
                      defaults group in config file (default "mysqld").

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- -----------------------------
version                           FALSE
target-dir                        /var/lib/mysql/xtrabackup_backupfiles/
backup                            FALSE
stats                             FALSE
prepare                           FALSE
export                            FALSE
apply-log-only                    FALSE
print-param                       FALSE
use-memory                        104857600
suspend-at-start                  FALSE
suspend-at-end                    FALSE
throttle                          0
log-copy-interval                 1000
extra-lsndir                      (No default value)
incremental-lsn                   (No default value)
incremental-basedir               (No default value)
incremental-dir                   (No default value)
tables                            (No default value)
tables_file                       (No default value)
create-ib-logfile                 FALSE
datadir                           /var/lib/mysql
tmpdir                            /tmp
parallel                          1
stream                            (No default value)
compress                          (No default value)
compress-threads                  1
compress-chunk-size               65536
encrypt                           NONE
encrypt-key                       (No default value)
encrypt-key-file                  (No default value)
encrypt-threads                   1
encrypt-chunk-size                65536
innodb                            (No default value)
innodb_adaptive_hash_index        TRUE
innodb_additional_mem_pool_size   1048576
innodb_autoextend_increment       8
innodb_buffer_pool_size           268435456
innodb_checksums                  TRUE
innodb_data_file_path             (No default value)
innodb_data_home_dir              (No default value)
innodb_doublewrite                TRUE
innodb_io_capacity                400
innodb_file_io_threads            4
innodb_read_io_threads            4
innodb_write_io_threads           4
innodb_file_per_table             TRUE
innodb_flush_log_at_trx_commit    0
innodb_flush_method               O_DIRECT
innodb_force_recovery             0
innodb_lock_wait_timeout          50
innodb_log_buffer_size            8388608
innodb_log_file_size              5242880
innodb_log_files_in_group         2
innodb_log_group_home_dir         (No default value)
innodb_max_dirty_pages_pct        90
innodb_open_files                 400
innodb_page_size                  16384
innodb_log_block_size             512
innodb_fast_checksum              FALSE
innodb_extra_undoslots            FALSE
innodb_doublewrite_file           (No default value)
innodb_buffer_pool_filename       (No default value)
debug-sync                        (No default value)
compact                           FALSE
rebuild_indexes                   FALSE
rebuild_threads                   1
incremental-force-scan            FALSE
defaults_group                    mysqld