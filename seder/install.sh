#!/usr/bin/env bash
set -euo pipefail

# Bootstrap for a fresh Ubuntu machine: the few packages needed to build
# luam, then luam and seder (cloned next to this repo), then
# `seder apply` with this directory's data. Every step checks before
# acting, so rerunning it is safe.
#
#   ./install.sh [machine] [seder apply options]    machine defaults to laptop
#
# PROJECTS (default ~/Projects) sets where luam and seder are cloned.

cd "$(dirname "$0")"

MACHINE="${1:-laptop}"
shift || true
PROJECTS="${PROJECTS:-$HOME/Projects}"
LUAM_DIR="$PROJECTS/luam"
SEDER_DIR="$PROJECTS/seder"

if [ ! -f "machines/$MACHINE.lua" ]; then
    echo "No machines/$MACHINE.lua. Available: $(ls machines | sed 's/\.lua$//' | tr '\n' ' ')" >&2
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

clone() {
    if [ ! -d "$2/.git" ]; then
        mkdir -p "$(dirname "$2")"
        git clone "$1" "$2"
    fi
}

clone https://github.com/BenSiv/luam.git "$LUAM_DIR"
clone https://github.com/BenSiv/seder.git "$SEDER_DIR"

if [ ! -f "$LUAM_DIR/obj/liblua.a" ] || [ ! -x "$LUAM_DIR/bin/luam" ]; then
    (cd "$LUAM_DIR" && bash bld/build_lang.sh)
fi
if [ ! -x "$SEDER_DIR/bin/seder" ]; then
    (cd "$SEDER_DIR" && LUAM_DIR="$LUAM_DIR" bash bld/build.sh)
fi

exec "$SEDER_DIR/bin/seder" apply "machines/$MACHINE.lua" "$@"
