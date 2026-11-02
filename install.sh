#!/bin/bash
set -e

clear


echo Create Docker Network for Cloud only
read

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






echo #######################################################################################
echo
echo Install and start Portainer
read

cd /docker/portainer
docker run -d --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer/data:/data -p 9000:9000 portainer/portainer-ce:latest


echo #######################################################################################
echo
echo Login into Portainer WebUI
echo
echo Here comes the LOG. Copy the Secret-Token!
read

docker logs portainer





echo #######################################################################################
echo
echo Install and start Redis
read

cd /docker/redis
docker compose up -d redis






echo #######################################################################################
echo
echo Install and start MariaDB
read

cd /docker/mariadb
docker compose up -d mariadb




echo #######################################################################################
echo
echo MariaDB: Create Database and User
read

docker exec -it mariadb mariadb -u root -p -e "
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'nextcloud';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
FLUSH PRIVILEGES;
"





echo #######################################################################################
echo
echo MariaDB: MariaDB-Secure-Installation
read

docker exec -it mariadb mariadb-secure-installation







echo #######################################################################################
echo
echo Build PHP-FPM Image for Nextcloud
read

cd /docker/nextcloud
docker build --pull -t nextcloud:v1.0.0 .






echo #######################################################################################
echo
echo Load latest Nextcloud Version and install
read

cd /docker/nextcloud

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



echo #######################################################################################
echo
echo Create and start PHP-FPM for Nextcloud
read

cd /docker/nextcloud
docker compose up -d nextcloud





echo #######################################################################################
echo
echo Create and start Caddy Proxy Server
read

cd /docker/caddy
docker compose up -d caddy




echo #######################################################################################
echo
echo You must ending the Nextcloud Setup over WebUI.
echo Login into Nextcloud Domain.
echo Do not close this terminal....
read
read


echo #######################################################################################
echo
echo Now some APPs where disable, install an config...
read

cd /docker

docker exec -it nextcloud php /var/www/nextcloud/occ app:install previewgenerator
docker exec -it nextcloud php /var/www/nextcloud/occ app:install recognize
docker exec -it nextcloud php /var/www/nextcloud/occ app:install memories
docker exec -it nextcloud php /var/www/nextcloud/occ recognize:download-models
docker exec -it nextcloud php /var/www/nextcloud/occ memories:places-setup

docker exec -it nextcloud php /var/www/nextcloud/occ maintenance:repair --include-expensive
docker exec -it nextcloud php /var/www/nextcloud/occ db:add-missing-indices

docker exec -it nextcloud php /var/www/nextcloud/occ app:install files_3dmodelviewer
docker exec -it nextcloud php /var/www/nextcloud/occ app:install calendar
docker exec -it nextcloud php /var/www/nextcloud/occ app:install contacts
docker exec -it nextcloud php /var/www/nextcloud/occ app:install camerarawpreviews
docker exec -it nextcloud php /var/www/nextcloud/occ app:install theming_customcss
docker exec -it nextcloud php /var/www/nextcloud/occ app:install files_external
docker exec -it nextcloud php /var/www/nextcloud/occ app:install files_linkeditor
#docker exec -it nextcloud php /var/www/nextcloud/occ app:install maps
#docker exec -it nextcloud php /var/www/nextcloud/occ app:install metadata
#docker exec -it nextcloud php /var/www/nextcloud/occ app:install music
#docker exec -it nextcloud php /var/www/nextcloud/occ app:install files_photospheres
docker exec -it nextcloud php /var/www/nextcloud/occ app:install notify_push

docker exec -it nextcloud php /var/www/nextcloud/occ app:disable comments
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable dashboard
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable app_api
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable contactsinteraction
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable federation
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable files_reminders
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable files_downloadlimit
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable firstrunwizard
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable nextcloud_announcements
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable webhook_listeners
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable privacy
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable recommendations
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable support

docker exec -it nextcloud php /var/www/nextcloud/occ app:disable weather_status
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable files_versions
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable user_status
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable survey_client
docker exec -it nextcloud php /var/www/nextcloud/occ app:disable circles



echo #######################################################################################
echo
echo We are Ready !!!
echo
echo #######################################################################################


exit


