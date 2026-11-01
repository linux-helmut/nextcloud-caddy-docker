#!/bin/bash

wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip -d /docker/nextcloud
mv /docker/nextcloud/nextcloud /docker/nextcloud/html
chown www-data:www-data /docker/nextcloud/html -R
rm latest.zip

mv /docker/nextcloud/example/vorgaben.config.php /docker/nextcloud/html/config
mv /docker/nextcloud/example/autoconfig.php /docker/nextcloud/html/config

mkdir data
chown www-data:www-data data
chmod 0770 data


exit
