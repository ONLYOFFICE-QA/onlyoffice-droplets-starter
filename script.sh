#!/bin/bash
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50
sudo swapon --show
ufw disable
docker run -itd -p 80:80 onlyoffice/4testing-documentserver-ie
