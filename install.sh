docker stop `docker ps --no-trunc -aq`
docker rm `docker ps --no-trunc -aq`

docker build -t tutum/lamp .

docker run -d -p 80:80 -p 3306:3306 tutum/lamp

sleep 20

SQLPASSWORD=`docker logs \`docker ps --no-trunc -aq\`|grep "mysql -uadmin"|cut -f 3 -d\-|cut -b 2-`

echo create database ach | mysql -uadmin -p$SQLPASSWORD -h 127.0.0.1

mysql ach -uadmin -p$SQLPASSWORD -h 127.0.0.1< db.sql
