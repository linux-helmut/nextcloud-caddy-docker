# nextcloud-caddy-docker

Self-hosted Nextcloud stack using Caddy as reverse proxy, PHP-FPM, MariaDB and Redis with Docker.

The project provides a modular Docker-based infrastructure for running a self-hosted Nextcloud server. Each service is configured and managed independently using Docker Compose.

## Requirements

The following components are expected to be installed and operational:

- Debian Linux
- Docker Engine
- Docker Compose Plugin
- A configured domain with public DNS records
- Public access to TCP ports 80 and 443

## Project Structure

```text
nextcloud-caddy-docker/
│
├── network/
│   └── create.sh           # Create Docker network with IPv4 and IPv6
│
├── redis/
│   ├── compose.yml         # Redis Docker Compose configuration
│   ├── start.sh            # Create and start the Redis container
│   ├── update.sh           # Update Redis image and recreate container
│   └── restart.sh          # Recreate Redis container after configuration changes
│
├── README.md
└── LICENSE                 # To be added
```

## Components

### Docker Network

Creates a dedicated Docker bridge network for communication between the individual services.

Features:
- Custom IPv4 subnet
- IPv6 support
- Dedicated bridge interface
- Shared network for all application containers

```text
network/
└── create.sh    # Creates the Docker network with IPv4 and IPv6 support
```

### Redis

Redis provides caching and file locking for Nextcloud.

```text
redis/
├── compose.yml    # Redis Docker Compose configuration
├── start.sh       # Create and start the Redis container
├── update.sh      # Pull latest image, recreate and start container
└── restart.sh     # Recreate Redis container after configuration changes
```

## Installation

Installation instructions for the individual components will be added as the project develops.

## License

The project's original scripts, configuration files and documentation will be released under the MIT License.

Third-party software, Docker images and included components remain subject to their respective licenses and copyright notices.

## Project Status

Work in progress. Additional components and installation instructions will be added step by step.
