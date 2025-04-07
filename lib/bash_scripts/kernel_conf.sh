#/bin/bash

# how aggressively the Linux kernel swaps memory pages from RAM to disk (swap space)
sysctl vm.swappiness=10
# The Sysctl vm.vfs_cache_pressure = 50 team changes the Linux nucleus parameter,
# which controls how the system releases the cache for dentries (Directory Entries)
# and Inodes., The Sysctl vm.vfs_cache_pressure = 50 team changes the Linux nucleus
# parameter, which controls how the system frees the cache for dentries (Directory Entries) and Inodes.
sysctl vm.vfs_cache_pressure=50
# disable lazy memoty allocation
sudo sysctl vm.overcommit_memory=2

