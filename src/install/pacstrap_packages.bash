#!/usr/bin/env bash

packages="sudo zram-generator neovim networkmanager"

if [ "$DEVICE" == "vm" ]; then
	case "$VM" in
		"oracle")
			drivers="$drivers linux-headers virtualbox-guest-utils"
			;;
	esac
else
	echo "WWHY"
	exit 1
	drivers="linux-firmware"
	
	case "$CPU" in
		"GenuineIntel")
			drivers="$drivers intel-ucode"
			;;
	esac
	
	case "$GPU" in
		"NVIDIA")
			drivers="$drivers nvidia-open nvidia-settings libva-nvidia-driver"
			;;
		"Intel")
			drivers="$drivers mesa vulkan-intel intel-media-driver libvpl vpl-gpu-rt"
			;;
	esac
fi

########################################

echo -e "${YELLOW}Installing base packages$NC"
pacstrap -K /mnt base linux

echo -e "${YELLOW}Installing other packages$NC"
pacstrap /mnt $packages

echo -e "${YELLOW}Installing drivers$NC"
pacstrap /mnt $drivers
