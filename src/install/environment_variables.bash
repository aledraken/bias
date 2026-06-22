#!/usr/bin/env bash

echo "ELECTRON_OZONE_PLATFORM_HINT=auto" >> /mnt/etc/environment

####################

if [ "$DEVICE" == "vm" ]; then
	echo "WLR_NO_HARDWARE_CURSORS=1" >> /mnt/etc/environment
else
	case "$GPU" in
		"NVIDIA")
			echo -e "LIBVA_DRIVER_NAME=nvidia\n__GLX_VENDOR_LIBRARY_NAME=nvidia\nNVD_BACKEND=direct\nVDPAU_DRIVER=nvidia" >> /mnt/etc/environment
			;;
		"Intel")
			echo -e "LIBVA_DRIVER_NAME=iHD\nANV_DEBUG=video-decode,video-encode" >> /mnt/etc/environment
			;;
	esac
fi


