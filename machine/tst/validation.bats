load test_helper

setup() { setup_env; }
teardown() { teardown_env; }

expect_error() {
    run "$MACHINE" plan hosts/test.lua
    [ "$status" -eq 1 ]
    [[ "$output" == *"$1"* ]]
    [ ! -s "$LOG" ]
}

@test "a misspelled field is rejected before anything runs" {
    host '"m"'
    module m <<'LUA'
return {snap = {present = {{name = "x", clasic = true}}}}
LUA
    expect_error "unknown field 'clasic'"
}

@test "a misspelled state is rejected" {
    host '"m"'
    module m <<'LUA'
return {apt = {presnet = {"jq"}}}
LUA
    expect_error "unknown key 'presnet'"
}

@test "the same thing wanted present and absent is an error naming both" {
    host '"a", "b"'
    module a <<'LUA'
return {apt = {present = {"gimp"}}}
LUA
    module b <<'LUA'
return {apt = {absent = {"gimp"}}}
LUA
    expect_error "wants gimp absent, but ./modules/a.lua"
}

@test "run items must say how to tell they are done" {
    host '"m"'
    module m <<'LUA'
return {run = {present = {{name = "x", cmd = "true"}}}}
LUA
    expect_error "needs 'creates' or 'unless'"
}

@test "path removal refuses shallow paths and home" {
    host '"m"'
    module m <<'LUA'
return {path = {absent = {"/usr"}}}
LUA
    expect_error "refusing a path this close to /"
    module m <<'LUA'
return {path = {absent = {"~"}}}
LUA
    expect_error "refusing the home directory"
}

@test "unknown variables are rejected" {
    host '"m"'
    module m <<'LUA'
return {path = {present = {"${nope}/x"}}}
LUA
    expect_error 'unknown variable ${nope}'
}

@test "module files are data: no os or io" {
    host '"m"'
    module m <<'LUA'
os.execute("touch /tmp/should-not-exist")
return {}
LUA
    expect_error "attempt to index"
}

@test "host vars expand inside modules, including ~ and other vars" {
    cat > hosts/test.lua <<'LUA'
return {vars = {projects = "~/P", configs = "${projects}/configs"}, modules = {"m"}}
LUA
    module m <<'LUA'
return {path = {present = {"${configs}"}}}
LUA
    run "$MACHINE" plan hosts/test.lua
    [ "$status" -eq 0 ]
    [[ "$output" == *"+ $HOME/P/configs"* ]]
}
