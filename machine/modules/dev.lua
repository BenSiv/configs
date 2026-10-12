-- Development toolchain: Lua 5.1 + LuaRocks, Antigravity IDE and the
-- libraries its Electron build needs.
return {
    apt = {
        present = {
            "lua5.1", "liblua5.1-0-dev", "luarocks", "gcc",
            "libsecret-1-0", "libnotify4", "libnss3", "libxkbcommon0",
            "libgbm1", "libasound2t64", "libgtk-3-0t64",
        },
    },
    snap = {
        present = {{name = "antigravity-ide-snap", classic = true}},
    },
    path = {
        -- The old manual Antigravity install, replaced by the snap.
        absent = {"/opt/antigravity", "/usr/local/bin/antigravity"},
    },
    run = {
        present = {
            {name = "luarocks luafilesystem", cmd = "luarocks install luafilesystem",
             unless = "luarocks show luafilesystem", sudo = true},
            {name = "luarocks lua-yaml", cmd = "luarocks install lua-yaml",
             unless = "luarocks show lua-yaml", sudo = true},
            {name = "luarocks dkjson", cmd = "luarocks install dkjson",
             unless = "luarocks show dkjson", sudo = true},
        },
    },
}
