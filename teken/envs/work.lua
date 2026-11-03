-- The work machine: WSL (Ubuntu) on Windows 11. The luam tools on PATH
-- and the dotfiles from this repo, linked through the active generation.
-- The checkouts in ~/Projects are state: teken never touches them.
-- The dev container (devenv.lua) runs on this machine too.
--
-- Host prerequisites (no seder here): build-essential libreadline-dev
-- libsqlite3-dev libmariadb-dev libssl-dev libcrypt-dev
--
--   tkn switch envs/work.lua
return {
    requires_teken = "0.2.0",
    target = "home",
    units = {"luam-stack", "dotfiles", "home-shell"},
    state = {
        {path = "~/Projects"},
    },
    keep = 3,
}
