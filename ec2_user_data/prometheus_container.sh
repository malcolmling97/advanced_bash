#!/usr/bin/env bash
# Amazon Linux 2023 user-data (runs as root; no sudo needed)
set -Eeuo pipefail

# Variables at the top for easy amendment
PROM_IMAGE_VER="${PROM_IMAGE_VER:-2.54.1}"
NE_IMAGE_VER="${NE_IMAGE_VER:-1.8.2}"

# Install docker
dnf -y install docker || true
dnf -y upgrade docker || true
systemctl enable --now docker

# Install docker compose (the plugin doesn't exist)
mkdir -p /usr/local/lib/docker/cli-plugins
DC_VER="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)"
ARCH="$(uname -m)" # x86_64 or aarch64
curl -SL "https://github.com/docker/compose/releases/download/${DC_VER}/docker-compose-linux-${ARCH}" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Checks to see what version it is
docker compose version

# ===================== Start creating config file here ====================
# Create folder
mkdir monitoring
cd monitoring

# Docker compose config
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v${PROM_IMAGE_VER}
    container_name: prometheus
    network_mode: "host"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    restart: unless-stopped

  node_exporter:
    image: prom/node-exporter:v${NE_IMAGE_VER}
    container_name: node_exporter
    pid: "host"
    network_mode: "host"
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/host:ro,rslave
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/host'
      - '--collector.systemd'
      - '--collector.tcpstat'
      - '--collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run|var/lib/docker|snap|var/lib/containerd)($|/)'

volumes:
  prometheus_data:
EOF

# Prometheus config
cat <<'EOF' > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"] 

  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
EOF


# run docker compose
docker compose up -d



