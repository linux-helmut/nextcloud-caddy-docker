# Installation nextcloud-caddy-docker

1. Verzeichnis `/docker` erstellen.
2. GitHub-Repository herunterladen und entpacken.
3. Den Ordner `nc` nach `/docker/nc` kopieren.
4. Die zentrale Konfiguration `/docker/nc/config.env` anpassen.

   WICHTIG:
   - Alle Beispielpasswörter und JWT-Schlüssel ersetzen.
   - Eigene Domains für Nextcloud und optional Euro-Office eintragen.
   - Docker-Netzwerk und IP-Bereiche prüfen.
   - Für internen Betrieb: CADDY_TLS="tls internal"
   - Für öffentlichen Betrieb: CADDY_TLS=""
   - Bei öffentlichem Betrieb DNS-Einträge und Firewall konfigurieren.

## Docker-Netzwerk

Netzwerk erstellen:

    /docker/nc/create_network.sh

## Redis

Container erstellen und starten:

    /docker/nc/redis/start_redis.sh

## MariaDB

Container erstellen und starten:

    /docker/nc/mariadb/start_mariadb.sh

Datenbank und Benutzer für Nextcloud erstellen sowie MariaDB absichern:

    /docker/nc/mariadb/first_start.sh

Bei der Datenbankabsicherung die angezeigten Fragen beachten.

## Nextcloud

Eigenes PHP-FPM-Image erstellen:

    /docker/nc/nextcloud/build_nextcloud_image.sh

Aktuelle Nextcloud-Version herunterladen und vorbereiten:

    /docker/nc/nextcloud/load_latest_nextcloud.sh

Nextcloud-Container erstellen und starten:

    /docker/nc/nextcloud/start_nextcloud.sh

## Caddy

Container erstellen und starten:

    /docker/nc/caddy/start_caddy.sh

Die Ports 80/TCP, 443/TCP und gegebenenfalls 443/UDP müssen verfügbar sein.

Bei öffentlichem Betrieb müssen die Domains auf den Server zeigen und Caddy die Zertifikate beziehen können.

## Nextcloud-Erstinstallation

Im Browser öffnen:

    https://cloud.lokal.de   (oder die in config.env eingetragene URL)

Nextcloud-Installation abschließen.

## Optionale Komponenten

### Nextcloud-Apps

Vorgesehene Apps installieren und konfigurieren:

    /docker/nc/nextcloud/first_app_config.sh

### Portainer

Portainer installieren und starten:

    /docker/portainer/start_portainer.sh

Anschließend die Container-Logs prüfen. Hier steht der Schlüssel für die erstmalige Anmeldung im Browser:

    docker logs portainer

### Euro-Office

Document Server erstellen und starten:

    /docker/nc/euro-office/start_euro-office.sh

Euro-Office-App in Nextcloud installieren und konfigurieren:

    /docker/nc/euro-office/install_euro-office.sh

Die Konfiguration verwendet OFFICE_DOMAIN, NC_DOMAIN und EUROOFFICE_JWT_SECRET aus der zentralen config.env.

WICHTIG:
Bei interner TLS-Konfiguration (tls internal) muss der Administrator sicherstellen, dass der Euro-Office-Document-Server der Caddy-Zertifizierungsstelle vertraut.

Die TLS-Zertifikatsprüfung sollte nicht pauschal deaktiviert werden.
