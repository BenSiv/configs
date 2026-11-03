-- The personal dev container: the personal laptop's tools (personal.lua)
-- in a container, for working on the luam projects anywhere podman runs.
-- Every repo lives on the devenv-personal volume at /root/Projects, the
-- same layout as ~/Projects on the laptop, so a rebuild never loses work;
-- missing checkouts are cloned on start. The work container is
-- specified in celleste-bio/software (devenv/bensiv).
--
--   tkn build  envs/devenv.lua
--   tkn switch envs/devenv.lua
return {
    requires_teken = "0.3.0",
    target = "container",
    units = {"build-deps", "base-tools", "luam-stack", "dotfiles", "projects"},
    state = {
        {path = "/root/Projects", volume = "devenv-personal"},   -- every repo and worktree
    },
    container = {
        name = "devenv-personal",
        base = "ubuntu:24.04",
        hostname = "devenv-personal",
        tty = true,
        restart = "always",
        command = {"bash"},
        ephemeral = {"/root/.cache", "/root/.claude", "/root/.local", "/root/.config/micro/buffers"},
    },
    keep = 3,
}
