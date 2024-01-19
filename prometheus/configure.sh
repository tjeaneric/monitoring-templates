#!/bin/sh
#Create prometheus.yml file incase it is not already created
sudo nano /etc/prometheus/prometheus.yml

"
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
"

#Create Prometheus Systemd Service
sudo nano /etc/systemd/system/prometheus.service

"
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
"

#Reload Systemd
sudo systemctl daemon-reload

#Start Prometheus Service
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check Prometheus Status
sudo systemctl status prometheus

