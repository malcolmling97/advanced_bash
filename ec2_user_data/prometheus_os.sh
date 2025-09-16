#!/usr/bin/env bash
# Amazon Linux 2023 user-data (runs as root; no sudo needed)
set -Eeuo pipefail

PROM_VER="${PROM_VER:-2.54.1}"
NE_VER="${NE_VER:-1.8.2}"

# Faster boots: upgrade is optional; install the few pkgs we need
dnf -y swap curl-minimal curl
dnf -y install tar

# 1) Use system accounts; pick an available nologin path; make idempotent
NOLOGIN="$(command -v nologin || echo /sbin/nologin)"
id prometheus     >/dev/null 2>&1 || useradd --system --no-create-home --shell "$NOLOGIN" prometheus
id node_exporter  >/dev/null 2>&1 || useradd --system --no-create-home --shell "$NOLOGIN" node_exporter

# 2) Ensure data/config are owned by the runtime user
mkdir -p /etc/prometheus /var/lib/prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# 3) Download w/ -f to fail on HTTP errors
cd /tmp
curl -fSLO "https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz"
curl -fSLO "https://github.com/prometheus/node_exporter/releases/download/v${NE_VER}/node_exporter-${NE_VER}.linux-amd64.tar.gz"
tar -xzf "prometheus-${PROM_VER}.linux-amd64.tar.gz"
tar -xzf "node_exporter-${NE_VER}.linux-amd64.tar.gz"

# 4) Install binaries as root:root with exec perms (don’t chown to app users)
install -m 0755 "prometheus-${PROM_VER}.linux-amd64/prometheus"     /usr/local/bin/prometheus
install -m 0755 "prometheus-${PROM_VER}.linux-amd64/promtool"       /usr/local/bin/promtool
install -m 0755 "node_exporter-${NE_VER}.linux-amd64/node_exporter" /usr/local/bin/node_exporter

# Config
cat <<'YAML' > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: "prometheus"
    static_configs: [{ targets: ["127.0.0.1:9090"] }]
  - job_name: "node"
    static_configs: [{ targets: ["127.0.0.1:9100"] }]
YAML
chown prometheus:prometheus /etc/prometheus/prometheus.yml

# 5) Validate before starting (catches typos)
promtool check config /etc/prometheus/prometheus.yml

# Units (kept simple; “After/Wants” are fine)
cat <<'UNIT' > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network-online.target
Wants=network-online.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter --web.listen-address=127.0.0.1:9100
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

cat <<'UNIT' > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network-online.target
Wants=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now node_exporter prometheus

# Quick hints on the console
echo "Prometheus UI:  http://$(hostname -I | awk '{print $1}'):9090"
echo "Checks: curl -s localhost:9090/-/ready ; curl -s localhost:9100/metrics | head"
