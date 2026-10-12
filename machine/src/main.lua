-- machine: declarative setup for this repo's Ubuntu machines.
--
--   machine plan  [host.lua] [-v]   show what apply would change
--   machine check [host.lua]        exit 2 when the machine has drifted
--   machine apply [host.lua] [-y]   make the changes (asks first on a tty)
--
-- host.lua defaults to hosts/<hostname>.lua under the current directory;
-- its modules are read from the modules/ directory next to hosts/.

if package.preload["engine"] == nil then
    script_dir = string.match(arg[0], "^(.*/)")
    if script_dir == nil then
        script_dir = "./"
    end
    package.path = script_dir .. "?.lua;" .. package.path
end

shell = require("shell")
loader = require("loader")
engine = require("engine")

USAGE = """usage: machine <plan|check|apply> [host.lua] [-v|--verbose] [-y|--yes]

  plan    show what apply would change (-v: unchanged items too)
  check   like plan, but exit 2 when anything would change
  apply   make the changes; asks for confirmation unless -y

host.lua defaults to hosts/<hostname>.lua."""

function parse_args(args)
    options = {verbose = false, yes = false}
    for _, value in ipairs(args) do
        if value == "-v" or value == "--verbose" then
            options.verbose = true
        elseif value == "-y" or value == "--yes" then
            options.yes = true
        elseif value == "-h" or value == "--help" then
            options.help = true
        elseif string.sub(value, 1, 1) == "-" then
            error("unknown option " .. value, 0)
        elseif options.command == nil then
            options.command = value
        elseif options.host == nil then
            options.host = value
        else
            error("unexpected argument " .. value, 0)
        end
    end
    return options
end

function default_host()
    out, _ = shell.capture("hostname")
    return "hosts/" .. string.gsub(out, "%s+$", "") .. ".lua"
end

function confirm()
    if shell.ok("test -t 0") == false then
        error("apply needs -y when not run from a terminal", 0)
    end
    io.write("Apply these changes? [y/N] ")
    answer = io.read("*l")
    return answer == "y" or answer == "Y" or answer == "yes"
end

function main(args)
    options = parse_args(args)
    if options.help == true or options.command == nil then
        print(USAGE)
        if options.help == true then
            return 0
        end
        return 1
    end
    command = options.command
    if command != "plan" and command != "check" and command != "apply" then
        error("unknown command " .. command .. "\n\n" .. USAGE, 0)
    end
    host_path = options.host
    if host_path == nil then
        host_path = default_host()
    end
    desired, _ = loader.load_desired(host_path, engine.providers)
    groups = engine.plan(desired)
    counts = engine.print_plan(groups, options.verbose)
    changes = counts.add + counts.remove + counts.conflict
    if command == "plan" then
        return 0
    end
    if command == "check" then
        if changes > 0 then
            return 2
        end
        return 0
    end
    if changes == 0 then
        print("Nothing to do.")
        return 0
    end
    if options.yes == false and confirm() == false then
        print("Not applied.")
        return 1
    end
    if engine.apply(groups) then
        print("Done.")
        return 0
    end
    return 1
end

ok, result = pcall(main, arg)
if ok != true then
    io.write(io.stderr, "machine: " .. tostring(result) .. "\n")
    os.exit(1)
end
os.exit(result)
