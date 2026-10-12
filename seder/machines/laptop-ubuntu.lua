-- Ben's laptop while it still runs Ubuntu; replaced by laptop.lua (Debian)
-- after the reinstall, then this file goes. Bundles are listed in apply order;
-- within a run, all removals happen first, then all additions.
return {
    requires_seder = "0.4.0",
    vars = {
        projects = "~/Projects",
        configs = "${projects}/configs",
        timezone = "America/Los_Angeles",
        -- The phone's Passtore folder, mounted by GNOME when it is
        -- connected over USB (MTP).
        gpg_keys = "/run/user/${uid}/gvfs/mtp:host=Sony_XQ-FE72_HQ65991561/Internal shared storage/Passtore",
    },
    bundles = {"base", "gnome", "ubuntu", "dev", "dotfiles", "builds", "cleanup", "secrets"},
}
