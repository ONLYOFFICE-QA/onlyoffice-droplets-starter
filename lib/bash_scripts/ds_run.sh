#!/bin/bash

source ./swap.sh
source ./kernel_conf.sh

DS_VERSION=replace_me

# disable ufw
service ufw stop
ufw disable

# updating docker
apt-get update
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
yes Y | apt-get install docker-ce -y
apt-get install docker-compose -y

# run document server
docker run -itd -p 80:80 --name 'droplet_starter' onlyoffice/4testing-documentserver-ee:$DS_VERSION
sleep 90 # timeout for running the document server
sudo docker exec droplet_starter sudo supervisorctl start ds:example
sudo docker exec droplet_starter sudo sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
