#!/bin/bash
set -e

# Verzeichnisse
BASE_DIR="/docker/nc/nextcloud"
TEMP_DIR="/docker/nc/temp"
HTML_DIR="$BASE_DIR/html"
DATA_DIR="$BASE_DIR/data"

cd "$BASE_DIR"

# Prüfen, ob bereits eine Installation existiert
if [ -e "$HTML_DIR" ]; then
    echo "Nextcloud-Verzeichnis existiert bereits: $HTML_DIR"
    echo "Installation wird abgebrochen."
    exit 1
fi

# Aktuelle Nextcloud-Version herunterladen
wget -O latest.zip https://download.nextcloud.com/server/releases/latest.zip

# Archiv entpacken
mkdir -p "$TEMP_DIR"
unzip -q latest.zip -d "$TEMP_DIR"

# Nextcloud installieren
mv "$TEMP_DIR/nextcloud" "$HTML_DIR"
rmdir "$TEMP_DIR"

# Konfigurationsvorlagen kopieren
cp "$BASE_DIR/example/vorgaben.config.php" \
   "$HTML_DIR/config/vorgaben.config.php"

cp "$BASE_DIR/example/autoconfig.php" \
   "$HTML_DIR/config/autoconfig.php"

# Berechtigungen setzen
chown -R www-data:www-data "$HTML_DIR"

# Datenverzeichnis erstellen
mkdir -p "$DATA_DIR"
chown www-data:www-data "$DATA_DIR"
chmod 0770 "$DATA_DIR"

echo "Nextcloud wurde erfolgreich bereitgestellt."

exit 0
