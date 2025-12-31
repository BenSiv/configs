#!/bin/bash
set -e

# Configuration
UBUNTU_ISO="ubuntu-24.04.3-live-server-amd64.iso"
ISO_URL="https://releases.ubuntu.com/24.04/ubuntu-24.04.3-live-server-amd64.iso"
WORK_DIR="iso_work"
OUTPUT_ISO="custom-ubuntu-ansible.iso"

# Dependencies check
command -v xorriso >/dev/null 2>&1 || { echo >&2 "xorriso is required."; exit 1; }
command -v 7z >/dev/null 2>&1 || { echo >&2 "7z (p7zip) is required."; exit 1; }

# Download ISO if not present
if [ ! -f "$UBUNTU_ISO" ]; then
    echo "ISO not found. Downloading..."
    wget -O "$UBUNTU_ISO" "$ISO_URL"
fi

# Clean previous build
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Extract ISO
echo "Extracting ISO..."
7z x "$UBUNTU_ISO" -o"$WORK_DIR" -y > /dev/null

# Remove integrity check (since we are modifying content)
rm -f "$WORK_DIR/md5sum.txt"

# Prepare ncloud directory
mkdir -p "$WORK_DIR/ncloud"
cp user-data "$WORK_DIR/ncloud/user-data"
touch "$WORK_DIR/ncloud/meta-data" # Empty meta-data is fine

# Inject Ansible configuration
echo "Injecting Ansible..."
mkdir -p "$WORK_DIR/ansible"
cp -r ../roles ../site.yml ../inventory ../ansible.cfg ../install.sh "$WORK_DIR/ansible/"

# Patch GRUB to enable Autoinstall
echo "Patching GRUB..."
# This sed is specific to standard Ubuntu 20.04+ layout.
# We append 'autoinstall ds=nocloud;s=/cdrom/ncloud/' to the linux command line.
sed -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/ncloud/ ---|g' "$WORK_DIR/boot/grub/grub.cfg"

# Repack ISO
echo "Building new ISO..."
cd "$WORK_DIR"
xorriso -as mkisofs -r \
  -V 'Ubuntu-Server 24.04.3 LTS amd64' \
  -o "../$OUTPUT_ISO" \
  --grub2-mbr "--interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:../$UBUNTU_ISO" \
  --protective-msdos-label \
  -partition_cyl_align off \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "--interval:local_fs:6441216d-6451375d::../$UBUNTU_ISO" \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2_start_1610304s_size_10160d:all::' \
    -no-emul-boot \
  . 

echo "Done! ISO available at $OUTPUT_ISO"
