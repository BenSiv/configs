# Ansible Deployment Walkthrough

I have generated a complete Ansible configuration to replicate your NixOS setup on a fresh Ubuntu machine.

## Prerequisites
1.  **Install Ubuntu**: Install the latest Ubuntu (non-LTS as requested) on your machine.
2.  **Git**: Ensure `git` is installed (`sudo apt install git`).
3.  **Clone Repo**: Clone this repository to your new machine (or copy the `ansible` folder).

## Directory Structure
The configuration is located in `configs/ansible`:
- `site.yml`: Main playbook.
- `inventory`: Localhost inventory.
- `install.sh`: One-click installation script.
- `roles/`: Contains `common`, `development`, `user`, and `gnome` configurations.

## How to Run (Recommended)
1.  **Install Ubuntu**: Install standard **Ubuntu 24.04 Desktop** manually from a fresh USB stick.
2.  **Clone Repo**:
    ```bash
    git clone https://github.com/BenSiv/configs.git
    cd configs/ansible
    ```
3.  **Run Installer**:
    ```bash
    ./install.sh
    ```

This is the most reliable method.

## Optional: Custom ISO (Experimental)
You can build a fully automated Ubuntu installer, but this is experimental:
-   **System**: Sets timezone, locale, installs basic tools (`curl`, `git`, `micro`, `fd`, `ripgrep`, `sqlite3`, `pandoc`, `xelatex`, `google-chrome`).
-   **Cleanup**: Removes default apps (LibreOffice, Thunderbird, Games, etc.).
-   **Dev**: Installs `lua5.1`, `gcc`, `antigravity` (Google IDE).
-   **User**: Configures Git, creates `.bash_aliases`, `.config/micro`, and clones your projects to `~/Projects`.
-   **GNOME**: Sets dark mode, wallpaper, clock format, and keybindings.

## Next Steps
-   **Commit & Push**: Commit these files to your repository so you can access them on the new machine.

## Optional: Automated USB (CIDATA Method)
To create a fully automated USB drive (without modifying the ISO):
1.  **Flash Standard ISO**: Write `ubuntu-24.04.3-live-server-amd64.iso` to your USB (`/dev/sda`).
2.  **Create Partition**: Create a new FAT32 partition labeled `CIDATA` in the remaining space.
3.  **Copy Configs**: Copy `ansible/`, `user-data`, and `meta-data` to the root of the `CIDATA` partition.
4.  **Boot**: Insert USB and boot. Ubuntu will automatically find the configs and install.

**Notes**:
*   **User**: `bensiv`
*   **Password**: `1234`
*   **Network**: Connect Ethernet for full automated setup. If offline, it installs basic Ubuntu; run `./install.sh` manualy after connecting to WiFi.
