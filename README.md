# Nextcloud Caddy Docker

A modular, self-hosted Nextcloud environment built with Docker, PHP-FPM, MariaDB, Redis and Caddy.

The project is designed to keep the individual services independent. Each service has its own Docker Compose configuration and management scripts. The initial installation procedure is documented separately in [`install.txt`](install.txt).

**Default setup: local network use.** The supplied Caddy and Nextcloud configuration uses local hostnames and Caddy's internal certificate authority. See [Local network setup and external access](#local-network-setup-and-external-access) before installing.

## Features

- Modular Docker Compose setup
- Dedicated Docker bridge network with IPv4 and IPv6
- Caddy reverse proxy with HTTPS and HTTP/3
- Custom PHP-FPM image based on Debian 13
- PHP 8.4 and Nextcloud-related PHP extensions
- Node.js 26, ImageMagick and FFmpeg in the PHP-FPM image
- MariaDB 11.8 database backend
- Redis for caching and transactional file locking
- Optional Euro-Office Document Server integration
- Optional Portainer management interface
- Persistent application, database and service data outside containers
- Individual scripts to start, restart or update services

## Architecture

The stack consists of independently managed components:

| Component | Purpose |
|---|---|
| Caddy | HTTPS termination and reverse proxy |
| Nextcloud PHP-FPM | PHP runtime for the Nextcloud application |
| Nextcloud application | Application code, configuration and user data |
| MariaDB | Database backend |
| Redis | Caching and transactional file locking |
| Euro-Office | Optional online document editing |
| Portainer | Optional Docker management interface |

Caddy is the public-facing web entry point. It forwards requests to the Nextcloud PHP-FPM container and, when installed, to the Euro-Office Document Server.

The Euro-Office image includes its own internal Nginx, which is part of the Document Server. Caddy forwards requests to that service; the internal Nginx is not an additional public-facing reverse proxy.

Portainer is installed separately and does not use the shared Nextcloud Docker network.

### Request flow

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

The database, Redis, PHP-FPM and Euro-Office containers communicate over the dedicated Docker network. Their service ports are not published to the host by the supplied Compose files. Caddy publishes TCP ports 80 and 443 and UDP port 443.

## Local network setup and external access

### Default configuration: local use

The repository is configured for local network access by default.

Caddy uses its internal certificate authority through the `tls internal` directive. The supplied hostnames are:

| Service | Local hostname |
|---|---|
| Nextcloud | `cloud.lokal.de` |
| Euro-Office | `office.lokal.de` |

Both hostnames must be configured in the local DNS server and must resolve to the IP address of the Docker host. This DNS configuration is not created automatically by the installation scripts.

Clients must trust the root certificate of Caddy's internal certificate authority. Otherwise, browsers and other clients will report that the certificate is not trusted. Export Caddy's root certificate from its data directory and install it in the trusted root certificate store on the client devices.

The local DNS records and the trusted Caddy root certificate are both required for a clean local HTTPS setup.

### Using the installation externally

The supplied configuration is not ready for public Internet access without changes. To use the installation with public domains:

1. Replace `cloud.lokal.de` and `office.lokal.de` with the intended public hostnames.
2. Remove the `tls internal` directives from the corresponding site blocks in `nc/caddy/caddyfile`. Caddy can then obtain publicly trusted certificates automatically when the DNS and network requirements are met.
3. Search the repository and the deployed configuration for every occurrence of the old local hostnames and update them consistently. This includes, in particular, `nc/nextcloud/example/vorgaben.config.php` (for example, `overwritehost`, `overwrite.cli.url` and the `notify_push` URL), the Caddy configuration and any other domain-dependent settings.
4. Configure public DNS records for all hostnames to point to the server's public IP address.
5. Make TCP ports 80 and 443 reachable from the Internet. UDP port 443 is needed for HTTP/3.
6. Review the Nextcloud trusted-domain, overwrite and proxy settings, and any Euro-Office URL settings, to ensure they match the public domains and deployment.

Changing only the Caddyfile is not sufficient. All domain references in the Nextcloud and related configuration must agree.

## Requirements

- Debian Linux; Debian 13 (Trixie) is the intended base system
- Docker Engine
- Docker Compose plugin
- Administrative access to the host
- Sufficient persistent storage for the database, Nextcloud files and service data

For local use, a local DNS server must be available and configurable. For external use, public DNS and Internet reachability on the required ports are needed.

The repository does not install Debian or Docker itself.

## Installation

Follow [`install.txt`](install.txt) for the initial installation sequence. It describes the commands and manual steps in the intended order.

In outline, the installation consists of:

1. Create the `/docker` directory and copy the repository's `nc` directory to `/docker/nc`.
2. Create the dedicated Docker network.
3. Start Redis and MariaDB.
4. Create the Nextcloud database and database user, then run the MariaDB security setup.
5. Build the custom Nextcloud PHP-FPM image.
6. Download and extract the Nextcloud application and copy the example configuration files.
7. Start the Nextcloud PHP-FPM container.
8. Start Caddy.
9. Open `https://cloud.lokal.de` and complete the Nextcloud installation in the browser.
10. Optionally configure Nextcloud apps, Portainer and Euro-Office.

Portainer and Euro-Office are optional and can be installed independently of the core Nextcloud stack.

## Repository layout

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

## Components

### Docker network

Script: `nc/create_network.sh`

Creates the external Docker bridge network used by the Nextcloud-related containers.

Current network settings:

| Setting | Value |
|---|---|
| Docker network | `nextcloud` |
| Linux bridge interface | `br_nextcloud` |
| IPv4 subnet | `172.30.0.0/16` |
| IPv4 gateway | `172.30.0.1` |
| IPv6 subnet | `fd00:172:30::/64` |
| IPv6 gateway | `fd00:172:30::1` |

Check that these address ranges do not overlap with existing Docker networks, LAN subnets or VPN networks before creating the network.

### MariaDB

Directory: `nc/mariadb/`

MariaDB 11.8 provides the Nextcloud database. Its data is persisted on the host under `/docker/nc/mariadb/db`. The supplied Compose file does not publish the database port to the host; Nextcloud reaches MariaDB over the Docker network on port `3306`.

Main files:

| File | Purpose |
|---|---|
| `compose.yml` | MariaDB container definition |
| `mariadb.cnf` | MariaDB server configuration |
| `start_mariadb.sh` | Starts the service |
| `first_start.sh` | Creates the Nextcloud database and user, then starts `mariadb-secure-installation` |
| `update_image.sh` | Pulls the configured image and recreates the service |

Review the example database credentials in the Compose file and `first_start.sh` before using the setup.

### Redis

Directory: `nc/redis/`

Redis provides Nextcloud caching and transactional file locking. The supplied configuration sets a 512 MB maximum memory limit and uses the `allkeys-lfu` eviction policy. Redis is available to the other containers on the Docker network at `nc_redis:6379`; its port is not published to the host.

Management scripts:

- `start_redis.sh`
- `restart_redis.sh`
- `update_image.sh`

### Nextcloud and PHP-FPM

Directory: `nc/nextcloud/`

The custom image is built from `debian:trixie-slim` and provides PHP 8.4 with the extensions and tools required by this setup. It also includes Node.js 26, ImageMagick, FFmpeg and `iproute2`.

**The image contains the PHP-FPM runtime, not the Nextcloud application code or user configuration.** The application, configuration and data are mounted from persistent host directories:

| Host path | Container path | Purpose |
|---|---|---|
| `/docker/nc/nextcloud/html` | `/var/www/nextcloud` | Nextcloud application |
| `/docker/nc/nextcloud/data` | `/var/www/data` | Nextcloud user data |
| `/docker/nc/nextcloud/etc` | `/etc/php/8.4/cli` and `/etc/php/8.4/fpm` | PHP configuration |

Main scripts:

| Script | Purpose |
|---|---|
| `build_nextcloud_image.sh` | Builds the custom image (`nextcloud:v1.0.0`) |
| `load_latest_nextcloud.sh` | Downloads and prepares the latest Nextcloud release and copies example configuration files |
| `start_nextcloud.sh` | Starts the PHP-FPM container |
| `update_nextcloud.sh` | Recreates the PHP-FPM container |
| `first_app_config.sh` | Installs and disables the selected Nextcloud apps |
| `wartung.sh` | Runs the configured Nextcloud OCC maintenance tasks |

The PHP configuration is maintained in `etc/`. Example Nextcloud configuration files are provided in `example/`.

The example `autoconfig.php` contains database and administrator settings for the initial installation. Adapt it to the actual database credentials before running the setup. The example `vorgaben.config.php` contains additional settings, including proxy, URL, Redis, mail and preview configuration. Review and adapt it to your environment.

### Caddy

Directory: `nc/caddy/`

Caddy is the web entry point and reverse proxy for Nextcloud and the optional Euro-Office service. Its configuration is stored in `caddyfile`.

The supplied Caddy configuration:

- Serves Nextcloud on `cloud.lokal.de`
- Serves Euro-Office on `office.lokal.de`
- Uses `tls internal` for locally generated certificates
- Enables HTTP/1.1, HTTP/2 and HTTP/3
- Forwards PHP requests to `nextcloud:9000`
- Forwards Euro-Office requests to `nc_euro-office:80`
- Includes Nextcloud well-known redirects and access restrictions

Caddy publishes TCP ports `80` and `443`, plus UDP port `443`. Its persistent data and configuration are stored under `/docker/nc/caddy/`.

Management scripts:

- `start_caddy.sh`
- `restart_caddy.sh`
- `update_image.sh`

See [Local network setup and external access](#local-network-setup-and-external-access) before changing the domains or TLS configuration.

### Euro-Office (optional)

Directory: `nc/euro-office/`

Euro-Office provides online document editing through the Document Server image `ghcr.io/euro-office/documentserver:latest`.

The container is attached to the shared Docker network and is reached through Caddy at `nc_euro-office:80`. Its internal Nginx is part of the Document Server image. No host port is published by the supplied Compose file.

The Compose file enables JWT authentication and contains an example secret. Replace the example secret before using Euro-Office.

Persistent directories:

- `/docker/nc/euro-office/data`
- `/docker/nc/euro-office/private`

Start and update scripts:

- `start_euro-office.sh`
- `update_image.sh`

After starting the Document Server, the Euro-Office Nextcloud app must also be installed and configured. The required steps are listed in `install.txt`.

### Portainer (optional)

Directory: `portainer/`

Portainer is an optional Docker management interface. It is started separately by `start_portainer.sh` and is not connected to the shared Nextcloud network.

The current script publishes Portainer's HTTP interface on host port `9000`. Protect access to this interface appropriately.

## Maintenance and updates

Each service has its own scripts. Run them from the corresponding directory under `/docker/nc/`, so Docker Compose finds the intended `compose.yml`.

Examples:

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

Updating or rebuilding the PHP-FPM image/container does not update the Nextcloud application code. These are separate operations and should be handled using the appropriate Nextcloud update procedure.

## Security notes

The repository contains example credentials and secrets for demonstration and initial testing. **Do not use these values in a production environment.** Replace database passwords, the MariaDB root password, the Nextcloud administrator password and the Euro-Office JWT secret. Protect configuration files containing credentials and do not commit real secrets to Git.

Also:

- Do not expose MariaDB or Redis directly to the Internet.
- Restrict access to Portainer.
- Keep the host, Docker images and Nextcloud installation updated.
- Review Nextcloud trusted-domain, proxy and overwrite settings after changing domains.
- Back up the database, Nextcloud data, application configuration and service-specific persistent data.

## License and third-party software

This repository contains Docker Compose files, shell scripts and configuration examples. Third-party software and container images remain subject to their respective licenses and terms.
