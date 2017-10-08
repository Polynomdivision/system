# OpenSuse
## Installation
1. Install using ```Custom``` and install only ```AppArmor```, ```x64 Runtime``` and ```Console Tools```
2. Enable the Firewall

## Post-Instllation
1. Install ```git``` and ```ansible```
2. Clone the repository
3. Run the playbook

The Playbook requires the following variables to be set:
- ```username```: The username, duh.

The Playbook will also need to elevate privileges in order to install packages or configuration files
