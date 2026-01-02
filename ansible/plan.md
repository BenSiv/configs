# Ansible Migration Plan

## Goal Description
Migrate the existing NixOS/Home Manager configuration to an Ansible-based setup for Ubuntu, and provide an automated ISO builder.

## Strategy Change: Manual Install + Configuration Script
The user has opted for a robust, manual installation of the standard Ubuntu Desktop ISO, followed by executing our Ansible automation script (`install.sh`) to configure the environment.

### The "Golden Path"
1.  **Install OS**: User installs Ubuntu 24.04 Desktop manually.
2.  **Bootstrap**: User pulls this repo and runs `./install.sh`.
3.  **Configure**: Script installs Ansible, runs playbook, and sets up the machine.

### `configs/ansible` Structure
-   `install.sh`: Entry point. Installs Ansible if missing, then runs `ansible-playbook`.
-   `site.yml`: The main playbook.
-   `roles/`: Contains all logic (`common`, `gnome`, `development`, `user`).

### Experimental / Legacy
-   `iso-builder/`: Contains the work for the automated ISO and CIDATA methods. This is preserved for future reference but is no longer the primary path.
