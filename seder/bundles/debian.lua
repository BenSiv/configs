-- What only Debian needs: its GNOME desktop, and apps from Flathub
-- (sandboxed) where Ubuntu used snaps.
--
-- gnome-core is declared so the desktop stays wanted when the bloatware
-- removal in gnome.lua takes the full `gnome` metapackage with it (it
-- depends on LibreOffice and Shotwell); gnome-core only recommends a
-- browser, so Firefox ESR can go.

-- A Flathub app, adding the Flathub remote first on a fresh install.
function flathub(id)
    return {name = id, remote = "flathub", remote_url = "https://dl.flathub.org/repo/flathub.flatpakrepo"}
end

return {
    apt = {
        present = {"gnome-core", "flatpak"},
        absent = {"firefox-esr"},
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
