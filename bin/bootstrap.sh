#!/bin/sh

set -eux

# Set the keyboard layout
loadkeys jp106

# Verify the boot mode
if [ -e /sys/firmware/efi/efivars ]; then
  echo "ERROR: /sys/firmware/efi/efivars exists." 1>&2
  exit 1
fi

# Connect to the internet
ping -c 1 archlinux.org

# Update the system clock
timedatectl set-ntp true

# Partition the disks
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
  +512M # 512 MB boot parttion
  t

  82 # swap
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  t

  83 # linux
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

# Format the partitions
mkfs.ext4 /dev/sda2
mkswap /dev/sda1

# Mount the file systems
mount /dev/sda2 /mnt
swapon /dev/sda1

# Install essential packages
pacstrap /mnt base linux linux-firmware

# Configure the system

## Fstab
genfstab -U /mnt >>/mnt/etc/fstab
