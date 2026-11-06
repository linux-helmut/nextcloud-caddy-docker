#!/bin/bash
set -e

cd "$(dirname "$0")"

docker compose --env-file /docker/nc/config.env up -d nc_redis

exit 0
