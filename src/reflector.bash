#!/usr/bin/env bash


reflector --country $COUNTRIES --sort rate --latest 10 --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist
