#!/bin/bash

if [ ! -f "/data/.initialized" ]; then
    cp -r /root/configs/micro /root/.config/

    cat /root/configs/bash/bashrc.sh >> /root/.bashrc

    # Build and install luam
    echo "Compiling luam..."
    cd /root/luam
    bash bld/build_lang.sh
    cp bin/luam /usr/local/bin/
    cp bin/luamc /usr/local/bin/
    chmod +x /usr/local/bin/luam /usr/local/bin/luamc
    echo "luam installed to /usr/local/bin"

    my_bash_aliases='
    alias readdir="ls --format=single-column --almost-all --group-directories-first"
    alias rd="luam /root/automations/src/readdir.lua"
    alias edit="luam /root/automations/src/edit.lua"
    alias find="luam /root/automations/src/find.lua"
    alias repo="luam /root/automations/src/repo.lua"
    alias sqlite=sqlite3
    '
    echo "$my_bash_aliases" > ~/.bash_aliases

    source /root/.bashrc

    source /root/lua-utils/install_requirements.sh

    # Run clipboard sync: when primary clipboard changes, copy it to regular clipboard
    wl-paste --primary --watch sh -c 'wl-paste --primary | wl-copy' >/dev/null 2>&1 &

    # Compile and install brain-ex
    echo "Compiling brain-ex..."
    bash /root/brain-ex/install_requirements.sh
    bash /root/brain-ex/build.sh
    cp /root/brain-ex/bld/brex /usr/local/bin/
    chmod +x /usr/local/bin/brex
    echo "brain-ex installed to /usr/local/bin"

    echo "Moving home"
    cd /root

    # Mark as initialized
    mkdir -p /data
    touch /data/.initialized
    echo "All set!"
fi

# Run the specified command or default to starting a shell
exec "${@:-bash}"
