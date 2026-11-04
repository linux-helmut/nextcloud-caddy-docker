#!/bin/bash


docker exec -it nc_mariadb mariadb -u root -p -e "
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'nextcloud';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
FLUSH PRIVILEGES;
"

clear
echo "MariaDB absichern/abhärten!  (mariadb-secure-installation)"
echo ""
docker exec -it nc_mariadb mariadb-secure-installation

exit
