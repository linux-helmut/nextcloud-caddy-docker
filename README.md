# Nextcloud Caddy Docker

A modular, self-hosted Nextcloud infrastructure using Docker, Caddy as reverse proxy, PHP-FPM, MariaDB and Redis.

The project provides a complete setup for running your own Nextcloud server with individually managed Docker containers and a manually installed Nextcloud application.

Each service has its own Docker Compose configuration and can be managed independently.

## Architecture

The planned infrastructure consists of the following components:

| Component | Description |
|---|---|
| Caddy | Reverse proxy, automatic HTTPS and TLS certificate management |
| PHP-FPM | PHP runtime environment for Nextcloud |
| Nextcloud | Manually installed Nextcloud application |
| MariaDB | Database backend |
| Redis | Caching and transactional file locking |
| Docker Network | Shared bridge network with IPv4 and IPv6 support |

All containers communicate through a dedicated Docker bridge network.

## Requirements

The following prerequisites must already be installed and operational:

- Debian Linux (Debian 13 recommended)
- Docker Engine
- Docker Compose Plugin
- SSH access with administrative privileges
- A registered domain with correctly configured DNS records
- Public access to TCP ports 80 and 443

Basic Debian installation and Docker setup are not covered by this project.

## Project Structure

```text
nextcloud-caddy-docker/
│
├── network/
│   └── create.sh
│
├── mariadb/
│   ├── compose.yml
│   ├── mariadb.cnf
│   ├── start.sh
│   └── update.sh
│
├── redis/
│   ├── compose.yml
│   ├── start.sh
│   ├── update.sh
│   └── restart.sh
│
├── caddy/                 # Planned
│
├── php-fpm/               # Planned
│
├── nextcloud/             # Planned
│
├── docs/                  # Planned
│
├── README.md
└── LICENSE                # Planned
```

## Components

### 1. Docker Network

Creates a dedicated Docker bridge network for communication between the containers.

Features:

- Custom IPv4 subnet
- IPv6 support
- Dedicated Linux bridge interface
- Shared network for all services

Files:

| File | Description |
|---|---|
| `network/create.sh` | Creates the Docker bridge network with IPv4 and IPv6 support |

Network name: `nextcloud`

Bridge interface: `br_nextcloud`

IPv4 subnet: `172.30.0.0/16`

IPv6 subnet: `fd00:172:30::/64`

Make sure the selected network ranges do not overlap with existing networks or VPN connections.

### 2. MariaDB

MariaDB provides the database backend for Nextcloud.

The database runs in its own Docker container with persistent storage and a custom server configuration.

Features:

- MariaDB 11.8
- Persistent database storage
- Custom MariaDB configuration
- Europe/Berlin timezone
- Internal Docker network communication
- No publicly exposed database port

Files:

| File | Description |
|---|---|
| `compose.yml` | MariaDB Docker Compose configuration |
| `mariadb.cnf` | MariaDB server configuration |
| `start.sh` | Creates and starts the MariaDB container |
| `update.sh` | Pulls the latest image and recreates the container |

The database is accessible to other containers through the Docker network using:

- Hostname: `mariadb`
- Port: `3306`

### 3. Redis

Redis provides caching and transactional file locking for Nextcloud.

The Redis container is configured for in-memory operation without persistent database snapshots.

Features:

- Redis Alpine image
- 512 MB memory limit
- LFU eviction policy
- Disabled RDB snapshots
- Dedicated Docker network

Files:

| File | Description |
|---|---|
| `compose.yml` | Redis Docker Compose configuration |
| `start.sh` | Creates and starts the Redis container |
| `update.sh` | Pulls the latest image and recreates the container |
| `restart.sh` | Recreates the Redis container after configuration changes |

### 4. PHP-FPM

PHP-FPM provides the PHP runtime environment for Nextcloud.

A custom Docker image is built using a dedicated Dockerfile.

Planned features:

- Custom PHP-FPM Docker image
- PHP extensions required by Nextcloud
- Separate CLI and FPM configurations
- Custom PHP-FPM pool configuration
- Configurable PHP memory and execution limits

### 5. Nextcloud

Nextcloud is installed manually inside the PHP-FPM container's web directory.

No prebuilt Nextcloud application image is required.

The application files are maintained separately from the PHP runtime environment.

This allows Nextcloud to be installed and updated independently of the PHP-FPM Docker image.

### 6. Caddy

Caddy acts as the reverse proxy for the Nextcloud installation.

Planned features:

- Automatic HTTPS
- Automatic TLS certificate management
- Reverse proxy configuration for PHP-FPM
- HTTP/3 support
- Separate persistent configuration and certificate storage

## Installation

The installation guide will cover the following steps:

1. Create the required directory structure.
2. Create the dedicated Docker network.
3. Configure and start MariaDB.
4. Configure and start Redis.
5. Build and start the custom PHP-FPM image.
6. Install Nextcloud manually.
7. Configure Caddy as reverse proxy.
8. Configure Nextcloud database access and Redis caching.
9. Complete the Nextcloud installation and verify the system.

Detailed installation instructions will be added as the project develops.

## Maintenance and Updates

Each Docker service is managed independently using its own Docker Compose configuration and shell scripts.

The project will include procedures for:

- Starting and stopping individual services
- Updating Docker images
- Recreating containers after configuration changes
- Updating Nextcloud manually
- Database maintenance
- Backup and recovery

## Security

The project follows a modular container architecture.

Important security considerations:

- Database and Redis services are not exposed publicly.
- Only required public services should publish host ports.
- Persistent application data is stored outside the containers.
- Secrets and passwords must not be committed to the repository.
- Docker images should be kept up to date.
- External storage permissions must be configured carefully.

## License

The original scripts, Docker configurations and documentation are intended to be released under the MIT License.

Third-party software, Docker images and included components remain subject to their respective licenses and copyright notices.

See the individual projects for further licensing information.

## Project Status

**Work in progress**

The project is being developed step by step.

The goal is to provide a complete, reproducible installation guide for building a self-hosted Nextcloud environment with Docker.

Additional components, configuration files and installation instructions will be added as development progresses.
