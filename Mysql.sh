#! /bin/shell
# 快速安装MySQL
# CentOS7 中已成功验证
# 使用yum+rpm方式安装

# 配置阿里云yum镜像源
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all
yum makecache

# 下载mysql rpm
wget https://repo.mysql.com//mysql80-community-release-el7-3.noarch.rpm

# 安装rpm
rpm -Uvh mysql80-community-release-el7-3.noarch.rpm

# yum 安装mysql服务
yum install -y mysql-community-server

# 启动mysql服务
systemctl start mysqld.service

# 查看mysql服务状态
systemctl status mysqld.service

# 查看安装的mysql密码
grep 'temporary password' /var/log/mysqld.log

TEMP_PWD=$(grep 'temporary password' /var/log/mysqld.log)
PWD=${TEMP_PWD##* }
echo "${PWD}"

# 使用新密码登陆
#exit
# mysql -uroot -pSpus666!

# 导入spring-boot-plus数据库脚本
# use mysql;
# source /root/mysql_spring_boot_plus.sql;
