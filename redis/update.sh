#!/bin/bash

docker compose pull nc_redis
docker compose up -d nc_redis

exit
