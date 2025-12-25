#!/bin/bash
set -e

echo "Building Bootable ISO..."
echo "This may take a while as it downloads/builds the system..."

# Check for dependencies
if ! command -v guile &> /dev/null; then
    echo "Guile not found. Rerunning in 'guix shell guile guile-wisp'..."
    exec guix shell guile guile-wisp guix -- bash "$0" "$@"
fi

# Make sure channels.scm and system.scm exist
make channels.scm system.scm

# Build the image and create a symlink to it
# We use --root to create a persistent GC root (symlink) named 'install-image.iso'
guix time-machine -C channels.scm -- system image --image-type=iso9660 --root=install-image.iso system.scm

echo "---------------------------------------------------"
echo "ISO created at: ./install-image.iso"
echo "---------------------------------------------------"
echo "To write to USB drive (replace /dev/sdX):"
echo "sudo dd if=./install-image.iso of=/dev/sdX status=progress && sync"
