# NixOS Development Environment

This directory contains configuration to reproduce the minimal development environment using NixOS.

## Prerequisites

- [NixOS Minimal ISO](https://nixos.org/download.html) flashed to a USB drive.
- A target machine with internet access.

## Installation

1.  **Boot into the NixOS Installer**
    Boot the target machine from the USB drive.

2.  **Partition and Mount**
    You must manually partition your disks and mount them to `/mnt`.
    The installer expects:
    - Root partition mounted at `/mnt`
    - Boot/EFI partition mounted at `/mnt/boot` (or `/mnt/boot/efi` depending on preference, script detects `/mnt`)

    Example manual setup:
    ```bash
    # Assuming nvme0n1 is your drive
    parted /dev/nvme0n1 -- mklabel gpt
    parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
    parted /dev/nvme0n1 -- set 1 esp on
    parted /dev/nvme0n1 -- mkpart primary 512MB 100%

    mkfs.fat -F 32 -n boot /dev/nvme0n1p1
    mkfs.ext4 -L nixos /dev/nvme0n1p2

    mount /dev/disk/by-label/nixos /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
    ```

3.  **Run the Installer**
    Clone this repository or copy this directory to the live environment.
    
    ```bash
    cd configs/nix
    chmod +x install.sh
    sudo ./install.sh
    ```

4.  **Post-Install**
    - Reboot
    - Login as `bensiv` (password: `1234`)
    - Change your password immediately!

## Contents

- `flake.nix`: The entry point for the system configuration.
- `configuration.nix`: Main system configuration (bootloader, networking, users).
- `home.nix`: Home Manager configuration (user packages: git, micro, etc.).
- `install.sh`: Automated wrapper to install the system.
