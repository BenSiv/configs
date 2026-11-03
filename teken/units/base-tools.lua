-- Command-line tools of the personal container, after seder's base and
-- dev bundles. teken installs with --no-install-recommends, so what a
-- desktop install gets by recommendation is listed explicitly.
return {
    apt = {
        "tzdata", "curl", "wget", "gnupg", "unzip", "xz-utils",
        "make", "fd-find", "ripgrep", "jq", "tree", "micro", "sqlite3",
        "bats", "pandoc", "cmark-gfm", "pass",
        "lua5.1", "liblua5.1-0-dev", "luarocks",
    },
    env = {
        TZ = "America/Los_Angeles",
        LUAM_LIB = "/opt/teken/lib/luam",   -- luam-stack's lib/ (bashrc)
    },
    verify = {"micro --version", "sqlite3 --version", "rg --version"},
}
