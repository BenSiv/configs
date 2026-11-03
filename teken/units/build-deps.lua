-- What the luam builds compile and link against (seder's builds bundle).
return {
    apt = {
        "ca-certificates", "git", "build-essential", "cmake",
        "libreadline-dev", "libncurses-dev", "libsqlite3-dev",
        "libcrypt-dev", "libssl-dev", "libmariadb-dev", "libpq-dev",
    },
}
