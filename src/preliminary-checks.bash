#!/usr/bin/env bash

# Check boot entries

boot_entries_count=$(efibootmgr | grep -Ec "Linux Boot Manager|A-Linux" || true)



if [ "$boot_entries_count" -gt 0 ]; then
	echo -e "${RED}Previous boot entries found!$NC"
	while (( $boot_entries_count > 0 )); do
		echo -e "$YELLOW$boot_entries_count entries remaining$NC"
		efibootmgr | tail -n 4

		read -p "Choose an entry: (xxxx) " entry_to_delete
		
		read -p "Are you sure? (y/N) " -n 1 reply
		echo
		if [[ "$reply" != [yY] ]]; then
			echo
			continue
		fi
		
		efibootmgr -b "$entry_to_delete" -B >/dev/null

		boot_entries_count=$(efibootmgr | grep -c "A-Linux" || true)

		echo
	done
	echo -e "${GREEN}All duplicate entries were deleted!$NC\n"
fi

####################
# Unmount /mnt
if mountpoint -q /mnt; then
	umount -R /mnt
fi

####################
# Check internet connection
if ! ping -c 1 9.9.9.9 > /dev/null; then
	systemctl start iwd
	while true; do
		iwctl 

		if ping -c 1 9.9.9.9 > /dev/null; then
			break
		fi
	done
fi


