#!/bin/bash
set -e

docker compose --env-file /docker/nc/config.env up -d nextcloud

exit 0