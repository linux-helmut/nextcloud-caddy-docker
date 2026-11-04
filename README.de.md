# Nextcloud Caddy Docker

Eine modulare, selbst betriebene Nextcloud-Umgebung auf Basis von Docker, PHP-FPM, MariaDB, Redis und Caddy.

Das Projekt ist so aufgebaut, dass die einzelnen Dienste unabhängig voneinander betrieben und gewartet werden können. Jeder Dienst besitzt eine eigene Docker-Compose-Konfiguration sowie eigene Skripte zum Starten, Neustarten und Aktualisieren. Die erstmalige Einrichtung ist separat in [`install.txt`](install.txt) beschrieben.

**Standardeinstellung: lokale Nutzung im eigenen Netzwerk.** Die mitgelieferte Caddy- und Nextcloud-Konfiguration verwendet lokale Hostnamen und die interne Zertifizierungsstelle von Caddy. Bitte vor der Installation den Abschnitt [Lokale Nutzung und externe Erreichbarkeit](#lokale-nutzung-und-externe-erreichbarkeit) beachten.

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

## Lokale Nutzung und externe Erreichbarkeit

### Standardeinstellung: lokale Nutzung

Das Repository ist zunächst für den Zugriff innerhalb eines lokalen Netzwerks eingerichtet.

Caddy verwendet über die Direktive `tls internal` seine eigene interne Zertifizierungsstelle. Die vorgesehenen Hostnamen lauten:

| Dienst | Lokaler Hostname |
|---|---|
| Nextcloud | `cloud.lokal.de` |
| Euro-Office | `office.lokal.de` |

Beide Hostnamen müssen im lokalen DNS-Server eingerichtet werden und auf die IP-Adresse des Docker-Hosts zeigen. Diese DNS-Einträge werden durch die Installationsskripte nicht automatisch angelegt.

Zusätzlich müssen die Clients dem Root-Zertifikat der internen Caddy-Zertifizierungsstelle vertrauen. Andernfalls zeigen Browser und andere Clients eine Zertifikatswarnung an. Das Root-Zertifikat kann aus dem Datenverzeichnis von Caddy exportiert und auf den jeweiligen Geräten im Speicher für vertrauenswürdige Stammzertifikate installiert werden.

Für eine saubere lokale HTTPS-Nutzung sind somit sowohl die lokalen DNS-Einträge als auch das vertrauenswürdige Caddy-Root-Zertifikat erforderlich.

### Nutzung von außen über das Internet

Die mitgelieferte Konfiguration ist nicht ohne Anpassungen für den öffentlichen Internetzugriff vorgesehen. Für die Nutzung mit öffentlichen Domains sind folgende Änderungen notwendig:

1. `cloud.lokal.de` und `office.lokal.de` durch die gewünschten öffentlichen Hostnamen ersetzen.
2. Die Direktiven `tls internal` aus den entsprechenden Site-Blöcken in `nc/caddy/caddyfile` entfernen. Caddy kann anschließend automatisch öffentlich vertrauenswürdige Zertifikate beziehen, sofern DNS und Netzwerkzugriff korrekt eingerichtet sind.
3. Das Repository und die tatsächlich verwendeten Konfigurationsdateien nach allen Vorkommen der bisherigen lokalen Hostnamen durchsuchen und diese konsistent ersetzen. Dazu gehören insbesondere `nc/nextcloud/example/vorgaben.config.php` (beispielsweise `overwritehost`, `overwrite.cli.url` und die URL für `notify_push`), die Caddy-Konfiguration und weitere domainabhängige Einstellungen.
4. Öffentliche DNS-Einträge für alle Hostnamen einrichten, die auf die öffentliche IP-Adresse des Servers zeigen.
5. TCP-Port 80 und 443 aus dem Internet erreichbar machen. Für HTTP/3 wird zusätzlich UDP-Port 443 benötigt.
6. Die Nextcloud-Einstellungen für vertrauenswürdige Domains, Proxy und URL-Überschreibung sowie gegebenenfalls die Euro-Office-URL prüfen und an die öffentlichen Domains anpassen.

Es reicht nicht aus, nur die Domains im Caddyfile zu ändern. Alle Domainreferenzen in Nextcloud und den zugehörigen Konfigurationen müssen übereinstimmen.

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

Aktuelle Netzwerkeinstellungen:

| Einstellung | Wert |
|---|---|
| Docker-Netzwerk | `nextcloud` |
| Linux-Bridge-Interface | `br_nextcloud` |
| IPv4-Subnetz | `172.30.0.0/16` |
| IPv4-Gateway | `172.30.0.1` |
| IPv6-Subnetz | `fd00:172:30::/64` |
| IPv6-Gateway | `fd00:172:30::1` |

Vor dem Anlegen prüfen, dass sich diese Adressbereiche nicht mit vorhandenen Docker-Netzwerken, LAN-Subnetzen oder VPN-Netzen überschneiden.

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

Vor der Verwendung die Beispiel-Zugangsdaten in der Compose-Datei und in `first_start.sh` prüfen.

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
| `build_nextcloud_image.sh` | Baut das eigene Image (`nextcloud:v1.0.0`) |
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
- verwendet `tls internal` für lokal erzeugte Zertifikate
- aktiviert HTTP/1.1, HTTP/2 und HTTP/3
- leitet PHP-Anfragen an `nextcloud:9000` weiter
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

Jeder Dienst besitzt eigene Skripte. Diese sollten aus dem jeweiligen Verzeichnis unter `/docker/nc/` aufgerufen werden, damit Docker Compose die passende `compose.yml` findet.

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

Das Repository enthält Beispiel-Zugangsdaten und Secrets zur Demonstration und für erste Tests. **Diese Werte dürfen nicht in einer produktiven Umgebung verwendet werden.** Datenbankpasswörter, MariaDB-Root-Passwort, Nextcloud-Administratorpasswort und das Euro-Office-JWT-Secret müssen ersetzt werden. Konfigurationsdateien mit Zugangsdaten sind zu schützen. Echte Secrets dürfen nicht in Git eingecheckt werden.

Zusätzlich gilt:

- MariaDB und Redis nicht direkt im Internet veröffentlichen.
- Zugriff auf Portainer einschränken.
- Hostsystem, Docker-Images und Nextcloud aktuell halten.
- Nextcloud-Einstellungen für vertrauenswürdige Domains, Proxy und URL-Überschreibung nach Domainänderungen prüfen.
- Datenbank, Nextcloud-Daten, Anwendungskonfiguration und persistente Daten der Dienste regelmäßig sichern.

## Lizenz und Drittanbieter-Software

Dieses Repository enthält Docker-Compose-Dateien, Shell-Skripte und Konfigurationsbeispiele. Für Drittanbieter-Software und Container-Images gelten deren jeweilige Lizenzen und Nutzungsbedingungen.
