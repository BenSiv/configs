-- Core command-line tools and system settings.
return {
    apt = {
        present = {
            "curl", "wget", "git", "make", "build-essential", "cmake",
            "fd-find", "ripgrep", "jq", "tree", "micro", "sqlite3",
            "pandoc", "texlive-xetex", "pass", "gnupg", "locales",
            "libreadline-dev", "libsqlite3-dev", "podman", "keepassxc-full", "vlc",
            {name = "quarto",
             url = "https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.550/quarto-1.4.550-linux-amd64.deb"},
            {name = "google-chrome-stable",
             url = "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"},
        },
    },
    link = {
        present = {
            {path = "/usr/bin/fd", target = "/usr/bin/fdfind"},
        },
    },
    run = {
        present = {
            {name = "timezone ${timezone}",
             cmd = "timedatectl set-timezone ${timezone}",
             unless = "test \"$(timedatectl show -p Timezone --value)\" = ${timezone}",
             sudo = true},
            {name = "locale en_US.UTF-8",
             cmd = "locale-gen en_US.UTF-8",
             unless = "locale -a | grep -qix en_US.utf8",
             sudo = true},
        },
    },
}
