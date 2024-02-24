#!bin/bash

#Install Alert-manager binaries
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz 

tar xvfz alertmanager-0.26.0.linux-amd64.tar.gz

sudo cp alertmanager-0.26.0.linux-amd64/alertmanager /usr/local/bin
sudo cp alertmanager-0.26.0.linux-amd64/amtool /usr/local/bin/
sudo mkdir /var/lib/alertmanager

rm -rf alertmanager*