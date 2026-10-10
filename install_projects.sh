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
if [ -d "$PROJECTS_DIR/external/manifold" ]; then
    MANIFOLD_DIR="$PROJECTS_DIR/external/manifold"
else
    MANIFOLD_DIR="$PROJECTS_DIR/manifold"
fi

if [ ! -d "$MANIFOLD_DIR" ]; then
    echo "Cloning manifold..."
    git clone --recursive https://github.com/elalish/manifold.git "$MANIFOLD_DIR"
fi

git -C "$MANIFOLD_DIR" submodule update --init --recursive

if [ ! -d "$MANIFOLD_DIR/build" ]; then
    echo "Building manifold..."
    cmake -S "$MANIFOLD_DIR" -B "$MANIFOLD_DIR/build" -DCMAKE_BUILD_TYPE=Release
    cmake --build "$MANIFOLD_DIR/build" -j"$(nproc)"
fi

# 1. Build luam
echo "Building luam..."
cd "$PROJECTS_DIR/luam"
bash bld/build_lang.sh
bash bld/build_libs.sh

# 2. Build brain-ex
echo "Building brain-ex..."
cd "$PROJECTS_DIR/brain-ex"
bash bld/build.sh

# 3. Build luametry
echo "Building luametry..."
cd "$PROJECTS_DIR/luametry"
export LUAM_DIR="$PROJECTS_DIR/luam"
export MANIFOLD_DIR="$MANIFOLD_DIR"
bash bld/build.sh

# 4. Build daat
if [ -d "$PROJECTS_DIR/daat" ]; then
    echo "Building daat..."
    cd "$PROJECTS_DIR/daat"
    export LUAM_DIR="$PROJECTS_DIR/luam"
    bash bld/build.sh
fi

# 5. Build camopass
if [ -d "$PROJECTS_DIR/camopass" ]; then
    echo "Building camopass..."
    cd "$PROJECTS_DIR/camopass"
    export LUAM_DIR="$PROJECTS_DIR/luam"
    bash bld/build.sh
fi

# 6. Install binaries
echo "Installing binaries to /usr/local/bin..."
rm -f /usr/local/bin/luam /usr/local/bin/luamc /usr/local/bin/brex /usr/local/bin/luametry /usr/local/bin/daat /usr/local/bin/camopass
cp "$PROJECTS_DIR/luam/bin/luam" /usr/local/bin/luam
[ -f "$PROJECTS_DIR/luam/bin/luamc" ] && cp "$PROJECTS_DIR/luam/bin/luamc" /usr/local/bin/luamc
cp "$PROJECTS_DIR/brain-ex/bin/brex" /usr/local/bin/brex
cp "$PROJECTS_DIR/luametry/bin/luametry" /usr/local/bin/luametry
[ -f "$PROJECTS_DIR/daat/bin/daat" ] && cp "$PROJECTS_DIR/daat/bin/daat" /usr/local/bin/daat
[ -f "$PROJECTS_DIR/camopass/bin/camopass" ] && cp "$PROJECTS_DIR/camopass/bin/camopass" /usr/local/bin/camopass

echo "Installation complete!"
