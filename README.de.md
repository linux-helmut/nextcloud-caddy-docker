# Nextcloud Caddy Docker

Eine modulare, selbst betriebene Nextcloud-Umgebung auf Basis von Docker, PHP-FPM, MariaDB, Redis und Caddy.

Das Projekt ist so aufgebaut, dass die einzelnen Dienste unabhängig voneinander betrieben und gewartet werden können. Jeder Dienst besitzt eine eigene Docker-Compose-Konfiguration sowie eigene Skripte zum Starten, Neustarten und Aktualisieren. Die erstmalige Einrichtung ist separat in [`install.txt`](install.txt) beschrieben.

**Die mitgelieferte Beispielkonfiguration ist auf lokale Nutzung ausgelegt.** Über die zentrale Datei `nc/config.env` lässt sich Caddy mit `CADDY_TLS` wahlweise für interne oder öffentliche TLS-Zertifikate konfigurieren. Das Projekt kann mit passenden Domains und DNS-Einträgen auch öffentlich betrieben werden.

## Funktionen

- Modularer Aufbau mit Docker Compose
- Eigenes Docker-Bridge-Netzwerk mit IPv4 und IPv6
- Caddy als Reverse Proxy mit HTTPS und HTTP/3
- Eigenes PHP-FPM-Image auf Basis von Debian 13
- PHP 8.4 mit den für Nextcloud benötigten Erweiterungen
- Node.js 26, ImageMagick und FFmpeg im PHP-FPM-Image
- MariaDB 11.8 als Datenbank
- Redis für Caching und transaktionales File Locking
- Optionale Integration des Euro-Office Document Servers
- Optionales Verwaltungsinterface mit Portainer
- Persistente Anwendungs-, Datenbank- und Dienstdaten außerhalb der Container
- Separate Skripte zur Verwaltung der einzelnen Dienste

## Architektur

Die Umgebung besteht aus unabhängig verwalteten Komponenten:

| Komponente | Aufgabe |
|---|---|
| Caddy | HTTPS-Terminierung und Reverse Proxy |
| Nextcloud PHP-FPM | PHP-Laufzeitumgebung für Nextcloud |
| Nextcloud-Anwendung | Anwendungscode, Konfiguration und Benutzerdaten |
| MariaDB | Datenbank |
| Redis | Caching und transaktionales File Locking |
| Euro-Office | Optionale Online-Dokumentbearbeitung |
| Portainer | Optionale Docker-Verwaltungsoberfläche |

Caddy ist der zentrale Web-Einstiegspunkt. Er leitet Anfragen an den Nextcloud-PHP-FPM-Container und – sofern installiert – an den Euro-Office Document Server weiter.

Das Euro-Office-Image enthält einen eigenen internen Nginx. Dieser gehört zum Document Server und ist kein zusätzlicher öffentlich erreichbarer Reverse Proxy. Caddy leitet die Anfragen an diesen internen Dienst weiter.

Portainer wird separat installiert und ist nicht mit dem gemeinsamen Nextcloud-Docker-Netzwerk verbunden.

### Datenfluss

```text
Browser
   |
   | HTTPS
   v
 Caddy
   |
   +------> Nextcloud PHP-FPM
   |              |
   |              +------> MariaDB
   |              |
   |              +------> Redis
   |
   +------> Euro-Office (optional)
```

Datenbank, Redis, PHP-FPM und Euro-Office kommunizieren über das dedizierte Docker-Netzwerk. Die mitgelieferten Compose-Dateien veröffentlichen deren Dienstports nicht auf dem Host. Caddy veröffentlicht TCP-Port 80 und 443 sowie UDP-Port 443.

## Lokale und öffentliche Nutzung

Die Betriebsart wird über die zentrale Konfigurationsdatei `/docker/nc/config.env` festgelegt. Die mitgelieferten Werte sind Beispiele und müssen vor der Installation an die eigene Umgebung angepasst werden.

### Interner Betrieb

Für den internen Betrieb werden lokale DNS-Einträge benötigt. Die Beispiel-Hostnamen lauten:

| Dienst | Lokaler Hostname |
|---|---|
| Nextcloud | `cloud.lokal.de` |
| Euro-Office | `office.lokal.de` |

Für interne Zertifikate wird in `config.env` gesetzt:

```bash
CADDY_TLS="tls internal"
```

Caddy stellt dann eigene Zertifikate aus. Die Clients müssen der internen Caddy-Zertifizierungsstelle vertrauen. Das Root-Zertifikat kann aus dem persistenten Caddy-Datenverzeichnis exportiert und auf den jeweiligen Geräten als vertrauenswürdige Stammzertifizierungsstelle installiert werden.

### Öffentlicher Betrieb über das Internet

Für öffentlich erreichbare Domains wird `CADDY_TLS` in `config.env` leer gesetzt:

```bash
CADDY_TLS=""
```

Caddy verwendet dann seine automatische ACME-Zertifikatsverwaltung und versucht, öffentlich vertrauenswürdige Zertifikate zu beziehen. Dafür müssen folgende Voraussetzungen erfüllt sein:

1. `NC_DOMAIN` und gegebenenfalls `OFFICE_DOMAIN` in `config.env` auf die gewünschten öffentlichen Hostnamen setzen.
2. Öffentliche DNS-Einträge für diese Hostnamen anlegen. Sie müssen auf die öffentliche IP-Adresse des Docker-Hosts zeigen. Die DNS-Einträge werden nicht durch das Projekt erstellt.
3. TCP-Port 80 und TCP-Port 443 müssen aus dem Internet erreichbar sein. Für HTTP/3 wird zusätzlich UDP-Port 443 benötigt.
4. Domainreferenzen in den Nextcloud-Konfigurationsvorlagen prüfen und anpassen, insbesondere `overwritehost`, `overwrite.cli.url` und die URL für `notify_push` in `nc/nextcloud/example/vorgaben.config.php`.
5. Nach der Installation die Nextcloud-Einstellungen für vertrauenswürdige Domains, Proxy und URL-Überschreibung sowie gegebenenfalls die Euro-Office-URL prüfen.

Es reicht nicht aus, nur die DNS-Einträge zu ändern. Die Domains müssen in `config.env`, Caddy und den Nextcloud-Konfigurationen zusammenpassen.

## Voraussetzungen

- Debian Linux; vorgesehen ist Debian 13 (Trixie)
- Docker Engine
- Docker-Compose-Plugin
- Administrative Rechte auf dem Host
- Ausreichend Speicherplatz für Datenbank, Nextcloud-Dateien und Dienstdaten

Für die lokale Nutzung muss ein konfigurierbarer lokaler DNS-Server vorhanden sein. Für den externen Zugriff werden öffentliche DNS-Einträge und die Erreichbarkeit der erforderlichen Ports benötigt.

Die Installation von Debian und Docker selbst ist nicht Bestandteil dieses Projekts.

## Installation

Für die erstmalige Einrichtung bitte der Datei [`install.txt`](install.txt) folgen. Sie enthält die vorgesehenen Installationsschritte und die dazugehörigen Befehle in der richtigen Reihenfolge.

Grob umfasst die Installation folgende Schritte:

1. Verzeichnis `/docker` erstellen und das Verzeichnis `nc` aus dem Repository nach `/docker/nc` kopieren.
2. Dediziertes Docker-Netzwerk erstellen.
3. Redis und MariaDB starten.
4. Nextcloud-Datenbank und Datenbankbenutzer anlegen und anschließend die MariaDB-Sicherheitskonfiguration ausführen.
5. Eigenes Nextcloud-PHP-FPM-Image bauen.
6. Nextcloud-Anwendung herunterladen und entpacken sowie die Beispiel-Konfigurationsdateien kopieren.
7. Nextcloud-PHP-FPM-Container starten.
8. Caddy starten.
9. Im Browser `https://cloud.lokal.de` öffnen und die Nextcloud-Installation abschließen.
10. Optional Nextcloud-Apps konfigurieren, Portainer und Euro-Office installieren.

Portainer und Euro-Office sind optional und können unabhängig vom Kernsystem installiert werden.

## Verzeichnisstruktur des Repositorys

```text
nextcloud-caddy-docker/
├── install.txt
├── nc/
│   ├── create_network.sh
│   ├── caddy/
│   │   ├── compose.yml
│   │   ├── caddyfile
│   │   ├── start_caddy.sh
│   │   ├── restart_caddy.sh
│   │   └── update_image.sh
│   ├── euro-office/
│   │   ├── compose.yml
│   │   ├── start_euro-office.sh
│   │   └── update_image.sh
│   ├── mariadb/
│   │   ├── compose.yml
│   │   ├── mariadb.cnf
│   │   ├── first_start.sh
│   │   ├── start_mariadb.sh
│   │   └── update_image.sh
│   ├── nextcloud/
│   │   ├── compose.yml
│   │   ├── dockerfile
│   │   ├── build_nextcloud_image.sh
│   │   ├── load_latest_nextcloud.sh
│   │   ├── start_nextcloud.sh
│   │   ├── update_nextcloud.sh
│   │   ├── first_app_config.sh
│   │   ├── wartung.sh
│   │   ├── etc/
│   │   └── example/
│   └── redis/
│       ├── compose.yml
│       ├── start_redis.sh
│       ├── restart_redis.sh
│       └── update_image.sh
└── portainer/
    └── start_portainer.sh
```

## Komponenten

### Docker-Netzwerk

Skript: `nc/create_network.sh`

Erstellt das externe Docker-Bridge-Netzwerk, über das die Nextcloud-bezogenen Container miteinander kommunizieren.

Beispielwerte aus der mitgelieferten `config.env` (bei Bedarf anpassen):

| Einstellung | Wert |
|---|---|
| Docker-Netzwerk | `nc_cloud` |
| Linux-Bridge-Interface | `br_nc_cloud` |
| IPv4-Subnetz | `172.30.0.0/16` |
| IPv4-Gateway | `172.30.0.1` |
| IPv6-Subnetz | `fd00:172:30::/64` |
| IPv6-Gateway | `fd00:172:30::1` |

Die Werte werden über `DOCKER_NETWORK`, `DOCKER_IPV4_SUBNET`, `DOCKER_IPV4_GATEWAY`, `DOCKER_IPV6_SUBNET` und `DOCKER_IPV6_GATEWAY` in `config.env` gesteuert. Vor dem Anlegen prüfen, dass sich die Adressbereiche nicht mit vorhandenen Docker-Netzwerken, LAN-Subnetzen oder VPN-Netzen überschneiden.

### MariaDB

Verzeichnis: `nc/mariadb/`

MariaDB 11.8 stellt die Datenbank für Nextcloud bereit. Die Daten werden auf dem Host unter `/docker/nc/mariadb/db` gespeichert. Die mitgelieferte Compose-Datei veröffentlicht den Datenbankport nicht auf dem Host. Nextcloud erreicht MariaDB intern über das Docker-Netzwerk auf Port `3306`.

Wichtige Dateien:

| Datei | Aufgabe |
|---|---|
| `compose.yml` | Definition des MariaDB-Containers |
| `mariadb.cnf` | MariaDB-Serverkonfiguration |
| `start_mariadb.sh` | Startet den Dienst |
| `first_start.sh` | Erstellt Nextcloud-Datenbank und Benutzer und startet anschließend `mariadb-secure-installation` |
| `update_image.sh` | Lädt das konfigurierte Image und erstellt den Dienst neu |

Datenbankname, Benutzer und Passwörter werden zentral in `config.env` festgelegt. Vor der Installation müssen alle Beispiel-Zugangsdaten ersetzt werden.

### Redis

Verzeichnis: `nc/redis/`

Redis übernimmt das Caching und das transaktionale File Locking von Nextcloud. Die mitgelieferte Konfiguration setzt ein Speicherlimit von 512 MB und verwendet die Eviction-Policy `allkeys-lfu`. Redis ist intern über `nc_redis:6379` erreichbar. Der Port wird nicht auf dem Host veröffentlicht.

Verwaltungsskripte:

- `start_redis.sh`
- `restart_redis.sh`
- `update_image.sh`

### Nextcloud und PHP-FPM

Verzeichnis: `nc/nextcloud/`

Das eigene Image basiert auf `debian:trixie-slim` und stellt PHP 8.4 mit den für diese Umgebung benötigten Erweiterungen und Werkzeugen bereit. Zusätzlich sind Node.js 26, ImageMagick, FFmpeg und `iproute2` enthalten.

**Das Image enthält ausschließlich die PHP-FPM-Laufzeitumgebung, nicht den Nextcloud-Anwendungscode oder die Benutzerkonfiguration.** Anwendung, Konfiguration und Daten werden aus persistenten Verzeichnissen des Hosts eingebunden:

| Host-Pfad | Container-Pfad | Zweck |
|---|---|---|
| `/docker/nc/nextcloud/html` | `/var/www/nextcloud` | Nextcloud-Anwendung |
| `/docker/nc/nextcloud/data` | `/var/www/data` | Nextcloud-Benutzerdaten |
| `/docker/nc/nextcloud/etc` | `/etc/php/8.4/cli` und `/etc/php/8.4/fpm` | PHP-Konfiguration |

Wichtige Skripte:

| Skript | Aufgabe |
|---|---|
| `build_nextcloud_image.sh` | Baut das eigene Image aus `NC_IMAGE_NAME` und `NC_IMAGE_VERSION` in `config.env` |
| `load_latest_nextcloud.sh` | Lädt die aktuelle Nextcloud-Version herunter, entpackt sie und kopiert Beispiel-Konfigurationen |
| `start_nextcloud.sh` | Startet den PHP-FPM-Container |
| `update_nextcloud.sh` | Erstellt den PHP-FPM-Container neu |
| `first_app_config.sh` | Installiert und deaktiviert ausgewählte Nextcloud-Apps |
| `wartung.sh` | Führt die festgelegten Nextcloud-OCC-Wartungsaufgaben aus |

Die PHP-Konfiguration liegt unter `etc/`. Beispiel-Konfigurationsdateien für Nextcloud befinden sich unter `example/`.

Die Beispieldatei `autoconfig.php` enthält Datenbank- und Administratorangaben für die Erstinstallation. Vor dem Start müssen die Zugangsdaten an die tatsächliche Datenbank angepasst werden. Die Beispieldatei `vorgaben.config.php` enthält weitere Einstellungen, unter anderem für Proxy, URLs, Redis, E-Mail und Vorschaubilder. Diese Datei muss vor der Verwendung an die eigene Umgebung angepasst werden.

### Caddy

Verzeichnis: `nc/caddy/`

Caddy ist der Web-Einstiegspunkt und Reverse Proxy für Nextcloud und den optionalen Euro-Office-Dienst. Die Konfiguration befindet sich in der Datei `caddyfile`.

Die mitgelieferte Caddy-Konfiguration:

- stellt Nextcloud unter `cloud.lokal.de` bereit
- stellt Euro-Office unter `office.lokal.de` bereit
- verwendet den Wert von `CADDY_TLS` aus `config.env`
- aktiviert HTTP/1.1, HTTP/2 und HTTP/3
- leitet PHP-Anfragen an `nc_cloud:9000` weiter
- leitet Euro-Office-Anfragen an `nc_euro-office:80` weiter
- enthält Nextcloud-Weiterleitungen für bekannte Endpunkte und Zugriffsbeschränkungen

Caddy veröffentlicht TCP-Port `80` und `443` sowie UDP-Port `443`. Die persistenten Daten und die Konfiguration liegen unter `/docker/nc/caddy/`.

Verwaltungsskripte:

- `start_caddy.sh`
- `restart_caddy.sh`
- `update_image.sh`

Vor Änderungen an Domains oder TLS-Konfiguration bitte den Abschnitt [Lokale Nutzung und externe Erreichbarkeit](#lokale-nutzung-und-externe-erreichbarkeit) beachten.

### Euro-Office (optional)

Verzeichnis: `nc/euro-office/`

Euro-Office ermöglicht die Online-Bearbeitung von Dokumenten über das Document-Server-Image `ghcr.io/euro-office/documentserver:latest`.

Der Container ist mit dem gemeinsamen Docker-Netzwerk verbunden und wird über Caddy unter `nc_euro-office:80` angesprochen. Der interne Nginx gehört zum Document-Server-Image. Die mitgelieferte Compose-Datei veröffentlicht keinen Port auf dem Host.

Die Compose-Datei aktiviert JWT-Authentifizierung und enthält ein Beispiel-Secret. Dieses muss vor dem Einsatz ersetzt werden.

Persistente Verzeichnisse:

- `/docker/nc/euro-office/data`
- `/docker/nc/euro-office/private`

Start- und Update-Skripte:

- `start_euro-office.sh`
- `update_image.sh`

Nach dem Start des Document Servers muss zusätzlich die Euro-Office-App in Nextcloud installiert und konfiguriert werden. Die erforderlichen Schritte stehen in `install.txt`.

### Portainer (optional)

Verzeichnis: `portainer/`

Portainer ist eine optionale Verwaltungsoberfläche für Docker. Der Start erfolgt separat über `start_portainer.sh`. Portainer ist nicht mit dem gemeinsamen Nextcloud-Netzwerk verbunden.

Das aktuelle Skript veröffentlicht die HTTP-Oberfläche von Portainer auf Host-Port `9000`. Der Zugriff auf diese Oberfläche muss entsprechend abgesichert werden.

## Wartung und Updates

Jeder Dienst besitzt eigene Skripte. Die Compose-Aufrufe verwenden die zentrale Datei `/docker/nc/config.env`. Beachte, dass einzelne Skripte zusätzlich ein bestimmtes Arbeitsverzeichnis voraussetzen; die Beispiele zeigen den vorgesehenen Aufruf.

Beispiele:

```bash
cd /docker/nc/mariadb
./start_mariadb.sh
./update_image.sh
```

```bash
cd /docker/nc/redis
./start_redis.sh
./restart_redis.sh
./update_image.sh
```

```bash
cd /docker/nc/nextcloud
./start_nextcloud.sh
./update_nextcloud.sh
./wartung.sh
```

```bash
cd /docker/nc/caddy
./start_caddy.sh
./restart_caddy.sh
./update_image.sh
```

```bash
cd /docker/nc/euro-office
./start_euro-office.sh
./update_image.sh
```

Das Aktualisieren oder Neubauen des PHP-FPM-Images beziehungsweise -Containers aktualisiert nicht den Nextcloud-Anwendungscode. Beides sind getrennte Vorgänge und muss mit dem jeweils passenden Nextcloud-Update-Verfahren erfolgen.

## Sicherheitshinweise

Die mitgelieferte `nc/config.env` enthält ausdrücklich Beispielwerte. **Diese Werte müssen vor dem Einsatz ersetzt werden.** Das betrifft insbesondere Datenbankpasswörter, MariaDB-Root-Passwort, Nextcloud-Administratorpasswort, SMTP-Zugangsdaten und das Euro-Office-JWT-Secret. Die Datei ist als zentrale Konfiguration vorgesehen. Nach dem Kopieren nach `/docker/nc/config.env` sollte sie mit restriktiven Dateirechten geschützt werden, beispielsweise `chmod 600 /docker/nc/config.env`. Keine echten Zugangsdaten in ein öffentliches Git-Repository übernehmen.

Zusätzlich gilt:

- MariaDB und Redis nicht direkt im Internet veröffentlichen.
- Zugriff auf Portainer einschränken.
- Hostsystem, Docker-Images und Nextcloud aktuell halten.
- Nextcloud-Einstellungen für vertrauenswürdige Domains, Proxy und URL-Überschreibung nach Domainänderungen prüfen.
- Datenbank, Nextcloud-Daten, Anwendungskonfiguration und persistente Daten der Dienste regelmäßig sichern.

## Lizenz

Copyright (c) 2026 linux-helmut

Dieses Projekt steht unter der **PolyForm Noncommercial License 1.0.0**. Die Lizenz erlaubt die private und sonstige nicht-kommerzielle Nutzung, das Verändern sowie die Weitergabe des Projekts und eigener Änderungen. Eine kommerzielle Nutzung ist ohne eine separate Genehmigung des Rechteinhabers nicht gestattet.

Der vollständige Lizenztext befindet sich in der Datei [`LICENSE`](LICENSE). Die Lizenz gilt für die von `linux-helmut` bereitgestellten Projektbestandteile. Drittanbieter-Software, Container-Images und sonstige externe Komponenten unterliegen weiterhin ihren jeweiligen Lizenzen und Nutzungsbedingungen.
