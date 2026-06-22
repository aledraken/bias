#!/usr/bin/env bash


sgdisk -I --zap-all /dev/$DISK
sgdisk -I -n 1:0:+1G -t 1:ef00 /dev/$DISK
sgdisk -I -n 2:0:0 -t 2:8300 /dev/$DISK

mapfile partitions < <(lsblk -lno NAME /dev/$DISK)

BOOT_PART=${partitions[1]}
BOOT_PART=$(echo $BOOT_PART | xargs)
		
ROOT_PART=${partitions[2]}
ROOT_PART=$(echo $ROOT_PART | xargs)

