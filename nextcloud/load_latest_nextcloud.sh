#!/bin/bash

wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip -d /docker/nextcloud
mv /docker/nextcloud/nextcloud /docker/nextcloud/html
chown www-data:www-data /docker/nextcloud/html -R
rm latest.zip

exit
