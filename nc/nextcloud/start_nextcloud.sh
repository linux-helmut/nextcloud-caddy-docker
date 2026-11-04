#!/bin/bash
set -e

docker compose --env-file /docker/nc/config.env up -d nc_cloud

exit 0