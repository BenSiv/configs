#!/usr/bin/env bash
set -euo pipefail

# Bootstrap for a fresh Ubuntu machine: the few packages needed to build
# luam, then luam, then bin/machine, then `machine apply`. Every step
# checks before acting, so rerunning it is safe.
#
#   ./install.sh [host] [machine apply options]    host defaults to laptop
#
# PROJECTS (default ~/Projects) and LUAM_DIR (default $PROJECTS/luam)
# override where luam is cloned.

cd "$(dirname "$0")"

HOST="${1:-laptop}"
shift || true
PROJECTS="${PROJECTS:-$HOME/Projects}"
LUAM_DIR="${LUAM_DIR:-$PROJECTS/luam}"

if [ ! -f "hosts/$HOST.lua" ]; then
    echo "No hosts/$HOST.lua. Available: $(ls hosts | sed 's/\.lua$//' | tr '\n' ' ')" >&2
    exit 1
fi

missing=()
for pkg in git build-essential libreadline-dev; do
    if ! dpkg-query -W -f='${db:Status-Abbrev}' "$pkg" 2>/dev/null | grep -q '^ii'; then
        missing+=("$pkg")
    fi
done
if [ "${#missing[@]}" -gt 0 ]; then
    echo "Installing build prerequisites: ${missing[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
fi

if [ ! -d "$LUAM_DIR/.git" ]; then
    mkdir -p "$(dirname "$LUAM_DIR")"
    git clone https://github.com/BenSiv/luam.git "$LUAM_DIR"
fi
if [ ! -f "$LUAM_DIR/obj/liblua.a" ] || [ ! -x "$LUAM_DIR/bin/luam" ]; then
    (cd "$LUAM_DIR" && bash bld/build_lang.sh)
fi

LUAM_DIR="$LUAM_DIR" bash bld/build.sh
exec bin/machine apply "hosts/$HOST.lua" "$@"
