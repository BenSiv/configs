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
            -- Matched to Debian's GNOME version; enabled in gnome.lua.
            "gnome-shell-extension-blur-my-shell",
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
            -- Parental Controls; only recommended by GNOME Settings.
            "malcontent-gui",
        },
    },
    path = {
        -- The extensions.gnome.org copy, which would override the package.
        absent = {"~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx"},
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
            -- Ptyxis is the terminal on every distribution; gnome-core
            -- accepts it in place of GNOME Terminal, which Debian picks.
            hide("org.gnome.Terminal.desktop"),
            hide("org.gnome.Terminal.Preferences.desktop"),
            hide("debian-xterm.desktop"),
            hide("debian-uxterm.desktop"),
            hide("texdoctk.desktop"),       -- from texlive-base, which xetex needs
            -- Files with a folder icon instead of the filing cabinet.
            {path = "~/.local/share/applications/org.gnome.Nautilus.desktop",
             target = "${configs}/gnome/org.gnome.Nautilus.desktop"},
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
            -- The app grid, one page in this order (desktop IDs as Debian and
            -- Flathub ship them; Debian's GIMP is gimp.desktop). Rearranging
            -- icons by hand is undone by the next apply: change it here.
            {key = "/org/gnome/shell/app-picker-layout",
             value = "[{'org.gnome.Ptyxis.desktop': <{'position': <0>}>, 'app.zen_browser.zen.desktop': <{'position': <1>}>, 'google-chrome.desktop': <{'position': <2>}>, 'org.gnome.Nautilus.desktop': <{'position': <3>}>, 'com.rtosta.zapzap.desktop': <{'position': <4>}>, 'org.gnome.Software.desktop': <{'position': <5>}>, 'org.onlyoffice.desktopeditors.desktop': <{'position': <6>}>, 'micro.desktop': <{'position': <7>}>, 'vlc.desktop': <{'position': <8>}>, 'gimp.desktop': <{'position': <9>}>, 'com.github.PintaProject.Pinta.desktop': <{'position': <10>}>, 'Utilities': <{'position': <11>}>, 'System': <{'position': <12>}>, 'org.keepassxc.KeePassXC.desktop': <{'position': <13>}>, 'com.google.AndroidStudio.desktop': <{'position': <14>}>}]"},
        },
    },
}
