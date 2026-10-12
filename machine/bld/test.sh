#!/usr/bin/env bash
set -euo pipefail

# Builds bin/machine and runs the bats suite against it.

cd "$(dirname "$0")/.."
bash bld/build.sh
bats tst
