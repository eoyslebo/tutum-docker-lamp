FROM ubuntu:trusty
MAINTAINER Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install packages
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libapache2-mod-php5
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-mysql 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pwgen 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-apc

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN git clone https://github.com/Burton/Analysis-of-Competing-Hypotheses /app

RUN sed -i "40s/.*/\$dbhost = \'localhost\';/" /app/code/common_db.php
RUN sed -i "41s/.*/\$dbusername = \'root\';/" /app/code/common_db.php
RUN sed -i "42s/.*/\$dbuserpassword = \'\';/" /app/code/common_db.php
RUN sed -i "43s/.*/\$default_dbname = \'ach\';/" /app/code/common_db.php

RUN sed -i "25s/.*/<base href=\'http:\/\/192.168.200.107\/\'>/" /app/parts/includes.php
RUN sed -i "26s/.*/<?php \$base_URL=\'http:\/\/192.168.200.107\/\';/" /app/parts/includes.php



RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#RUN service mysql start
#RUN echo create database ach | mysql
#RUN mysql ach -uadmin < /app/db.sql


#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
