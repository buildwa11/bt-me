#!/bin/bash
mysql_root_pwd=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
mysql_cnf_path=$1
export mysql_passwd=$mysql_root_pwd
echo "------------------------------Stoping mysql-----------------------------------------"
/etc/init.d/mysql stop
sed -i '/\[mysqld\]/askip-grant-tables' $mysql_cnf_path
/etc/init.d/mysql start
echo "-------------------------------Changing pasword--------------------------------------"
printf "mysql password is %s" "$mysql_root_pwd" > /root/mysqlpassword
mysql -uroot mysql << EOF
use mysql;
update user set password = Password('$mysql_passwd') where User = 'root';
commit;
flush privileges;
EOF

if [ $? -eq 0 ]; then
echo "------------Password reset succesfully. Now restarting mysqld softly-------------------"
sed -i '/skip-grant-tables/d' /etc/my.cnf
/etc/init.d/mysql restart
echo "--------------------------Password set success----------------------------------------"
else
mysql -uroot mysql << EOF
use mysql;
update user set authentication_string = Password('$mysql_passwd') where User = 'root';
commit;
flush privileges;
EOF
if [ $? -eq 0 ]; then
echo "------------Password reset succesfully. Now restarting mysqld softly-------------------"
sed -i '/skip-grant-tables/d' $mysql_cnf_path
/etc/init.d/mysql restart
echo "--------------------------Password set success----------------------------------------"
else
echo "--------------------------Password set failed----------------------------------------"
fi
fi