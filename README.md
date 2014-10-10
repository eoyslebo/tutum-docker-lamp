tutum-docker-lamp forked to run https://github.com/Burton/Analysis-of-Competing-Hypotheses
=================

#stop and remove all docker containers
docker stop `docker ps --no-trunc -aq`
docker rm `docker ps --no-trunc -aq`

#build this container
docker build -t tutum/lamp .

#run this container
docker run -d -p 80:80 -p 3306:3306 tutum/lamp

#initialize database
sleep 20

SQLPASSWORD=`docker logs \`docker ps --no-trunc -aq\`|grep "mysql -uadmin"|cut -f 3 -d\-|cut -b 2-`

echo create database ach | mysql -uadmin -p$SQLPASSWORD -h 127.0.0.1

mysql ach -uadmin -p$SQLPASSWORD -h 127.0.0.1< db.sql

todo
=================

Hostname is hardcoded as 192.168.200.107
remove db.sql
