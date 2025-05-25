VERSION = "0.1.0"

local micro = import("micro")

local luaTermBufName = "*lua-repl*"

function getOrOpenLuaTerm()
    for _, buf in ipairs(micro.Buffers) do
        if buf:Type() == "terminal" and buf.Name == luaTermBufName then
            return buf
        end
    end
    micro.CurPane():VSplitIndexTerm("lua", luaTermBufName, false)
    micro.InfoBar():Message("Opened Lua REPL terminal.")
end

function sendToLuaTerm(line)
    for _, buf in ipairs(micro.Buffers) do
        if buf:Type() == "terminal" and buf.Name == luaTermBufName then
            buf:TermSend(line .. "\n")
            return
        end
    end
    micro.InfoBar():Error("Lua REPL terminal not found.")
end

function runCurrentLine(bp)
    getOrOpenLuaTerm()

    local sel = bp.Cursor:GetSelection()
    local line = ""

    if sel ~= "" then
        line = sel
    else
        line = bp.Buf:Line(bp.Cursor.Y)
    end

    sendToLuaTerm(line)
end

function init()
    -- No keybinding code needed here
end
