#!/usr/bin/env bash

set -a

#NAME="ale"
#USER_PASS="1"
#ROOT_PASS="2"
#INSTALL_MODE="disk" # disk | part
#DISK="/dev/xxx"
#BOOT_PART="/dev/xxx" # Only needed with INSTALL_MODE="part"
#ROOT_PART="/dev/xxx" # ^
#DEVICE="vm" # desktop | laptop | vm
#VM="oracle" # leave empty or ignore | oracle
#BOOTLOADER="uki" # uki | systemd-boot
#GPU="NVIDIA" # NVIDIA | Intel | VMware | empty for no gpu stuff
#CPU="GenuineIntel" # GenuineIntel | empty for no cpu stuff
#UPDATE_MIRRORS=false # TODO
#CHAOTIC_AUR=false # TODO
#TRIM=false #
#UKI=false

# CLEAN-UP ARGUMENTS
# TODO move it somewhere else
#
#if [ ! -n "$NAME" ]; then
#	echo -e "${RED}Error: Empty USERNAME$NC" >&2
#	exit 1
#fi
#
#case "$INSTALL_MODE" in
#	"disk")
#		unset $ROOT_PART
#		unset $BOOT_PART
#
#		;;
#	"part")
#		if [ ! -n "$DISK" ]; then
#			DISK=$(lsblk -no pkname $BOOT_PART)
#			echo "DISK not defined, $DISK was selected"
#		fi
#		;;
#	*)
#		echo -e "${RED}Error: Invalid INSTALL_MODE: $INSTALL_MODE$NC" >&2
#		exit 1
#		;;
#esac

# DISK & FORMATTING


if [ "$INSTALL_MODE" == "disk" ]; then
	./$INSTALL/partition_disk.bash
fi

./$INSTALL/format_partitions.bash

mkdir -p /mnt/etc
echo "KEYMAP=us" > /mnt/etc/vconsole.conf

./$INSTALL/pacstrap_packages.bash

echo -e "${YELLOW}Setting up zram-generator$NC"
echo -e "[zram0]
compression-algorithm = zstd" > /mnt/etc/systemd/zram-generator.conf
echo -e "vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0" > /mnt/etc/sysctl.d/99-vm-zram-parameters.conf

if [ "$GPU" == "NVIDIA" ]; then
	echo -e "${YELLOW}Setting up mkinitcpio for NVIDIA$NC"
	sed -i '/MODULES=()/c\MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /mnt/etc/mkinitcpio.conf
	mkinitcpio -P
fi

./$INSTALL/environment_variables.bash


# FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

# PACMAN
sed -i '/#Color/c\Color\nILoveCandy' /mnt/etc/pacman.conf
sed -i '/#VerbosePkgLists/s/^#//g' /mnt/etc/pacman.conf

# HOSTNAME

echo "a-linux-$DEVICE" > /mnt/etc/hostname

# CHROOT

CHROOT="arch-chroot /mnt"

if [ "$VM" == "oracle" ]; then
	$CHROOT systemctl enable vboxservice
fi

# TRIM

if $TRIM; then
	$CHROOT systemctl enable fstrim.timer
fi

# NETWORK

./$INSTALL/networkmanager.bash



# TIME & ZONE

$CHROOT ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
$CHROOT hwclock --systohc
$CHROOT systemctl enable systemd-timesyncd

# LOCALES

# TODO Choose locales
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /mnt/etc/locale.gen
$CHROOT locale-gen

# CHAOTIC-AUR
if $CHAOTIC_AUR; then
	./$INSTALL/chaotic_aur.bash
fi

./$INSTALL/bootloader.bash

# SUDO
# Enable sudo for users in group wheel
echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/99_wheel
# Allows running programs like gufw and firewall-config in wayland
echo 'Defaults env_keep += "XDG_RUNTIME_DIR"
Defaults env_keep += "WAYLAND_DISPLAY"' > /mnt/etc/sudoers.d/wayland

# USERS
$CHROOT useradd -m "$NAME"
$CHROOT usermod -aG wheel "$NAME"

case "$DEVICE" in
	"vm")
		case "$VM" in
			"oracle")
				$CHROOT usermod -aG vboxsf "$NAME"
				mkdir -p /mnt/media
				$CHROOT chown -R $NAME:users /media
				;;
		esac
		;;
esac

echo "root:$ROOT_PASS" | chpasswd -R /mnt
echo "$NAME:$USER_PASS" | chpasswd -R /mnt
