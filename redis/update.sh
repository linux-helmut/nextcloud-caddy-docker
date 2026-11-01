#!/bin/bash

docker compose pull redis
docker compose up -d redis

exit
