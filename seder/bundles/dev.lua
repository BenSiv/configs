-- Development toolchain: Lua 5.1 + LuaRocks. The IDE comes from the
-- distribution bundle.
return {
    apt = {
        present = {
            "lua5.1", "liblua5.1-0-dev", "luarocks", "gcc",
        },
    },
    path = {
        -- The old manual Antigravity install.
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
