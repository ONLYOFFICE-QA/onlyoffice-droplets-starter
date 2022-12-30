#!/bin/bash
DS_VERSION=replace_me


fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50
service ufw stop
ufw disable
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
apt install docker-ce -y
apt install docker-compose -y
docker run -itd -p 80:80 --name 'droplet_starter' onlyoffice/4testing-documentserver-ee:$DS_VERSION
sleep 90
sudo docker exec droplet_starter sudo supervisorctl start ds:example
sudo docker exec droplet_starter sudo sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
