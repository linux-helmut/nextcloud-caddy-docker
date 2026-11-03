#!/bin/bash


cd /docker/network
docker network create \
-d bridge \
--subnet=172.30.0.0/16 \
--gateway=172.30.0.1 \
--ipv6 \
--subnet=fd00:172:30::/64 \
--gateway=fd00:172:30::1 \
--opt com.docker.network.bridge.name=br_nextcloud \
nextcloud


cd /docker/portainer
docker run -d \
--name portainer \
--restart always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /docker/portainer/data:/data \
-p 9000:9000 \
portainer/portainer-ce:latest


cd /docker/redis
docker compose up -d redis


cd /docker/mariadb
docker compose up -d mariadb
docker exec -it mariadb mariadb -u root -p -e "
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'nextcloud';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
FLUSH PRIVILEGES;
"
docker exec -it mariadb mariadb-secure-installation


cd /docker/nextcloud
docker build --pull -t nextcloud:v1.0.0 .
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip -d /docker/nextcloud
mv nextcloud html
chown www-data:www-data /docker/nextcloud/html -R
rm latest.zip
mv /docker/nextcloud/example/vorgaben.config.php /docker/nextcloud/html/config/vorgaben.config.php
mv /docker/nextcloud/example/autoconfig.php /docker/nextcloud/html/config/autoconfig.php
mkdir data
chown www-data:www-data data
chmod 0770 data
docker compose up -d nextcloud


cd /docker/caddy
docker compose up -d caddy

docker logs portainer | grep "secret"

exit
