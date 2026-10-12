-- Desktop: GNOME tools, desktop apps, and the stock apps we don't use.
-- Not ported yet (still in ansible/roles/gnome_user): GNOME extensions,
-- dconf settings and the wallpaper.
return {
    apt = {
        present = {
            "ubuntu-desktop-minimal", "gnome-tweaks", "dconf-cli", "pipx",
            "gnome-shell-extension-manager", "gimp",
        },
        absent = {
            "aisleriot", "gnome-mahjongg", "gnome-mines", "gnome-sudoku", "firefox",
            "libreoffice-core", "libreoffice-common", "libreoffice-calc",
            "libreoffice-draw", "libreoffice-gnome", "libreoffice-gtk3",
            "libreoffice-impress", "libreoffice-math", "libreoffice-writer",
            "rhythmbox", "shotwell", "thunderbird", "transmission-common",
            "transmission-gtk", "remmina",
        },
    },
    snap = {
        present = {
            {name = "android-studio", classic = true},
            {name = "zen-browser-snap", channel = "candidate"},
            "onlyoffice-desktopeditors", "paint", "whatsapp-linux-app",
        },
        -- gimp comes from apt instead; code is replaced by Antigravity.
        absent = {"gimp", "firefox", "code"},
    },
    path = {
        present = {"~/.local/bin", "~/Pictures"},
    },
    run = {
        present = {
            {name = "gnome-extensions-cli",
             cmd = "pipx install gnome-extensions-cli",
             creates = "~/.local/bin/gnome-extensions-cli"},
        },
    },
}
