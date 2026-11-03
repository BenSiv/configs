-- The Celleste dev container, ported from software/devenv/bensiv
-- (Containerfile + deploy.sh). Every repo lives on the devenv-projects
-- volume at /root/projects, so rebuilding or swapping the image never
-- loses work; `devenv-clone` fills in missing checkouts there.
--
--   tkn build  envs/devenv.lua     # build and verify the image only
--   tkn switch envs/devenv.lua     # swap the running container
return {
    requires_teken = "0.2.0",
    target = "container",
    vars = {rnd_path = "~/rnd"},
    units = {
        "build-deps", "base-tools", "luam-stack", "dotfiles",
        "cloud-clis", "node-tools", "python", "celleste",
    },
    state = {
        {path = "/root/projects", volume = "devenv-projects"},   -- every repo and worktree
        {path = "/data", volume = "celleste-bensiv-data"},       -- brex database
        {path = "/root/rnd", bind = "${rnd_path}"},
    },
    container = {
        name = "celleste-bensiv",
        base = "ubuntu:24.04",
        hostname = "celleste-bensiv",
        ports = {"8000:8000", "8080:8080"},
        tty = true,
        restart = "always",
        command = {"bash"},
        ephemeral = {"/root/.cache", "/root/.claude", "/root/.local", "/root/.config/micro/buffers"},
    },
    keep = 3,
}
