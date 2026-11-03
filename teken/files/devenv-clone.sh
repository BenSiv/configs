#!/bin/sh
# Clones every devenv repo that is missing from /root/projects, the
# devenv-projects volume. Never touches a checkout that exists, so it is
# safe to rerun; work on the volume survives every image rebuild.
# Private repos ask for credentials once (gitconfig stores them).
set -u
P="${PROJECTS:-/root/projects}"
mkdir -p "$P" "$P/external"
clone() {
    if [ -e "$P/$2" ]; then
        echo "have   $2"
    else
        echo "clone  $2"
        git clone --quiet "$1" "$P/$2" || echo "FAILED $2" >&2
    fi
}
clone https://github.com/BenSiv/configs.git configs
clone https://github.com/BenSiv/luam.git luam
clone https://github.com/BenSiv/luametry.git luametry
clone https://github.com/BenSiv/automations.git automations
clone https://github.com/BenSiv/brain-ex.git brain-ex
clone https://github.com/BenSiv/daat.git daat
clone https://github.com/BenSiv/py-utils.git py-utils
clone https://github.com/celleste-bio/software.git software
clone https://github.com/celleste-bio/lims.git lims
clone https://github.com/celleste-bio/wiki-pages.git wiki-pages
clone https://github.com/celleste-bio/cvs-flask-holder.git cvs-flask-holder
clone https://github.com/celleste-bio/benchling-api-utils.git benchling-api-utils
