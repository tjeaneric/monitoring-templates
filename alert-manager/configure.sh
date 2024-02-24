#!bin/bash

#Configure Alertmanager as a service
sudo nano /etc/systemd/system/alertmanager.service

"
[Unit]
Description=Alert Manager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/prometheus/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

Restart=always

[Install]
WantedBy=multi-user.target
"


#Add Alertmanager’s configuration
sudo nano /etc/prometheus/alertmanager.yml

"
global:
  resolve_timeout: 1m
  slack_api_url: 'url'

route:
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#monitoring-instances'
    send_resolved: true
    icon_url: https://avatars3.githubusercontent.com/u/3380462
    title: |-
     [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
     {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
       {{" "}}(
       {{- with .CommonLabels.Remove .GroupLabels.Names }}
         {{- range $index, $label := .SortedPairs -}}
           {{ if $index }}, {{ end }}
           {{- $label.Name }}="{{ $label.Value -}}"
         {{- end }}
       {{- end -}}
       )
     {{- end }}
    text: >-
     {{ range .Alerts -}}
     *Alert:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}

     *Description:* {{ .Annotations.description }}

     *Details:*
       {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
       {{ end }}
     {{ end }}
""



# Create a rule
sudo nano /etc/prometheus/rules.yml

"
# Instance down rule
groups:
- name: AllInstances
  rules:
  - alert: InstanceDown
    # Condition for alerting
    expr: up == 0
    for: 1m
    # Annotation - additional informational labels to store more information
    annotations:
      title: 'Instance {{ $labels.instance }} down'
      description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute.'
    # Labels - additional labels to be attached to the alert
    labels:
      severity: 'critical'
"

"
# Rule for high storage usage alert
groups:
  - name: StorageThreshold
    rules:
      - alert: HighStorageUsage
        expr: 100 * (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes{mountpoint="/"})) > 50
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "High storage usage on {{ $labels.instance }}"
          description: "Storage usage on {{ $labels.instance }} is greater than 50%."
"

"
# Rule for memory usage alert
groups:
  - name: MemoryThreshold
    rules:
      - alert: HighRAMUsage
        expr: 100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 60
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "High RAM usage on {{ $labels.instance }}"
          description: "RAM usage on {{ $labels.instance }} is greater than 60%."
"

"
# Rule to get an alert when the CPU usage goes more than 60%.
groups:
  - name: CpuThreshold
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 60
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage on {{ $labels.instance }} is greater than 60%."
"

# Add the rules to the prometheus.yml file
sudo nano /etc/prometheus/prometheus.yml


# Reload Systemd
sudo systemctl daemon-reload 

#Start Alert manager Service
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# Check alertmanager Status
sudo systemctl status alertmanager
