#Run a shell script from version control
wget -O - https://raw.githubusercontent.com/username/path-to-the-sh-file | bash

#Check uncomplicatedFirewall(ufw) status
sudo ufw status verbose

#Enable ufw
sudo ufw enable

#Open or close port after enabling firewall(ufw)
sudo ufw allow port/tcp
sudo ufw deny port/tcp

#Display hot names instead of IPs

"""
  - job_name: 'node_exporter'
    static_configs:
      - targets: ["localhost:9100"]
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: 'monitoring server'
"""