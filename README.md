# Nextcloud Caddy Docker

A modular, self-hosted Nextcloud infrastructure using Docker, Caddy as reverse proxy, PHP-FPM, MariaDB and Redis.

The project provides a complete setup for running your own Nextcloud server with individually managed Docker containers and a manually installed Nextcloud application.

Each service has its own Docker Compose configuration and can be managed independently.

## Architecture

The infrastructure consists of the following components:

| Component | Description |
|---|---|
| Caddy | Reverse proxy, automatic HTTPS and TLS certificate management |
| PHP-FPM | Custom PHP runtime environment for Nextcloud |
| Nextcloud | Manually installed Nextcloud application |
| MariaDB | Database backend |
| Redis | Caching and transactional file locking |
| Euro-Office | Online document editing and collaboration |
| Docker Network | Dedicated bridge network with IPv4 and IPv6 support |

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
├── nextcloud/
│   ├── compose.yml
│   ├── start.sh
│   ├── update.sh
│   ├── load_latest_nextcloud.sh
│   ├── configure_apps.sh
│   └── wartung.sh
│
├── euro-office/
│   ├── compose.yml
│   ├── start.sh
│   └── update.sh
│
├── caddy/                 # Planned
├── php-fpm/               # Planned
├── docs/                  # Planned
│
├── README.md
└── LICENSE                # Planned
```

## Components

### 1. Docker Network

Creates a dedicated Docker bridge network for communication between the individual containers.

Features:

- Custom IPv4 subnet
- IPv6 support
- Dedicated Linux bridge interface
- Shared network for all services

Files:

| File | Description |
|---|---|
| `create.sh` | Creates the Docker bridge network with IPv4 and IPv6 support |

Network configuration:

| Setting | Value |
|---|---|
| Network name | `nextcloud` |
| Bridge interface | `br_nextcloud` |
| IPv4 subnet | `172.30.0.0/16` |
| IPv4 gateway | `172.30.0.1` |
| IPv6 subnet | `fd00:172:30::/64` |
| IPv6 gateway | `fd00:172:30::1` |

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

### 4. Nextcloud PHP-FPM

Provides the PHP-FPM runtime environment for the manually installed Nextcloud application.

The container uses a custom Docker image and separate configuration directories for PHP CLI and PHP-FPM.

Features:

- Custom PHP-FPM Docker image
- PHP 8.4
- Separate CLI and FPM configuration
- Persistent Nextcloud application directory
- Separate Nextcloud data directory
- Dedicated Docker network

Files:

| File | Description |
|---|---|
| `compose.yml` | Nextcloud PHP-FPM Docker Compose configuration |
| `start.sh` | Creates and starts the PHP-FPM container |
| `update.sh` | Pulls the custom image and recreates the container |

### 5. Nextcloud Installation and Maintenance

Nextcloud is installed manually inside the PHP-FPM container's web directory.

No prebuilt Nextcloud application image is required.

This allows Nextcloud to be installed and updated independently of the PHP-FPM Docker image.

Files:

| File | Description |
|---|---|
| `load_latest_nextcloud.sh` | Downloads and extracts the latest Nextcloud release and sets file ownership |
| `configure_apps.sh` | Installs, configures or disables selected Nextcloud apps using OCC commands |
| `wartung.sh` | Runs Nextcloud maintenance tasks and creates detailed log files |

The app configuration script provides a collection of optional OCC commands. Administrators can selectively enable commands to install additional apps or disable unwanted apps.

The maintenance script includes tasks such as:

- Preview cleanup
- File cleanup
- File tree repair
- Maintenance repair
- Trashbin cleanup
- App data scanning
- Database index checks

A full file scan can optionally be enabled when required.

### 6. Euro-Office

Euro-Office provides online document editing and collaboration for Nextcloud.

The document server runs in a separate Docker container and communicates with Nextcloud through the dedicated Docker network.

Features:

- Euro-Office Document Server
- JWT authentication
- Persistent document storage
- Separate private data directory
- Integration with Nextcloud

Files:

| File | Description |
|---|---|
| `compose.yml` | Euro-Office Docker Compose configuration |
| `start.sh` | Creates and starts the Euro-Office container |
| `update.sh` | Pulls the latest image and recreates the container |

Container image:

`ghcr.io/euro-office/documentserver:latest`

### 7. Caddy

Caddy acts as the reverse proxy for the Nextcloud installation.

Planned features:

- Automatic HTTPS
- Automatic TLS certificate management
- Reverse proxy configuration for PHP-FPM
- HTTP/3 support
- Persistent configuration and certificate storage

## Installation

The installation guide will cover the following steps:

1. Create the required directory structure.
2. Create the dedicated Docker network.
3. Configure and start MariaDB.
4. Configure and start Redis.
5. Build and start the custom PHP-FPM image.
6. Install Nextcloud manually.
7. Configure Nextcloud apps and maintenance tasks.
8. Configure Caddy as reverse proxy.
9. Install and configure Euro-Office.
10. Complete the Nextcloud configuration and verify the system.

Detailed installation instructions will be added as the project develops.

## Maintenance and Updates

Each Docker service is managed independently using its own Docker Compose configuration and shell scripts.

The project includes procedures for:

- Starting individual services
- Updating Docker images
- Recreating containers after configuration changes
- Installing and updating Nextcloud manually
- Managing Nextcloud apps
- Running OCC maintenance tasks
- Database maintenance

## Security

The project follows a modular container architecture.

Important security considerations:

- Database and Redis services are not exposed publicly.
- Only required public services should publish host ports.
- Persistent application data is stored outside the containers.
- Secrets and passwords must not be committed to the repository.
- Docker images should be kept up to date.
- External storage permissions must be configured carefully.
- Euro-Office JWT authentication must use a strong, individual secret.

## Third-Party Software and Licenses

The project's original scripts, Docker configurations and documentation are intended to be released under the MIT License.

Third-party software, Docker images and included components remain subject to their respective licenses and copyright notices.

The licenses of all external components must be respected.

## Project Status

**Work in progress**

The project is being developed step by step.

The goal is to provide a complete, reproducible installation guide for building a self-hosted Nextcloud environment with Docker.

Additional components, configuration files and installation instructions will be added as development progresses.
