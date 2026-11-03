-- Command-line tools of the dev container (the Containerfile's apt list).
-- teken installs with --no-install-recommends, so what the old image got
-- by recommendation is listed explicitly (tzdata, gnupg, xz-utils, ...).
return {
    apt = {
        "tzdata", "curl", "wget", "gnupg", "unzip", "xz-utils", "zstd",
        "tree", "jq", "micro", "sqlite3", "bats", "wl-clipboard",
        "pandoc", "texlive-xetex", "cmark", "cmark-gfm", "poppler-utils",
        "gnuplot-nox", "openscad", "postgresql-client", "mariadb-client",
        "nodejs", "npm", "python3", "python3-venv", "python3-pip",
    },
    env = {TZ = "Asia/Jerusalem"},
    verify = {"micro --version", "sqlite3 --version", "pandoc --version"},
}
