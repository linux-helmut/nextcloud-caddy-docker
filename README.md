# nextcloud-caddy-docker

Self-hosted Nextcloud stack using Caddy as reverse proxy, PHP-FPM, MariaDB and Redis with Docker.

## Components

### Redis

Redis provides caching and file locking for Nextcloud.

```text
redis/
├── compose.yml    # Redis Docker Compose configuration
├── start.sh       # Create and start the Redis container
└── update.sh      # Pull latest image, recreate and start container
```

More components and installation instructions will be added as the project develops.
