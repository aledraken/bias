#!/usr/bin/env bash

echo "${YELLOW}INSTALLING CHAOTIC_AUR$NC"
$CHROOT pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
$CHROOT pacman-key --lsign-key 3056513887B78AEB
$CHROOT pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo -e "\n[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >> /mnt/etc/pacman.conf

$CHROOT pacman -Syu --noconfirm
