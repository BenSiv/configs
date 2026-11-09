-- The work machine: WSL (Ubuntu) on Windows 11. The luam tools on PATH
-- and the dotfiles from this repo, linked through the active generation.
-- The checkouts in ~/Projects are state: cloned when missing, never
-- touched after.
-- The dev container (devenv.lua) runs on this machine too.
--
-- Host prerequisites (no seder here): build-essential libreadline-dev
-- libsqlite3-dev libmariadb-dev libssl-dev libcrypt-dev
--
--   tkn switch envs/work.lua
return {
    requires_teken = "0.3.0",
    target = "home",
    units = {"luam-stack", "dotfiles", "home-shell", "projects", "work-projects", "personal-repos"},
    state = {
        {path = "~/Projects"},
        {path = "~/Personal"},
    },
    keep = 3,
}
