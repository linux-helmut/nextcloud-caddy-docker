#!/bin/bash

docker compose --env-file /docker/nc/config.env pull nc_euro-office
docker compose --env-file /docker/nc/config.env up -d nc_euro-office

exit
