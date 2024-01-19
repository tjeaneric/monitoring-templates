#Run a shell script from version control
wget -O - https://raw.githubusercontent.com/username/path-to-the-sh-file | bash

#Check uncomplicatedFirewall(ufw) status
sudo ufw status verbose

#Enable ufw
sudo ufw enable

#Open or close port after enabling firewall(ufw)
sudo ufw allow port/tcp
sudo ufw deny port/tcp

