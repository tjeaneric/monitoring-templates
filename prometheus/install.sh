#!/bin/sh

#Update system packages
sudo apt update

#Create a System User for Prometheus
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

#Create Directories for Prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

#Download Prometheus and Extract Files
wget https://github.com/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz
tar vxf prometheus*.tar.gz

#open port 9090 and Access Prometheus Web Interface
sudo ufw allow 9090/tcp


#Navigate to the Prometheus Directory
cd prometheus*/

#Move the Binary Files & Set Owner
sudo mv prometheus /usr/local/bin
sudo mv promtool /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

#Move the Configuration Files & Set Owner
sudo mv consoles /etc/prometheus
sudo mv console_libraries /etc/prometheus
sudo mv prometheus.yml /etc/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus

#remove prometheus downloaded files
rm -rf prometheus-2.49.1.linux-amd64.tar.gz prometheus-2.49.1.linux-amd64

#Create prometheus.yml file incase it is not already created
sudo tee /etc/prometheus/prometheus.yml << EOF;
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

#Create Prometheus Systemd Service
sudo tee /etc/systemd/system/prometheus.service << EOF;
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
    --web.enable-lifecycle


[Install]
WantedBy=multi-user.target
EOF


#Reload Systemd
sudo systemctl daemon-reload

#Start Prometheus Service
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check Prometheus Status
sudo systemctl status prometheus