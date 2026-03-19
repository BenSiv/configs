#!/bin/bash
set -e

echo "Starting project installation..."

# Get absolute path to Projects directory (allow env override)
if [ -z "$PROJECTS_DIR" ]; then
    PROJECTS_DIR="$HOME/Projects"
fi
if [ ! -d "$PROJECTS_DIR" ]; then
    echo "Error: PROJECTS_DIR not found at $PROJECTS_DIR" >&2
    exit 1
fi

# 0. Ensure manifold dependency (needed for luametry)
if [ ! -d "$PROJECTS_DIR/manifold" ]; then
    echo "Cloning manifold..."
    git clone --recursive https://github.com/elalish/manifold.git "$PROJECTS_DIR/manifold"
fi

git -C "$PROJECTS_DIR/manifold" submodule update --init --recursive

if [ ! -d "$PROJECTS_DIR/manifold/build" ]; then
    echo "Building manifold..."
    cmake -S "$PROJECTS_DIR/manifold" -B "$PROJECTS_DIR/manifold/build" -DCMAKE_BUILD_TYPE=Release
    cmake --build "$PROJECTS_DIR/manifold/build" -j"$(nproc)"
fi

# 1. Build luam
echo "Building luam..."
cd "$PROJECTS_DIR/luam"
# Clean and build core
bash bld/build_lang.sh
# Build libraries (needed for other projects)
bash bld/build_libs.sh

# 2. Build brain-ex
echo "Building brain-ex..."
cd "$PROJECTS_DIR/brain-ex"
bash bld/build.sh

# 3. Build luametry
echo "Building luametry..."
cd "$PROJECTS_DIR/luametry"
export LUAM_DIR="$PROJECTS_DIR/luam"
export MANIFOLD_DIR="$PROJECTS_DIR/manifold"
bash bld/build.sh

# 4. Install binaries
echo "Installing binaries to /usr/local/bin..."
# Remove first to avoid "Text file busy" error when binary is running
rm -f /usr/local/bin/luam /usr/local/bin/brex /usr/local/bin/luametry
# Copy new binaries
cp "$PROJECTS_DIR/luam/bin/luam" /usr/local/bin/luam
cp "$PROJECTS_DIR/brain-ex/bin/brex" /usr/local/bin/brex
cp "$PROJECTS_DIR/luametry/bin/luametry" /usr/local/bin/luametry

echo "Installation complete!"
