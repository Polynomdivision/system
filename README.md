System - My dotfiles using Ansible
===
Why? I can't write bash scripts that **actually** work.

## Structure
- system_desktop.yml: Dotfiles, packages and settings for my desktop linux (Arch Linux)
  - Hostname: miku
- system_netbook.yml: Dotfiles, packages and settings for my netbook linux (Arch Linux)
  - Hostname: mikasa
- system_laptop.yml: Dotfiles, packages and settings for my laptop linux (Arch Linux)
  - Hostname: nishimiya
- system_vm.yml: Dotfiles, packages and settings for my VMs (Arch Linux)
  - Hostname: isla-vmX
  - Yes, because Isla is a Giftia, I call all of my VMs after her
- arch_setup.sh: A script which installes Arch Linux and uses one of the playbooks above

The scripts folder contains small applications that I use to develop these playbooks.
## Setup
**DON'T** use the installation script. I take no responsibility if anyone actually uses this script.
