#!/bin/bash
# Partition using parted. Results in:
# - 1023MB boot partition /dev/sda1
# - 1GB swap /dev/sda2
# - ~ 8GB root partition /dev/sda3
parted /dev/vda <<EOF
mklabel msdos
mkpart primary ext4 1MB 1024MB
mkpart primary linux-swap 1024MB 2048MB
mkpart primary ext4 2048MB 100%
quit
EOF

# Format
mkfs.ext4 /dev/vda1
mkfs.ext4 /dev/vda3
mkswap /dev/vda2
swapon /dev/vda2

# Replace the ISO's Mirrorlist
cp -f mirrorlist /etc/pacman.d/mirrorlist

# Download the script
wget https://raw.githubusercontent.com/Polynomdivision/system/master/arch_setup.sh

# And run it
chmod +x arch_setup.sh
./arch_setup.sh /dev/vda3 /dev/vda1 /dev/vda laptop <<EOF
y
alexander
EOF
