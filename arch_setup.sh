# Asks the user to enter either yes or no
# exits 1 if no, 0 if yes
function confirm {
	echo -n "Are you sure? [y]es/[n]o: "
	answer=
	read answer
	
	if [[ $answer =~ ^[Yy]$ ]]; then
		return 0
	else
		# We just exit because here answer could be "n" or anything else than
		# "y"
		exit 1
	fi
}

if [ $# -ne 4 ]; then
	echo "Usage: ./arch_setup.sh <root part> <boot part> <boot drive> <install mode>"
	exit 1
fi

ROOT_PART=$1
BOOT_PART=$2
BOOT_DRIVE=$3
INSTALL_MODE=$4

if [ $INSTALL_MODE = "desktop" ] || [ $INSTALL_MODE = "netbook" ]; then
	# OK
	echo "" > /dev/null
else
	echo "Invalid installation mode: '$INSTALL_MODE'"
	echo "Known installation modes are: desktop, netbook"
	exit 1
fi

echo "=== SUMMARY ==="
echo "ROOT PARTITION: '$ROOT_PART'"
echo "BOOT PARTITION: '$BOOT_PART'"
echo "BOOT DRIVE    : '$BOOT_DRIVE'"
echo "INSTALLING AS : '$INSTALL_MODE'"
echo
confirm

alexander_PW=

echo -n "alexander's password: "
read -s alexander_PW
echo

# Mount everything
mount $ROOT_PART /mnt
mkdir -p /mnt/boot
mount $BOOT_PART /mnt/boot

# Install the base system
pacstrap -i /mnt base base-devel

# Update the fstab
echo "[ UPDATING FSTAB ]"
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the Ansible playbook to the new root directory
cp -r /run/archiso/bootmnt/Setup /mnt

# Dive into the chroot environment
cat << EOF | arch-chroot /mnt
hwclock --hctosys

echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf
echo "KEYMAP=de-latin1" > /etc/vconsole.conf
localectl set-x11-keymap de

pacman-key --init
pacman-key --populate
pacman -S --noconfirm grub os-prober intel-ucode vim

mkinitcpio -p linux
grub-install $BOOT_DRIVE
grub-mkconfig -o /boot/grub/grub.cfg

groupadd sudo
useradd alexander -G sudo
usermod --password $alexander_PW alexander
mkdir -p /home/alexander
chown alexander /home/alexander
chmod -R 700 /home/alexander

mkdir -p /home/alexander/Development/Misc
mv /Setup /home/alexander/Development/SysAdm/Setup
pacman -S --noconfirm ansible
ansible-playbook /home/alexander/Development/SysAdm/Setup/setup_$INSTALL_MODE.yml

exit
EOF

echo "Press 'ENTER' to reboot"
read

echo "Unmounting..."
unount -r /mnt
echo "Rebooting..."
reboot
