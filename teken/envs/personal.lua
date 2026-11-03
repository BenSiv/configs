-- The personal laptop: Debian 13 with GNOME, put in order by seder
-- (../seder/machines/laptop.lua), which also installs the build
-- prerequisites. Same units as work.lua.
--
-- seder's dotfiles and builds bundles link the same paths (~/.bashrc,
-- /usr/local/bin/<tool>); see the README before the first switch here.
--
--   tkn switch envs/personal.lua
return {
    requires_teken = "0.3.0",
    target = "home",
    units = {"luam-stack", "dotfiles", "home-shell", "projects"},
    state = {
        {path = "~/Projects"},
    },
    keep = 3,
}
