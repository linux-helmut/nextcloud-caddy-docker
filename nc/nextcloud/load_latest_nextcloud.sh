#!/bin/bash

wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip -d /docker/nc/temp
mv /docker/nc/temp/nextcloud /docker/nc/nextcloud/html
rmdir /docker/nc/temp
#rm latest.zip

cp /docker/nc/nextcloud/example/vorgaben.config.php /docker/nc/nextcloud/html/config/vorgaben.config.php
cp /docker/nc/nextcloud/example/autoconfig.php /docker/nc/nextcloud/html/config/autoconfig.php

chown www-data:www-data /docker/nc/nextcloud/html -R

mkdir /docker/nc/nextcloud/data
chown www-data:www-data /docker/nc/nextcloud/data
chmod 0770 /docker/nc/nextcloud/data


exit
