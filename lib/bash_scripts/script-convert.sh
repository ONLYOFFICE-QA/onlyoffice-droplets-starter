#!/bin/bash

SERVER_VERSION="onlyoffice/4testing-documentserver-de:latest"

# clone project
git clone https://github.com/ONLYOFFICE-QA/convert-service-testing.git
cd ./convert-service-testing

sed -i 's,onlyoffice/4testing-documentserver-ie:latest,"'$SERVER_VERSION'",' \
        docker-compose.yml

# build start
docker-compose up -d

exit 1
