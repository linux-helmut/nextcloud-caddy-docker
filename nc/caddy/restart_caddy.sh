#!/bin/bash
set -e

docker compose --env-file /docker/nc/config.env up -d --force-recreate nc_caddy

exit 0
