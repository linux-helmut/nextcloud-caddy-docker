#!/bin/bash
set -Eeuo pipefail

CONTAINER="nc_cloud"
OCC="/var/www/nextcloud/occ"

# Talk-Konfiguration
TALK_URL="https://talk.lokal.de"
TALK_DOMAIN="talk.lokal.de"
TALK_PORT="3478"

SIGNALING_SECRET="1234567890123456789012345678901234567890"
TURN_SECRET="1234567890123456789012345678901234567890"

echo "======================================"
echo "Nextcloud Talk installieren"
echo "======================================"

OCC_CMD=(docker exec -u www-data "$CONTAINER" php "$OCC")

# --------------------------------------------------
# Talk installieren
# --------------------------------------------------

    echo "Installiere Talk ..."
    "${OCC_CMD[@]}" app:install spreed

# --------------------------------------------------
# High Performance Backend
# --------------------------------------------------

    echo "Registriere High Performance Backend ..."
    "${OCC_CMD[@]}" talk:signaling:add \
        --verify "$TALK_URL" "$SIGNALING_SECRET"

# --------------------------------------------------
# STUN
# --------------------------------------------------

    echo "Registriere STUN ..."

    "${OCC_CMD[@]}" talk:stun:add \
        "$TALK_DOMAIN:$TALK_PORT"

# --------------------------------------------------
# TURN
# --------------------------------------------------

    echo "Registriere TURN ..."

    "${OCC_CMD[@]}" talk:turn:add \
        --secret="$TURN_SECRET" \
        turn "$TALK_DOMAIN:$TALK_PORT" udp,tcp

# --------------------------------------------------
# Kontrolle
# --------------------------------------------------

echo
echo "======================================"
echo "Talk-Konfiguration"
echo "======================================"

"${OCC_CMD[@]}" talk:signaling:list
"${OCC_CMD[@]}" talk:stun:list
"${OCC_CMD[@]}" talk:turn:list

echo
echo "Nextcloud Talk wurde konfiguriert."
