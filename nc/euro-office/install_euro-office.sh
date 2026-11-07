#!/bin/bash
set -e

# Zentrale Konfiguration laden
source /docker/nc/config.env

echo "Installiere Euro-Office Nextcloud-App ..."

# App installieren
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ app:install eurooffice

echo "Konfiguriere Euro-Office ..."

# Öffentliche Document-Server-Adresse
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set eurooffice DocumentServerUrl --value="https://${OFFICE_DOMAIN}/"

# Interne Adresse: Nextcloud -> Euro-Office
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set eurooffice DocumentServerInternalUrl --value="https://${OFFICE_DOMAIN}/"
    
# Interne Adresse: Euro-Office -> Nextcloud
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set eurooffice StorageUrl --value="https://${NC_DOMAIN}/"

# Gemeinsamer JWT-Schlüssel
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set \
    eurooffice jwt_secret \
    --value="${EUROOFFICE_JWT_SECRET}"

# Zertifikatsprüfung, für interne Verwendung "true", für externe Verwendung "false"
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set eurooffice verify_peer_off --value="true"

echo "Euro-Office wurde erfolgreich installiert und konfiguriert."

exit 0
