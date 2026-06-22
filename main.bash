#!/usr/bin/env bash

set -a

set -e

DIR=$(dirname $0)
SRC="$DIR/src"
INSTALL="$SRC/install"
source $SRC/colors.bash

####################
#INSTALL ARGS

NAME="ale"
USER_PASS="1"
ROOT_PASS="1"
INSTALL_MODE="disk" # disk | part
DISK="sda"
BOOT_PART="sda1" # Only needed with INSTALL_MODE="part"
ROOT_PART="sda2" # ^
DEVICE="vm" # desktop | laptop | vm
VM="oracle" # leave empty or ignore | oracle
BOOTLOADER="systemd-boot" # uki | systemd-boot
GPU="VMware" # NVIDIA | Intel | VMware | empty for no gpu stuff
CPU="GenuineIntel" # GenuineIntel | empty for no cpu stuff
UPDATE_MIRRORS=false # Reflector
COUNTRIES="Italy,Germany,France,Albania,Spain,Switzerland,Austria"
CHAOTIC_AUR=true
TRIM=false #
UKI=true # To use with BOOTLOADER=systemd-boot

####################

#TODO check if args are correct with another script, if they aren't quit everything else keep going
# also try and fix them etc... or tell another script which args need fixing


if $UPDATE_MIRRORS; then
	./$SRC/reflector.bash $DIR/countries
fi

./$SRC/preliminary-checks.bash

./$SRC/install.bash > /dev/null
