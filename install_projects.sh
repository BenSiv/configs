#!/bin/bash
set -e

echo "Starting project installation..."

# Get absolute path to Projects directory
PROJECTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Build luam
echo "Building luam..."
cd "$PROJECTS_DIR/luam"
# Clean and build core
bash bld/build_ansi.sh
# Build libraries (needed for other projects)
bash bld/build_libs.sh

# 2. Build brain-ex
echo "Building brain-ex..."
cd "$PROJECTS_DIR/brain-ex"
bash bld/build.sh

# 3. Build luametry
echo "Building luametry..."
cd "$PROJECTS_DIR/luametry"
bash bld/build.sh

# 4. Install binaries
echo "Installing binaries to /usr/local/bin..."
# Remove first to avoid "Text file busy" error when binary is running
sudo rm -f /usr/local/bin/luam /usr/local/bin/brex /usr/local/bin/luametry
# Copy new binaries
sudo cp "$PROJECTS_DIR/luam/bin/luam" /usr/local/bin/luam
sudo cp "$PROJECTS_DIR/brain-ex/bin/brex" /usr/local/bin/brex
sudo cp "$PROJECTS_DIR/luametry/bin/luametry" /usr/local/bin/luametry

echo "Installation complete!"