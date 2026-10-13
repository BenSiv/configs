-- What only Ubuntu needs: its desktop metapackage, apps from snaps, and
-- settings for Ubuntu's own dock and desktop-icons extensions. Used by
-- machines/laptop-ubuntu.lua until the laptop moves to Debian.
return {
    apt = {
        present = {"ubuntu-desktop-minimal"},
        -- Ubuntu's firefox package only installs the snap.
        absent = {"firefox"},
    },
    snap = {
        present = {
            {name = "antigravity-ide-snap", classic = true},
            {name = "android-studio", classic = true},
            {name = "zen-browser-snap", channel = "candidate"},
            "onlyoffice-desktopeditors", "paint", "whatsapp-linux-app",
        },
        -- gimp comes from apt instead; code is replaced by Antigravity.
        absent = {"gimp", "firefox", "code"},
    },
    -- Blur my Shell from extensions.gnome.org (Debian packages it instead).
    run = {
        present = {
            {name = "extension blur-my-shell@aunetx",
             cmd = "~/.local/bin/gnome-extensions-cli install blur-my-shell@aunetx",
             creates = "~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx",
             env = {DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${uid}/bus"}},
        },
    },
    dconf = {
        present = {
            {key = "/org/gnome/shell/extensions/dash-to-dock/dock-position",
             value = "'BOTTOM'"},
            {key = "/org/gnome/shell/extensions/dash-to-dock/extend-height",
             value = "false"},
            {key = "/org/gnome/shell/extensions/dash-to-dock/dock-fixed",
             value = "false"},
            {key = "/org/gnome/shell/extensions/dash-to-dock/show-trash",
             value = "false"},
            {key = "/org/gnome/shell/extensions/ding/show-home",
             value = "false"},
            -- The app grid, with Ubuntu's snap app IDs.
            {key = "/org/gnome/shell/app-picker-layout",
             value = "[{'org.gnome.Ptyxis.desktop': <{'position': <0>}>, 'google-chrome.desktop': <{'position': <1>}>, 'zen-browser-snap_zen-browser.desktop': <{'position': <2>}>, 'antigravity.desktop': <{'position': <3>}>, 'micro.desktop': <{'position': <4>}>, 'whatsapp-linux-app_whatsapp-linux-app.desktop': <{'position': <5>}>, 'onlyoffice-desktopeditors_onlyoffice-desktopeditors.desktop': <{'position': <6>}>, 'org.gnome.Nautilus.desktop': <{'position': <7>}>, 'snap-store_snap-store.desktop': <{'position': <8>}>}, {'System': <{'position': <0>}>, 'Utilities': <{'position': <1>}>, 'org.gimp.GIMP.desktop': <{'position': <2>}>, 'vlc.desktop': <{'position': <3>}>, 'org.keepassxc.KeePassXC.desktop': <{'position': <4>}>, 'android-studio_android-studio.desktop': <{'position': <5>}>}]"},
        },
    },
}
