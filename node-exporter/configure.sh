#!/bin/sh

#Create Node-exporter Systemd Service
sudo nano /etc/systemd/system/node_exporter.service

"
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5
[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --collector.logind
[Install]
WantedBy=multi-user.target
"

#Reload Systemd
sudo systemctl daemon-reload

#Start Node-exporter Service
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check Node-exporter Status
sudo systemctl status node_exporter

#Configure Prometheus Server(Edit prometheus.yml file)
sudo nano /etc/prometheus/prometheus.yml

#Update and Add job to prometheus server to monitor the new created node exporter
"
  - job_name: 'node_exporter'

    static_configs:

      - targets: ['localhost:9100']
"

#Restart prometheus server
sudo systemctl restart prometheus