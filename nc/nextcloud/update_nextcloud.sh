#!/bin/bash
set -e

docker compose --env-file /docker/nc/config.env up -d --no-deps --force-recreate nextcloud

exit 0