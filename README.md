# Nextcloud Caddy Docker

[![Release](https://img.shields.io/badge/release-v1.2.0-blue?style=flat-square)](https://github.com/linux-helmut/nextcloud-caddy-docker/releases/tag/v1.2.0)   MariaDB 12.3, PHP 8.5

[![Release](https://img.shields.io/badge/release-v1.1.0-blue?style=flat-square)](https://github.com/linux-helmut/nextcloud-caddy-docker/releases/tag/v1.1.0)   MariaDB 12.3, PHP 8.4

[![Release](https://img.shields.io/badge/release-v1.0.0-blue?style=flat-square)](https://github.com/linux-helmut/nextcloud-caddy-docker/releases/tag/v1.0.0)   MariaDB 11.8, PHP 8.4

Eine modulare, selbst betriebene Nextcloud-Umgebung auf Basis von Docker, PHP-FPM, MariaDB, Redis und Caddy.

Das Projekt stellt eine vorbereitete Struktur und Skripte bereit, um eine eigene Nextcloud-Umgebung einzurichten. Es ist bewusst als **Installations- und Bereitstellungsgrundlage** konzipiert und nicht als Verwaltungsplattform für den laufenden Betrieb.

Nach der Einrichtung werden die einzelnen Dienste eigenständig über ihre jeweiligen Docker-Compose-Konfigurationen und Skripte betrieben. Sie können unabhängig voneinander gestartet, neu gestartet, aktualisiert, ersetzt oder angepasst werden. Die erstmalige Einrichtung ist in [`install.md`](install.md) beschrieben.

Die mitgelieferte Beispielkonfiguration ist auf den lokalen Betrieb ausgelegt. Über die zentrale Konfigurationsdatei `nc/config.env` lassen sich Domains, DNS-Server und die TLS-Betriebsart einstellen. Mit passenden Domains, DNS-Einträgen und einer entsprechenden Netzwerkkonfiguration kann die Umgebung ebenso öffentlich erreichbar betrieben werden.

## Projektansatz

Das Projekt soll die Installation einer modularen Nextcloud-Umgebung erleichtern, ohne eine zusätzliche Verwaltungsebene für den späteren Betrieb einzuführen.

Jeder Dienst besitzt eine eigene Docker-Compose-Konfiguration und – soweit für den jeweiligen Dienst vorgesehen – eigene Skripte. Die Komponenten bleiben dadurch voneinander getrennt und können gezielt gewartet werden.

Ein wichtiger Aspekt ist die Trennung der PHP-FPM-Laufzeitumgebung vom Nextcloud-Anwendungscode. Wird beispielsweise eine Sicherheitslücke in PHP bekannt, kann das PHP-FPM-Image mit einer korrigierten Version neu gebaut und der zugehörige Container aktualisiert werden. Dafür ist keine neue Version dieses Installationsprojekts erforderlich. Der Nextcloud-Anwendungscode wird davon unabhängig aktualisiert.

Die Verantwortung für den laufenden Betrieb bleibt beim Betreiber. Dazu gehören insbesondere:

- Aktualisierung des Hostsystems und der Docker-Images
- Aktualisierung des Nextcloud-Anwendungscodes und der installierten Apps
- Datensicherung und Wiederherstellung
- Überwachung und Wartung der Dienste
- Anpassung der Konfiguration an die eigene Umgebung

Das Projekt liefert dafür eine strukturierte Ausgangsbasis und die erforderlichen Skripte. Es führt jedoch keine automatische zentrale Verwaltung oder Aktualisierung der installierten Umgebung durch.

## Funktionen und Komponenten

- Modularer Aufbau mit Docker Compose
- Eigenes Docker-Bridge-Netzwerk mit IPv4 und IPv6
- Caddy als Reverse Proxy mit HTTPS und HTTP/3
- Eigenes PHP-FPM-Image auf Basis von Debian 13
- PHP 8.4 mit den für diese Umgebung benötigten Erweiterungen
- Optional Node.js 26 sowie ImageMagick und FFmpeg im PHP-FPM-Image
- MariaDB 11.8 als Datenbank
- Redis für Caching und transaktionales File Locking
- Optionale Integration des Euro-Office Document Servers
- Optionales Verwaltungsinterface mit Portainer
- Persistente Anwendungs-, Datenbank- und Dienstdaten außerhalb der Container
- Separate Compose-Dateien und Verwaltungsskripte für die einzelnen Dienste

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

Der Euro-Office-Document-Server enthält einen eigenen internen Nginx. Dieser gehört zum Document Server und ist kein zusätzlicher öffentlich erreichbarer Reverse Proxy. Caddy leitet die Anfragen an diesen internen Dienst weiter.

Portainer wird separat gestartet und ist nicht mit dem gemeinsamen Nextcloud-Docker-Netzwerk verbunden.

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

Datenbank, Redis, PHP-FPM und Euro-Office kommunizieren über das dedizierte Docker-Netzwerk. Die mitgelieferten Compose-Dateien veröffentlichen ihre Dienstports nicht direkt auf dem Host. Caddy veröffentlicht TCP-Port 80 und 443 sowie UDP-Port 443.

## Lokaler und öffentlicher Betrieb

Die Betriebsart wird über die zentrale Konfigurationsdatei `/docker/nc/config.env` festgelegt. Die mitgelieferten Werte sind Beispiele und müssen vor der Installation an die eigene Umgebung angepasst werden.

### Interner Betrieb

Für den internen Betrieb werden lokale DNS-Einträge benötigt. Die Beispiel-Hostnamen lauten:

| Dienst | Lokaler Hostname |
|---|---|
| Nextcloud | `cloud.lokal.de` |
| Euro-Office | `office.lokal.de` |

Die Hostnamen müssen auf die IPv4- und IPv6-Adressen des Docker-Hosts zeigen. Das gilt für die Clients, den Docker-Host und die Container, die diese Domains aufrufen müssen.

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

Es reicht nicht aus, nur die DNS-Einträge zu ändern. Die Domains müssen in `config.env`, der Caddy-Konfiguration und den Nextcloud-Konfigurationen zusammenpassen.

### DNS-Konfiguration für Docker

Die von den Containern verwendeten DNS-Server werden zentral in `nc/config.env` festgelegt:

```bash
DOCKER_DNS_IPV4="1.1.1.1"
DOCKER_DNS_IPV6="2606:4700:4700::1111"
```

Die Beispielwerte verwenden öffentliche DNS-Server. Wer einen eigenen lokalen DNS-Server – beispielsweise AdGuard Home – verwendet, kann hier dessen IPv4- und IPv6-Adressen eintragen. Das ist insbesondere dann erforderlich, wenn die Container lokale Domains wie `cloud.lokal.de` oder `office.lokal.de` auflösen müssen.

Die DNS-Einstellungen der Container werden nicht automatisch aus der DNS-Konfiguration des Hosts übernommen, sondern über diese Variablen in den jeweiligen Compose-Dateien festgelegt.

## Voraussetzungen

- Debian Linux; vorgesehen ist Debian 13 (Trixie)
- Docker Engine
- Docker Compose Plugin
- Administrative Rechte auf dem Host
- Ausreichend Speicherplatz für Datenbank, Nextcloud-Dateien und Dienstdaten
- IPv4- und IPv6-Netzwerkkonnektivität entsprechend der gewählten Netzwerkkonfiguration

Für den lokalen Betrieb ist ein konfigurierbarer lokaler DNS-Server erforderlich. Der Docker-Host, die betreffenden Docker-Container und alle zugreifenden Clients müssen die verwendeten lokalen Domains auf die IPv4- und IPv6-Adressen des Docker-Hosts auflösen können. Die DNS-Server für die Container werden über `DOCKER_DNS_IPV4` und `DOCKER_DNS_IPV6` in `config.env` festgelegt.

Für den öffentlichen Zugriff sind öffentliche DNS-Einträge sowie die Erreichbarkeit der erforderlichen Ports notwendig.

Die Installation von Debian und Docker selbst ist nicht Bestandteil dieses Projekts.

## Installation

Für die erstmalige Einrichtung bitte der Datei [`install.md`](install.md) folgen. Sie enthält die vorgesehenen Installationsschritte und die dazugehörigen Befehle in der richtigen Reihenfolge.

Die Installation umfasst im Wesentlichen folgende Schritte:

1. Verzeichnis `/docker` erstellen und das Verzeichnis `nc` aus dem Repository nach `/docker/nc` kopieren.
2. Zentrales Docker-Netzwerk erstellen.
3. Redis und MariaDB starten.
4. Nextcloud-Datenbank und Datenbankbenutzer anlegen und anschließend die MariaDB-Sicherheitskonfiguration ausführen.
5. Eigenes Nextcloud-PHP-FPM-Image bauen.
6. Nextcloud-Anwendung herunterladen und entpacken sowie die Beispiel-Konfigurationsdateien kopieren und anpassen.
7. Nextcloud-PHP-FPM-Container starten.
8. Caddy starten.
9. Im Browser die konfigurierte Nextcloud-Domain öffnen und die Nextcloud-Installation abschließen.
10. Optional Nextcloud-Apps konfigurieren sowie Portainer und Euro-Office installieren.

Portainer und Euro-Office sind optional und können unabhängig vom Kernsystem installiert werden.

## Verzeichnisstruktur des Repositorys

```text
nextcloud-caddy-docker/
├── LICENSE
├── README.md
├── install.md
├── nc/
│   ├── config.env
│   ├── create_network.sh
│   ├── caddy/
│   │   ├── compose.yml
│   │   ├── caddyfile
│   │   ├── start_caddy.sh
│   │   ├── restart_caddy.sh
│   │   └── update_image.sh
│   ├── euro-office/
│   │   ├── compose.yml
│   │   ├── install_euro-office.sh
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

## Komponenten im Detail

### Docker-Netzwerk

Skript: `nc/create_network.sh`

Das Skript erstellt das externe Docker-Bridge-Netzwerk, über das die Nextcloud-bezogenen Container miteinander kommunizieren.

Beispielwerte aus der mitgelieferten `config.env` (bei Bedarf anpassen):

| Einstellung | Wert |
|---|---|
| Docker-Netzwerk | `nc_cloud` |
| Linux-Bridge-Interface | `br_nc_cloud` |
| IPv4-Subnetz | `172.30.0.0/16` |
| IPv4-Gateway | `172.30.0.1` |
| IPv6-Subnetz | `fd00:172:30::/64` |
| IPv6-Gateway | `fd00:172:30::1` |

Die Werte werden über `DOCKER_NETWORK`, `DOCKER_IPV4_SUBNET`, `DOCKER_IPV4_GATEWAY`, `DOCKER_IPV6_SUBNET` und `DOCKER_IPV6_GATEWAY` in `config.env` gesteuert. Vor dem Anlegen ist zu prüfen, dass sich die Adressbereiche nicht mit vorhandenen Docker-Netzwerken, LAN-Subnetzen oder VPN-Netzen überschneiden.

### MariaDB

Verzeichnis: `nc/mariadb/`

MariaDB 11.8 stellt die Datenbank für Nextcloud bereit. Die Daten werden auf dem Host unter `/docker/nc/mariadb/db` gespeichert. Die mitgelieferte Compose-Datei veröffentlicht den Datenbankport nicht auf dem Host. Nextcloud erreicht MariaDB intern über das Docker-Netzwerk auf Port `3306`.

| Datei | Aufgabe |
|---|---|
| `compose.yml` | Definition des MariaDB-Containers |
| `mariadb.cnf` | MariaDB-Serverkonfiguration |
| `start_mariadb.sh` | Startet den Dienst |
| `first_start.sh` | Erstellt Nextcloud-Datenbank und Benutzer und startet anschließend `mariadb-secure-installation` |
| `update_image.sh` | Aktualisiert das konfigurierte Image und erstellt den Dienst neu |

Datenbankname, Benutzer und Passwörter werden zentral in `config.env` festgelegt. Vor der Installation müssen alle Beispiel-Zugangsdaten ersetzt werden.

### Redis

Verzeichnis: `nc/redis/`

Redis übernimmt das Caching und das transaktionale File Locking von Nextcloud. Die mitgelieferte Konfiguration setzt ein Speicherlimit von 512 MB und verwendet die Eviction-Policy `allkeys-lfu`. Redis ist intern über `nc_redis:6379` erreichbar. Der Port wird nicht auf dem Host veröffentlicht.

Skripte:

- `start_redis.sh` – startet den Dienst
- `restart_redis.sh` – startet den Dienst neu
- `update_image.sh` – aktualisiert das Image und erstellt den Dienst neu

### Nextcloud und PHP-FPM

Verzeichnis: `nc/nextcloud/`

Das eigene Image basiert auf `debian:trixie-slim` und stellt PHP 8.4 mit den für diese Umgebung benötigten Erweiterungen und Werkzeugen bereit. Zusätzlich können Node.js 26 installiert sowie ImageMagick und FFmpeg im Image bereitgestellt werden.

**Das PHP-FPM-Image enthält weder den Nextcloud-Anwendungscode noch die Benutzerdaten.** Anwendung, Konfiguration und Daten liegen in persistenten Verzeichnissen auf dem Host und werden in den Container eingebunden:

| Host-Pfad | Container-Pfad | Zweck |
|---|---|---|
| `/docker/nc/nextcloud/html` | `/var/www/nextcloud` | Nextcloud-Anwendung und Konfiguration |
| `/docker/nc/nextcloud/data` | `/var/www/data` | Nextcloud-Benutzerdaten |
| `/docker/nc/nextcloud/etc` | `/etc/php/8.4/cli` und `/etc/php/8.4/fpm` | PHP-Konfiguration |

Wichtige Skripte:

| Skript | Aufgabe |
|---|---|
| `build_nextcloud_image.sh` | Baut das PHP-FPM-Image anhand von `NC_IMAGE_NAME`, `NC_IMAGE_VERSION` und `INSTALL_NODE26` aus `config.env` |
| `load_latest_nextcloud.sh` | Lädt die konfigurierte aktuelle Nextcloud-Version herunter, entpackt sie und kopiert Beispiel-Konfigurationsdateien |
| `start_nextcloud.sh` | Startet den PHP-FPM-Container |
| `update_nextcloud.sh` | Erstellt den PHP-FPM-Container mit dem konfigurierten Image neu |
| `first_app_config.sh` | Installiert und deaktiviert ausgewählte Nextcloud-Apps |
| `wartung.sh` | Führt die vorgesehenen Nextcloud-OCC-Wartungsaufgaben aus |

Die PHP-Konfiguration liegt unter `etc/`. Beispiel-Konfigurationsdateien für Nextcloud befinden sich unter `example/`.

Die Beispieldatei `autoconfig.php` enthält Datenbank- und Administratorangaben für die Erstinstallation. Vor dem Start müssen die Zugangsdaten an die tatsächliche Datenbank angepasst werden. Die Beispieldatei `vorgaben.config.php` enthält weitere Einstellungen, unter anderem für Proxy, URLs, Redis, E-Mail und Vorschaubilder. Diese Datei muss vor der Verwendung an die eigene Umgebung angepasst werden.

PHP-FPM und der Nextcloud-Anwendungscode werden getrennt aktualisiert. Ein Neubau des PHP-FPM-Images aktualisiert nicht automatisch den Nextcloud-Anwendungscode. Umgekehrt ersetzt ein Nextcloud-Anwendungsupdate nicht die PHP-Laufzeitumgebung.

#### Nextcloud-Hintergrundaufgaben (Cron)

Die regelmäßige Ausführung der Nextcloud-Hintergrundaufgaben erfolgt über den Cron-Dienst des Docker-Hosts.

Dazu muss auf dem Host ein Cronjob eingerichtet werden, der alle fünf Minuten `cron.php` im Nextcloud-Container ausführt.

Beispiel für `/etc/cron.d/nextcloud`:

```cron
*/5 * * * * root docker exec -u www-data nc_cloud php /var/www/nextcloud/cron.php
```

Der Cronjob wird auf dem Docker-Host ausgeführt, nicht innerhalb des Containers.

Voraussetzung ist, dass der Cron-Dienst auf dem Host installiert und aktiv ist.



### Caddy

Verzeichnis: `nc/caddy/`

Caddy ist der Web-Einstiegspunkt und Reverse Proxy für Nextcloud und den optionalen Euro-Office-Dienst. Die Konfiguration befindet sich in der Datei `caddyfile`.

Die mitgelieferte Caddy-Konfiguration:

- stellt Nextcloud unter der in `NC_DOMAIN` festgelegten Domain bereit
- stellt Euro-Office unter der in `OFFICE_DOMAIN` festgelegten Domain bereit
- verwendet den Wert von `CADDY_TLS` aus `config.env`
- unterstützt HTTP/1.1, HTTP/2 und HTTP/3
- leitet PHP-Anfragen an `nc_cloud:9000` weiter
- leitet Euro-Office-Anfragen an `nc_euro-office:80` weiter
- enthält Weiterleitungen für bekannte Nextcloud-Endpunkte und Zugriffsbeschränkungen

Caddy veröffentlicht TCP-Port `80` und `443` sowie UDP-Port `443`. Die persistenten Daten und die Konfiguration liegen unter `/docker/nc/caddy/`.

Skripte:

- `start_caddy.sh` – startet Caddy
- `restart_caddy.sh` – startet Caddy neu
- `update_image.sh` – aktualisiert das Image und erstellt den Dienst neu

Vor Änderungen an Domains oder TLS-Konfiguration sind die Abschnitte [Lokaler und öffentlicher Betrieb](#lokaler-und-öffentlicher-betrieb) und [DNS-Konfiguration für Docker](#dns-konfiguration-für-docker) zu beachten.

### Euro-Office (optional)

Verzeichnis: `nc/euro-office/`

Euro-Office ermöglicht die Online-Bearbeitung von Dokumenten über das Document-Server-Image `ghcr.io/euro-office/documentserver:latest`.

Der Container ist mit dem gemeinsamen Docker-Netzwerk verbunden und wird intern über `nc_euro-office:80` angesprochen. Der interne Nginx gehört zum Document-Server-Image. Die mitgelieferte Compose-Datei veröffentlicht keinen Port auf dem Host. Der Zugriff von außen erfolgt über Caddy und die konfigurierte `OFFICE_DOMAIN`.

Die Compose-Datei aktiviert JWT-Authentifizierung. Das Beispiel-Secret in `config.env` muss vor dem Einsatz durch einen eigenen ausreichend langen Schlüssel ersetzt werden. Derselbe Schlüssel muss auch in der Nextcloud-Euro-Office-App hinterlegt werden.

Persistente Verzeichnisse:

- `/docker/nc/euro-office/data`
- `/docker/nc/euro-office/private`

Skripte:

- `start_euro-office.sh` – startet den Document Server
- `update_image.sh` – aktualisiert das Image und erstellt den Dienst neu
- `install_euro-office.sh` – installiert und konfiguriert die Nextcloud-App

Euro-Office ist optional. Nach dem Start des Document Servers muss zusätzlich die Euro-Office-App in Nextcloud installiert und konfiguriert werden. Die Schritte dazu sind in [`install.md`](install.md) beschrieben.

### Portainer (optional)

Verzeichnis: `portainer/`

Portainer ist eine optionale Verwaltungsoberfläche für Docker. Der Start erfolgt separat über `start_portainer.sh`. Portainer ist nicht mit dem gemeinsamen Nextcloud-Netzwerk verbunden.

Das mitgelieferte Skript veröffentlicht die HTTP-Oberfläche von Portainer auf Host-Port `9000`. Der Zugriff auf diese Oberfläche muss entsprechend abgesichert werden. Portainer ist nicht Voraussetzung für den Betrieb der Nextcloud-Umgebung.

## Wartung und Updates

Die Dienste werden einzeln über ihre Compose-Dateien und Skripte verwaltet. Die Compose-Aufrufe verwenden die zentrale Datei `/docker/nc/config.env`. Einige Skripte setzen außerdem voraus, dass sie aus ihrem jeweiligen Verzeichnis aufgerufen werden.

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
./build_nextcloud_image.sh
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

Die Aktualisierung eines Dienstes erfolgt gezielt über dessen eigenes Image beziehungsweise dessen eigene Anwendung. Dabei sind Abhängigkeiten und Kompatibilität zwischen den Komponenten zu berücksichtigen. Insbesondere müssen Nextcloud-Anwendungscode, PHP-Version und Datenbankversion zueinander passen.

Das Projekt führt keine automatische Update-Prüfung und keine automatische Aktualisierung der Dienste durch. Der Betreiber entscheidet selbst, wann und auf welche Version aktualisiert wird.

## Sicherheit und Datensicherung

Die mitgelieferte `nc/config.env` enthält ausdrücklich Beispielwerte. **Alle Beispiel-Zugangsdaten und Secrets müssen vor dem Einsatz ersetzt werden.** Das betrifft insbesondere:

- Datenbankpasswort und MariaDB-Root-Passwort
- Nextcloud-Administratorpasswort
- SMTP-Zugangsdaten
- Euro-Office-JWT-Secret

Die Datei ist als zentrale Konfiguration vorgesehen. Nach dem Kopieren nach `/docker/nc/config.env` sollte sie mit restriktiven Dateirechten geschützt werden, beispielsweise:

```bash
chmod 600 /docker/nc/config.env
```

Keine echten Zugangsdaten in ein öffentliches Git-Repository übernehmen.

Zusätzlich gilt:

- MariaDB und Redis nicht direkt im Internet veröffentlichen.
- Zugriff auf Portainer einschränken.
- Hostsystem, Docker-Images und Nextcloud-Anwendung aktuell halten.
- Nextcloud-Einstellungen für vertrauenswürdige Domains, Proxy und URL-Überschreibung nach Domainänderungen prüfen.
- Datenbank, Nextcloud-Daten, Anwendungskonfiguration und persistente Dienstdaten regelmäßig sichern.
- Vor größeren Versionswechseln eine überprüfte Datensicherung erstellen.

Die Verantwortung für Updates, Sicherheit und Datensicherung liegt beim Betreiber der installierten Umgebung.

## Lizenz

Copyright (c) 2026 linux-helmut

Dieses Projekt steht unter der **PolyForm Noncommercial License 1.0.0**. Die Lizenz erlaubt die private und sonstige nicht-kommerzielle Nutzung, das Verändern sowie die Weitergabe des Projekts und eigener Änderungen. Eine kommerzielle Nutzung ist ohne eine separate Genehmigung des Rechteinhabers nicht gestattet.

Der vollständige Lizenztext befindet sich in der Datei [`LICENSE`](LICENSE). Die Lizenz gilt für die von `linux-helmut` bereitgestellten Projektbestandteile. Drittanbieter-Software, Container-Images und sonstige externe Komponenten unterliegen weiterhin ihren jeweiligen Lizenzen und Nutzungsbedingungen.
