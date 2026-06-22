#!/usr/bin/env bash


$CHROOT systemctl enable NetworkManager
$CHROOT systemctl enable systemd-resolved

ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

# TODO Choose dns
DNS="9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net"

sed -i "/#DNS=/c\DNS=$DNS" /mnt/etc/systemd/resolved.conf
sed -i '/#DNSSEC=no/c\DNSSEC=yes' /mnt/etc/systemd/resolved.conf
sed -i '/#DNSOverTLS=no/c\DNSOverTLS=yes' /mnt/etc/systemd/resolved.conf
