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

if [ $INSTALL_MODE = "desktop" ] || [ $INSTALL_MODE = "netbook" ] || [ $INSTALL_MODE = "laptop" ] || [ $INSTALL_MODE = "vm" ]; then
	# OK
	echo "" > /dev/null
else
	echo "Invalid installation mode: '$INSTALL_MODE'"
	echo "Known installation modes are: desktop, netbook"
	exit 1
fi

VM_HOST_NR=0
if [ $INSTALL_MODE = "vm" ]; then
	echo "Enter a number for the VM (Ex. 0 for 'isla-vm0' or 1 for 'isla-vm1')"
	echo -n "> "
	read VM_HOST_NR
fi

echo "=== SUMMARY ==="
echo "ROOT PARTITION: '$ROOT_PART'"
echo "BOOT PARTITION: '$BOOT_PART'"
echo "BOOT DRIVE    : '$BOOT_DRIVE'"
echo "INSTALLING AS : '$INSTALL_MODE'"
if [ $INSTALL_MODE = "vm" ]; then
	echo "VM NUMBER	    : '$VM_HOST_NR'"
fi
echo 
confirm


# Ask for a password and compute the hash
echo "Enter a password for alexander"
HASH=$(python2 -c 'import crypt,uuid,getpass; pw1 = getpass.getpass(); pw2 = getpass.getpass(prompt="Re-enter password: "); print(crypt.crypt(pw1, "$6$%s$" % uuid.uuid4().hex) if pw1 == pw2 else "PASSWORDS DONT MATCH")')

if [ "$HASH" = "PASSWORDS DONT MATCH" ]; then
	echo "ERROR: Passwords don't match"
	exit 1
fi

# Mount everything
mount $ROOT_PART /mnt
mkdir -p /mnt/boot
mount $BOOT_PART /mnt/boot

# Install the base system
pacstrap -i /mnt base base-devel

# Update the fstab
echo "[ UPDATING FSTAB ]"
genfstab -U /mnt >> /mnt/etc/fstab

# Dive into the chroot environment
cat << EOF | arch-chroot /mnt
hwclock --hctosys

echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=de-latin1" > /etc/vconsole.conf

pacman-key --init
pacman-key --populate
pacman -S --noconfirm grub os-prober intel-ucode vim sudo

mkinitcpio -p linux
grub-install $BOOT_DRIVE
grub-mkconfig -o /boot/grub/grub.cfg

mkdir -p /home/alexander/Development/SysAdm/
pacman -S --noconfirm ansible git
git clone https://github.com/Polynomdivision/system.git /home/alexander/Development/SysAdm/System
ansible-playbook /home/alexander/Development/SysAdm/System/system_$INSTALL_MODE.yml --extra-vars 'hash=$HASH vm_number=$VM_HOST_NR' | tee -a /root/deploy_log

exit
EOF

echo "==============================================="
echo -n "\n\n\nWAITING 15 SECONDS BEFORE REBOOTING\n\n\n"
echo "==============================================="
sleep 15
umount -R /mnt
reboot
