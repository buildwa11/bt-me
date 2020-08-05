FROM centos:7
MAINTAINER xinb

#设置entrypoint映射到www文件夹下持久化
COPY entrypoint.sh /entrypoint.sh
COPY Mysql.sh /Mysql.sh

RUN mkdir -p /www/letsencrypt \
    && ln -s /www/letsencrypt /etc/letsencrypt \
    && rm -f /etc/init.d \
    && mkdir /www/init.d \
    && ln -s /www/init.d /etc/init.d \
    && chmod +x /entrypoint.sh \
    && chmod +x /Mysql.sh \
    && mkdir /www/wwwroot
    
    
#更新系统 安装依赖
RUN cd /home \
    && yum -y update \
    && yum -y install wget httpd unzip 
RUN yum install php-mysql \
    && yum clean all \
    && yum makecache
#配置数据库
RUN echo y | bash /Mysql.sh
#配置Wordpress
RUN wget https://cn.wordpress.org/latest-zh_CN.zip \
    && unzip latest-zh_CN.zip \
    &&cp -r wordpress/* /var/www/html/ \
    
    


WORKDIR /www/wwwroot
CMD /entrypoint.sh
EXPOSE 80 443 3306 888

HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost:80/ && curl -fs http://localhost/ || exit 1 
