#!/bin/bash
set -e

# Zentrale Konfiguration laden
source /docker/nc/config.env

# Docker Image erstellen
docker build --pull \
    --build-arg INSTALL_NODE26="${INSTALL_NODE26}" \
    -t "${NC_IMAGE_NAME}:${NC_IMAGE_VERSION}" .

exit 0
