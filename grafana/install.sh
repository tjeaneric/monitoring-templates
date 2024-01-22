#!/bin/sh 

#Update and upgrade
sudo apt update -y && sudo apt upgrade -y

#Install the required packages
sudo apt install -y apt-transport-https software-properties-common wget

#Add the Grafana GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

#Add Grafana APT repository
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update

#Install Grafana
sudo apt install grafana

#Start the Grafana service
sudo grafana-server -v
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server


#Open the port in the firewall
sudo ufw enable 
sudo ufw allow ssh
sudo ufw allow 3000/tcp

