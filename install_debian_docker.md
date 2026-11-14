
# Debian 13 und Docker

## Debian 13 (Trixie)

https://www.debian.org

## Docker Engine

Docker wird über das offizielle Docker-Repository installiert.

### Repository einrichten

```bash
apt update
apt install ca-certificates curl

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: trixie
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

### Docker installieren

```bash
apt update

apt install docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

### Installation prüfen

```bash
docker --version
docker compose version
systemctl status docker
```
