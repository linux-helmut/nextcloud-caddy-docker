#!/bin/bash
set -e

docker compose --env-file /docker/nc/config.env up -d --force-recreate nc_redis

exit 0