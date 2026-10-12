-- Loads host and module files and turns them into the desired state the
-- engine plans against. Files are data, not code: each is run in the
-- same data-only sandbox daat uses for platform.lua and schemas (no io,
-- os or require) and must return a table. Every field is then checked
-- against the provider that owns it, so a typo fails before anything
-- touches the machine.

sandbox = require("sandbox")
shell = require("shell")

loader = {}

HOST_KEYS = {vars = "table", modules = "table"}

function fail(path, message)
    error(path .. ": " .. message, 0)
end

function read_source(path)
    file = io.open(path, "r")
    if file == nil then
        fail(path, "file not found")
    end
    source = io.read(file, "*a")
    io.close(file)
    return source
end

function loader.load_table(path)
    ok, value = sandbox.run(read_source(path), "@" .. path, sandbox.data_env())
    if ok != true then
        fail(path, tostring(value))
    end
    if type(value) != "table" then
        fail(path, "must return a table, got " .. type(value))
    end
    return value
end

function sorted_keys(tbl)
    keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, tostring(key))
    end
    table.sort(keys)
    return keys
end

-- type() with booleans named "boolean" (luam calls them "flag"), so
-- providers and error messages use the familiar name.
function type_name(value)
    name = type(value)
    if name == "flag" then
        return "boolean"
    end
    return name
end

function is_list(tbl)
    count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count == #tbl
end

-- ${name} -> vars[name]; a leading ~/ -> $HOME/. Applied to every
-- string in an item, including the values of nested tables (env).
function expand_string(value, vars, where)
    missing = nil
    value = string.gsub(value, "%${([%w_]+)}", function(name)
        if vars[name] == nil then
            missing = name
            return nil
        end
        return vars[name]
    end)
    if missing != nil then
        error(where .. ": unknown variable ${" .. missing .. "}", 0)
    end
    if value == "~" then
        return shell.home()
    end
    if string.sub(value, 1, 2) == "~/" then
        return shell.home() .. string.sub(value, 2)
    end
    return value
end

function expand_value(value, vars, where)
    if type(value) == "string" then
        return expand_string(value, vars, where)
    end
    if type(value) == "table" then
        result = {}
        for key, inner in pairs(value) do
            result[key] = expand_value(inner, vars, where)
        end
        return result
    end
    return value
end

function supports(provider, state)
    for _, name in ipairs(provider.states) do
        if name == state then
            return true
        end
    end
    return false
end

-- Checks one raw item from a module file and returns it normalized
-- (a bare string becomes {<key> = string}) and expanded.
function normalize_item(raw, provider, state, vars, where)
    item = raw
    if type(raw) == "string" then
        item = {}
        item[provider.key] = raw
    end
    if type(item) != "table" then
        error(where .. ": expected a string or table, got " .. type(raw), 0)
    end
    for field, value in pairs(item) do
        expected = provider.fields[field]
        if expected == nil then
            error(where .. ": unknown field '" .. tostring(field) .. "' (allowed: "
                .. table.concat(sorted_keys(provider.fields), ", ") .. ")", 0)
        end
        if type_name(value) != expected then
            error(where .. ": field '" .. field .. "' must be a " .. expected
                .. ", got " .. type_name(value), 0)
        end
    end
    for _, field in ipairs(provider.required[state]) do
        if item[field] == nil then
            error(where .. ": missing required field '" .. field .. "'", 0)
        end
    end
    item = expand_value(item, vars, where)
    if provider.validate != nil then
        err = provider.validate(item, state)
        if err != nil then
            error(where .. ": " .. err, 0)
        end
    end
    return item
end

function loader.load_host(path)
    host = loader.load_table(path)
    for key, value in pairs(host) do
        if HOST_KEYS[key] == nil then
            fail(path, "unknown key '" .. tostring(key) .. "' (allowed: vars, modules)")
        end
        if type(value) != HOST_KEYS[key] then
            fail(path, "'" .. key .. "' must be a table")
        end
    end
    if host.modules == nil or #host.modules == 0 then
        fail(path, "'modules' must list at least one module")
    end
    vars = {home = shell.home(), user = os.getenv("USER")}
    if host.vars != nil then
        for name, value in pairs(host.vars) do
            if type(value) != "string" then
                fail(path, "var '" .. tostring(name) .. "' must be a string")
            end
            vars[name] = value
        end
    end
    -- Vars may refer to each other and to ~ (projects = "~/Projects").
    for name, value in pairs(vars) do
        vars[name] = expand_string(value, vars, path .. ": var " .. name)
    end
    host.vars = vars
    return host
end

-- Builds the desired state for a host:
--   desired[provider_name] = list of {item, state, module, where}
-- in host module order, then file order. The same resource wanted both
-- present and absent is an error, naming both places.
function loader.load_desired(host_path, providers)
    host = loader.load_host(host_path)
    module_dir = shell.parent(shell.parent(host_path)) .. "/modules"
    desired = {}
    seen = {}
    for _, module_name in ipairs(host.modules) do
        path = module_dir .. "/" .. module_name .. ".lua"
        module = loader.load_table(path)
        for _, provider_name in ipairs(sorted_keys(module)) do
            provider = providers[provider_name]
            if provider == nil then
                fail(path, "unknown provider '" .. provider_name .. "' (known: "
                    .. table.concat(sorted_keys(providers), ", ") .. ")")
            end
            section = module[provider_name]
            if type(section) != "table" then
                fail(path, provider_name .. " must be a table of present/absent lists")
            end
            for _, state in ipairs(sorted_keys(section)) do
                if state != "present" and state != "absent" then
                    fail(path, provider_name .. ": unknown key '" .. state
                        .. "' (allowed: present, absent)")
                end
                if supports(provider, state) == false then
                    fail(path, provider_name .. " does not support '" .. state .. "'")
                end
                items = section[state]
                if type(items) != "table" or is_list(items) == false then
                    fail(path, provider_name .. "." .. state .. " must be a list")
                end
                if desired[provider_name] == nil then
                    desired[provider_name] = {}
                end
                for index, raw in ipairs(items) do
                    where = path .. ": " .. provider_name .. "." .. state .. "[" .. index .. "]"
                    item = normalize_item(raw, provider, state, host.vars, where)
                    id = provider_name .. ":" .. item[provider.key]
                    previous = seen[id]
                    if previous == nil then
                        seen[id] = {state = state, where = where}
                        table.insert(desired[provider_name],
                            {item = item, state = state, module = module_name, where = where})
                    elseif previous.state != state then
                        error(where .. ": wants " .. item[provider.key] .. " " .. state
                            .. ", but " .. previous.where .. " wants it " .. previous.state, 0)
                    end
                end
            end
        end
    end
    return desired, host
end

return loader
