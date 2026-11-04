#!/bin/bash
set -e

# Zentrale Konfiguration laden
source /docker/nc/config.env

# Prüfen, ob Netzwerk bereits existiert
if docker network inspect "$DOCKER_NETWORK" >/dev/null 2>&1; then
    echo "Docker Netzwerk '$DOCKER_NETWORK' existiert bereits."
    exit 0
fi

# Docker Netzwerk erstellen
docker network create \
    --driver bridge \
    --subnet "$DOCKER_IPV4_SUBNET" \
    --gateway "$DOCKER_IPV4_GATEWAY" \
    --ipv6 \
    --subnet "$DOCKER_IPV6_SUBNET" \
    --gateway "$DOCKER_IPV6_GATEWAY" \
    --opt "com.docker.network.bridge.name=br_${DOCKER_NETWORK}" \
    "$DOCKER_NETWORK"

echo "Docker Netzwerk '$DOCKER_NETWORK' wurde erstellt."

exit 0
