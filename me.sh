#!/bin/sh
mysql_install_dir=/usr/local/mysql
mysql_data_dir=/usr/local/mysql/data
mysql_6_version=5.6.17
MYSQL_VERSION=5.6.17
CMAKE_VERSION=2.8.12.2
dbrootpwd=root

[ -f /etc/init.d/functions ] && . /etc/init.d/functions
echo
echo "-----------step 1:add mysql user----"
useradd -s /sbin/nologin -M mysql
sleep 1

MYSQL(){
rpm -Uvh http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install make gcc gcc-c++  ncurses-devel gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel  ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap lsof

[ ! -f cmake-${CMAKE_VERSION}.tar.gz  ] && \
wget http://www.o2oxy.cn/wp-content/uploads/2017/05/cmake-2.8.12.2.tar.gz
echo "-------- stop 2: download mysql "
[ ! -f mysql-${MYSQL_VERSION}.tar.gz ] && \
http://www.o2oxy.cn/wp-content/uploads/2017/05/mysql-5.6.17.tar.gz
tar zxvf cmake-2.8.12.2.tar.gz && cd cmake-2.8.12.2 && ./configure && make && make install && cd ..
mkdir -p $mysql_data_dir 
chown -R mysql:mysql $mysql_install_dir
tar zxf mysql-${MYSQL_VERSION}.tar.gz
cd mysql-${MYSQL_VERSION} && /usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_USER=mysql -DWITH_DEBUG=0 -DWITH_SSL=system && make && make install

if [ -d support-files/ ];then
   action "YES" /bin/true
   cd support-files/
   if [ -f /etc/my.cnf ];then
   mv /etc/my.cnf /etc/my.cnf.bak
   cat >>/etc/my.cnf<<EOF
[client]
port = 3306
socket =$mysql_install_dir/mysql.sock
[mysqld]
datadir=$mysql_data_dir
skip-name-resolve
log-error=$mysql_install_dir/3306erroe.log
pid-file=$mysql_install_dir/3306mysql.pid
lower_case_table_names=1
innodb_file_per_table=1
port = 3306
socket =$mysql_install_dir/mysql.sock
back_log = 50
max_connections = 300
max_connect_errors = 1000
table_open_cache = 2048
max_allowed_packet = 16M
binlog_cache_size = 2M
max_heap_table_size = 64M
sort_buffer_size = 2M
join_buffer_size = 2M
thread_cache_size = 64
thread_concurrency = 8
query_cache_size = 64M
query_cache_limit = 2M
ft_min_word_len = 4
default-storage-engine = innodb
thread_stack = 192K
transaction_isolation = REPEATABLE-READ
tmp_table_size = 64M
log-bin=mysql-bin     
binlog_format=mixed
slow_query_log
long_query_time = 1
server-id = 1        
key_buffer_size = 8M
read_buffer_size = 2M
read_rnd_buffer_size = 2M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
myisam_recover
innodb_additional_mem_pool_size = 16M
innodb_buffer_pool_size = 200M
innodb_data_file_path = ibdata1:10M:autoextend
innodb_file_io_threads = 8
innodb_thread_concurrency = 16
innodb_flush_log_at_trx_commit = 1
innodb_log_buffer_size = 16M
innodb_log_file_size = 512M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 60
innodb_lock_wait_timeout = 120
[mysqldump]
quick
max_allowed_packet = 256M
[mysql]
no-auto-rehash
prompt=\\u@\\d \\R:\\m>
[myisamchk]
key_buffer_size = 512M
sort_buffer_size = 512M
read_buffer = 8M
write_buffer = 8M
[mysqlhotcopy]
interactive-timeout
[mysqld_safe]
open-files-limit = 8192
EOF
   else
   \cp -p my-default.cnf /etc/my.cnf
   fi
else 
   action "NO" /bin/false
   exit 1
fi
[ -f /usr/local/mysql/scripts/mysql_install_db ] &&\
/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=$mysql_install_dir --datadir=$mysql_data_dir --user=mysql
##cp mysqld data
\cp mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig mysqld on
echo "export PATH=$mysql_install_dir/bin:\$PATH" >> /etc/profile && echo "export PATH" >> /etc/profile
.  /etc/profile
service mysqld start
source /etc/profile
}
MYSQL