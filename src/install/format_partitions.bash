#!/usr/bin/env bash

mkfs.ext4 -F -L ROOT /dev/$ROOT_PART
mount /dev/$ROOT_PART /mnt


if $UKI || [ $BOOTLOADER == "uki" ]; then
	mkfs.fat -F 32 -n ESP /dev/$BOOT_PART
	mount --mkdir /dev/$BOOT_PART /mnt/efi
elif [ "$BOOTLOADER" == "systemd-boot" ]; then
	mkfs.fat -F 32 -n BOOT /dev/$BOOT_PART
	mount --mkdir /dev/$BOOT_PART /mnt/boot
fi
