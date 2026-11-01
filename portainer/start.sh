#!/bin/bash

docker run -d --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer/data:/data -p 9000:9000 portainer/portainer-ce:latest

docker logs portainer


exit
