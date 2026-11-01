#!/bin/bash


docker exec -it mariadb mariadb -u root -p -e "
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'nextcloud';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
FLUSH PRIVILEGES;
"

docker exec -it mariadb mariadb-secure-installation
docker exec -i mariadb mariadb-secure-installation <<'EOF'
n
n
y
y
y
y
EOF


exit
