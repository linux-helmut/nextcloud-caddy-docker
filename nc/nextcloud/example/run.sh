#!/bin/bash

### Start-Script innerhalb vom Container um Programme zu starten !!!


set -e

NOTIFY_PUSH="/var/www/nextcloud/apps/notify_push/bin/x86_64/notify_push"

if [ -x "$NOTIFY_PUSH" ] && [ -f /var/www/nextcloud/config/config.php ]; then
    echo "Starte notify_push ..."
    "$NOTIFY_PUSH" /var/www/nextcloud/config/config.php &
else
    echo "notify_push nicht vorhanden"
fi

exec php-fpm8.5 -F

