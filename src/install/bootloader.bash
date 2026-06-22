#!/usr/bin/env bash


case "$BOOTLOADER" in
	"uki")
		mkdir -p /mnt/etc/cmdline.d
		part_uuid=$(blkid -s PARTUUID -o value /dev/$ROOT_PART)
		echo "root=PARTUUID=$part_uuid rw" >> /mnt/etc/cmdline.d/root.conf

		sed -i '/^#default_uki/s/^#//' /mnt/etc/mkinitcpio.d/linux.preset
		sed -i '/^#default_options/s/^#//' /mnt/etc/mkinitcpio.d/linux.preset

		mkdir -p /mnt/efi/EFI/Linux
		$CHROOT mkinitcpio -p linux
		partition_number=$(cat "/sys/class/block/$BOOT_PART/partition")
		efibootmgr --create --disk /dev/$DISK --part $partition_number --label "A-Linux" --loader '\EFI\Linux\arch-linux.efi' --unicode
		;;

	"systemd-boot")
		#TODO

		if $UKI; then
			bootctl install --path /mnt/efi
			mkdir -p /mnt/etc/cmdline.d
			part_uuid=$(blkid -s PARTUUID -o value /dev/$ROOT_PART)
			echo "root=PARTUUID=$part_uuid rw" >> /mnt/etc/cmdline.d/root.conf

			sed -i '/^#default_uki/s/^#//' /mnt/etc/mkinitcpio.d/linux.preset
			sed -i '/^#default_options/s/^#//' /mnt/etc/mkinitcpio.d/linux.preset

			mkdir -p /mnt/efi/EFI/Linux
			$CHROOT mkinitcpio -p linux
			

			echo -e "default @saved
timeout 3
console-mode max" > /mnt/efi/loader/loader.conf

####################

		else
			bootctl install --path /mnt/boot
			echo -e "default @saved
timeout 3
console-mode max" > /mnt/boot/loader/loader.conf
			part_uuid=$(blkid -s PARTUUID -o value /dev/$ROOT_PART)
		
			echo -e "title A-Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=PARTUUID=$part_uuid" > /mnt/boot/loader/entries/arch.conf

			if [ "$DEVICE" != "vm" ]; then
				case "$CPU" in
					"GenuineIntel")
						sed -i '\|linux /vmlinuz-linux|a\initrd /intel-ucode.img' /mnt/boot/loader/entries/arch.conf
						;;
				esac
			fi
		fi
		;;
esac


