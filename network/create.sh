#!/bin/bash

docker network create \
-d bridge \
--subnet=172.30.0.0/16 \
--gateway=172.30.0.1 \
--ipv6 \
--subnet=fd00:172:30::/64 \
--gateway=fd00:172:30::1 \
--opt com.docker.network.bridge.name=br_nextcloud \
nextcloud


exit
