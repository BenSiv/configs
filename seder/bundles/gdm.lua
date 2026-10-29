-- GDM greeter accent color
defaults = {}
return {
    run = {
        present = {
            {
                name = "set GDM orange accent",
                cmd = "sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface accent-color 'orange'",
                unless = "sudo -u gdm dbus-launch gsettings get org.gnome.desktop.interface accent-color | grep -q '\''orange'\'''",
                env = {DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${uid}/bus"}
            }
        }
    }
}
