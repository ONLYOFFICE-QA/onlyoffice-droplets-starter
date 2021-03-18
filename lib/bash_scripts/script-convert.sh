#!/bin/bash

S3_KEY=$(cat ~/.s3/key)
S3_PRIVATE_KEY=$(cat ~/.s3/private_key)
PALLADIUM_TOKEN=$(cat ~/.palladium/token)
SERVER_VERSION='onlyoffice/4testing-documentserver-ee:6.3.0.19'

# Add swap
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# clone project
git clone https://github.com/ONLYOFFICE-QA/convert-service-testing.git
cd ./convert-service-testing

sed -i '4s!""!"'$S3_KEY'"!' Dockerfile
sed -i '5s!""!"'$S3_PRIVATE_KEY'"!' Dockerfile
sed -i '6s!""!"'$PALLADIUM_TOKEN'"!' Dockerfile

sed -i 's!onlyoffice/4testing-documentserver-ie:latest!"'$SERVER_VERSION'"!' \
        docker-compose.yml

# build start
docker-compose up -d
