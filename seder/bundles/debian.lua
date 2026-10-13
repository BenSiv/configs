-- What only Debian needs: its GNOME desktop, apps from Flathub (sandboxed)
-- where Ubuntu used snaps, and cleanup of Debian's GNOME defaults.
--
-- gnome-core is declared so the desktop stays wanted when the bloatware
-- removal in gnome.lua takes the full `gnome` metapackage with it (it
-- depends on LibreOffice and Shotwell); gnome-core only recommends a
-- browser, so Firefox ESR can go. Removing the `gnome` metapackage
-- orphans what it held, so the parts worth keeping are declared below
-- (a later apt autoremove would take them otherwise).
--
-- Apps gnome-core strictly requires can't be uninstalled without it, so
-- the unwanted ones are hidden instead: a user-level .desktop override
-- with Hidden=true (../gnome/hidden.desktop) removes an app from the grid,
-- search and "open with".

-- A Flathub app, adding the Flathub remote first on a fresh install.
function flathub(id)
    return {name = id, remote = "flathub", remote_url = "https://dl.flathub.org/repo/flathub.flatpakrepo"}
end

-- Hides the app with this desktop ID.
function hide(id)
    return {path = "~/.local/share/applications/" .. id, target = "${configs}/gnome/hidden.desktop"}
end

return {
    apt = {
        present = {
            "gnome-core", "flatpak",
            -- Held by the `gnome` metapackage, which the cleanup removes.
            "network-manager", "gstreamer1.0-libav", "gstreamer1.0-plugins-ugly",
        },
        absent = {
            "firefox-esr",
            "evolution", "evolution-plugins", "evolution-ews",
            "evolution-plugin-bogofilter", "evolution-plugin-pstimport",
            "gnome-music", "gnome-sound-recorder", "gnome-tour",
            -- Services that share this machine on the network.
            "rygel", "rygel-playbin", "rygel-tracker", "gnome-user-share",
            "gnome-remote-desktop",
            -- LibreOffice data left behind (LibreOffice itself is in gnome.lua).
            "libreoffice-help-en-us", "hyphen-en-us", "mythes-en-us",
        },
    },
    link = {
        present = {
            hide("org.gnome.Calendar.desktop"),
            hide("org.gnome.Contacts.desktop"),
            hide("org.gnome.Maps.desktop"),
            hide("org.gnome.Weather.desktop"),
            hide("org.gnome.Totem.desktop"),      -- VLC instead
            hide("org.gnome.Snapshot.desktop"),
            hide("simple-scan.desktop"),
            hide("org.gnome.Tecla.desktop"),
        },
    },
    flatpak = {
        present = {
            flathub("com.google.AndroidStudio"),
            flathub("app.zen_browser.zen"),
            flathub("org.onlyoffice.desktopeditors"),
            flathub("com.github.PintaProject.Pinta"),   -- for the Ubuntu "paint" snap
            flathub("com.rtosta.zapzap"),               -- WhatsApp
        },
    },
    dconf = {
        present = {
            -- The app grid, with the Flatpak app IDs.
            {key = "/org/gnome/shell/app-picker-layout",
             value = "[{'org.gnome.Ptyxis.desktop': <{'position': <0>}>, 'google-chrome.desktop': <{'position': <1>}>, 'app.zen_browser.zen.desktop': <{'position': <2>}>, 'micro.desktop': <{'position': <3>}>, 'com.rtosta.zapzap.desktop': <{'position': <4>}>, 'org.onlyoffice.desktopeditors.desktop': <{'position': <5>}>, 'org.gnome.Nautilus.desktop': <{'position': <6>}>, 'org.gnome.Software.desktop': <{'position': <7>}>}, {'System': <{'position': <0>}>, 'Utilities': <{'position': <1>}>, 'org.gimp.GIMP.desktop': <{'position': <2>}>, 'vlc.desktop': <{'position': <3>}>, 'org.keepassxc.KeePassXC.desktop': <{'position': <4>}>, 'com.google.AndroidStudio.desktop': <{'position': <5>}>}]"},
        },
    },
}
