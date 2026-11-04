#!/bin/bash

docker compose pull nc_mariadb
docker compose up -d nc_mariadb

exit
