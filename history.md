# Versionshistorie

## v1.2.2
- Talk optional erweitert
  - Talk High Performance Backend (AIO-Talk)
  - `config.env` um Talk-Domain erweitert
  - Caddy um Port 3478 (TCP/UDP) erweitert
  - Nextcloud Talk App optional installierbar
  - Automatische Konfiguration über OCC

## v1.2.1
- PHP-8.5-Konfiguration bereinigt und überarbeitet
- MariaDB-Konfiguration angepasst
- Node.js 26 optional integrierbar (standardmäßig deaktiviert)

## v1.2.0
- Umstellung auf PHP 8.5
- Anpassung des PHP-Dockerfiles und der Build-Konfiguration
- Überarbeitung der PHP-FPM-Konfiguration
- Bereinigung der PHP-Modulkonfiguration

## v1.1.0
- Umstellung auf MariaDB 12.3
- Überarbeitung der Docker-Compose-Dateien
- Anpassung der zentralen `config.env`
- Überarbeitung des Euro-Office-Installationsskripts
- Überarbeitung der Projektdokumentation

## v1.0.0
- Erste Veröffentlichung
- Grundstruktur:
  - Caddy
  - PHP-FPM 8.4
  - MariaDB 11.8
  - Redis
  - Euro-Office (optional)