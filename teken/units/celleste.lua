-- Celleste work: Quarto, the RDS CA bundle, shell additions, the git
-- editor, and `devenv-clone`, which fills the devenv-projects volume.
-- What the old entrypoint ran on every start (claude/sync.sh,
-- brex/setup.sh, the clipboard sync) waits for teken's runtime start.
return {
    build = {
        {name = "quarto", from = "configs",
         cmd = "curl -fsSL -o quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.24/quarto-1.8.24-linux-amd64.deb"
            .. " && echo 'e532f4ce6e0953dbcf4093a2d004ce0d6bf7d2fb6f5e0338fd271aa2ef28ff25  quarto.deb' | sha256sum -c -"
            .. " && mkdir -p out && dpkg-deb -x quarto.deb out/root && ln -s \"$PWD/out/root/opt/quarto/bin/quarto\" out/quarto",
         install = {["out/quarto"] = "bin/quarto"}},
    },
    fetch = {
        {url = "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem", path = "files/rds-global-bundle.pem"},
    },
    files = {
        {path = "files/path_addons", source = "files/devenv-path-addons.sh"},
        {path = "bin/devenv-git-editor", source = "files/devenv-git-editor.sh", mode = "755"},
        {path = "bin/devenv-clone", source = "files/devenv-clone.sh", mode = "755"},
    },
    links = {
        {path = "/root/.path_addons", target = "files/path_addons"},
        {path = "/root/.postgresql/root.crt", target = "files/rds-global-bundle.pem"},
    },
    env = {
        GIT_EDITOR = "devenv-git-editor",
        PGSSLMODE = "verify-ca",
        PROJECTS = "/root/projects",   -- bashrc and aliases follow it
        SOFTWARE_HOME = "/root/projects/software",
    },
    verify = {"quarto --version", "test -s /root/.postgresql/root.crt", "command -v devenv-clone"},
}
