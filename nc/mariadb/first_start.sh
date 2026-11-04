#!/bin/bash
set -e

# Zentrale Konfiguration laden
source /docker/nc/config.env

# Datenbank und Benutzer anlegen
docker exec nc_mariadb mariadb \
    -u root -p"${DB_ROOT_PASSWORD}" -e "
CREATE DATABASE IF NOT EXISTS ${DB_NAME}
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_USER}'@'%'
    IDENTIFIED BY '${DB_PASSWORD}';

ALTER USER '${DB_USER}'@'%'
    IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
"

# MariaDB absichern
clear
echo "MariaDB absichern/abhärten! (mariadb-secure-installation)"
echo ""

docker exec -it nc_mariadb mariadb-secure-installation

exit 0
