System - My dotfiles using Ansible
===
Why? I can't write bash scripts that **actually** work.

## Structure
- system.yml: The main playbook. The config is the same across all devices. Subtle things are controlled using the inventory
    - Desktop:
        - Use mesa with nouveau
        - Hostname: ```mitsuha``` (Kimi no Na wa)
        - Use ```intel-ucode```
    - Laptop:
        - Use mesa without anything special
        - Hostname: ```nishimiya``` (Koe no Katachi)
        - Use ```intel-ucode```
- ```scripts/```: Some helpful scripts
- ```test/```: Configuration for packer to build a VM using this repo
- arch_setup.sh: A script which installes Arch Linux and uses one of the playbooks above

The scripts folder contains small applications that I use to develop these playbooks.
## Setup
**DON'T** use the installation script. I take no responsibility if anyone actually uses this script.

1. Boot into the Arch ISO
2. Partition
3. ```wget https://raw.githubusercontent.com/Polynomdivision/system/master/arch_setup.sh```
4. ```chmod +x arch_setup.sh```. It is a tmpfs. No need to watch out; +x is fine
5. ```./arch_setup.sh <root part.> <boot part.> <boot dev.> <install mode>```
    - ```<root part.>```: The root partition, e.g. ```/dev/vda3```
    - ```<boot part.>```: The boot partition, e.g. ```/dev/vda1```
    - ```<boot dev.>```: The boot device, e.g. ```/dev/vda```
    - ```<install mode>```: Either ```desktop``` or ```laptop```

## Notes
The packer configuration is taken from [elasticdog/packer-arch](https://github.com/elasticdog/packer-arch) and
modified by me.
