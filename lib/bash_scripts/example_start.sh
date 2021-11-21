#!/bin/bash

IP=167.99.118.255
docker_container=951875838d86

echo sudo docker exec "$docker_container" sudo supervisorctl start ds:example \
| ssh -o StrictHostKeyChecking=no root@"$IP"

echo sudo docker exec "$docker_container" sudo sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf \
| ssh -o StrictHostKeyChecking=no root@"$IP"
