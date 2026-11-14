
#!/bin/bash
set -Eeuo pipefail

# --------------------------------------------------
# Zentrale Konfiguration laden
# --------------------------------------------------

source /docker/nc/config.env

# --------------------------------------------------
# Einstellungen
# --------------------------------------------------

CONTAINER="nc_cloud"
OCC="/var/www/nextcloud/occ"

TALK_URL="https://${TALK_DOMAIN}"
TALK_PORT="3478"

OCC_CMD=(docker exec -u www-data "$CONTAINER" php "$OCC")

# --------------------------------------------------
# Talk installieren
# --------------------------------------------------

echo "======================================"
echo "Nextcloud Talk installieren"
echo "======================================"

echo
echo "Installiere Talk ..."

"${OCC_CMD[@]}" app:install spreed

# --------------------------------------------------
# High Performance Backend
# --------------------------------------------------

echo
echo "Registriere High Performance Backend ..."

"${OCC_CMD[@]}" talk:signaling:add \
    --verify "$TALK_URL" "$SIGNALING_SECRET"

# --------------------------------------------------
# STUN
# --------------------------------------------------

echo
echo "Registriere STUN ..."

"${OCC_CMD[@]}" talk:stun:add \
    "$TALK_DOMAIN:$TALK_PORT"

# --------------------------------------------------
# TURN
# --------------------------------------------------

echo
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
echo "======================================"
echo "Nextcloud Talk erfolgreich installiert"
echo "======================================"
