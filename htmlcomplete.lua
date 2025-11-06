local micro = import("micro")
local config = import("micro/config")

local selfclosing_tags = {
    "meta", "link", "img", "input", "br",
    "hr", "area", "base", "col", "source",
    "track", "embed", "param", "wbr"
}

local boilerplate = [[

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>
    
</body>
</html>]]

function is_inside_tag(before, after)
    local b = before:match("<%w+%s*.*>$")
    if b == nil then return false end
    local e = after:match("^</%w+>")
    if e == nil then return false end
    return true
end

function strip(x)
    return x:gsub("^%s*(.*)%s*$", "%1")
end

function onInsertNewline(bp)
    if bp.Buf:FileType() ~= "html" then return false end
    if bp.Cursor.Loc.Y <= 0 then return false end
    local before = strip(bp.Buf:Line(bp.Cursor.Loc.Y-1))
    local after  = strip(bp.Buf:Line(bp.Cursor.Loc.Y))
    local tabsize = bp.Buf.Settings["tabsize"]
    if is_inside_tag(before, after) then
        local indent = bp.Cursor.Loc.X
        bp:InsertNewline()
        local loc = {Y = bp.Cursor.Loc.Y-1, X = 0}
        bp.Cursor:GotoLoc(loc)
        bp.Buf:Insert(loc, string.rep(" ", indent))
        bp.Cursor:End()
        bp:IndentLine()
        return true
    end
end

function onRune(bp, rune)
    if bp.Buf:FileType() ~= "html" then return end

    local buf = bp.Buf
    local line = buf:Line(bp.Cursor.Loc.Y)
    line = line:sub(1, bp.Cursor.Loc.X)
    line = strip(line)
    
    if rune == ">" then
        if line == "<!DOCTYPE html>" then
            bp.Buf:Insert({Y = bp.Cursor.Loc.Y, X = bp.Cursor.Loc.X}, boilerplate)
            bp.Cursor:GotoLoc({ X = bp.Cursor.Loc.X, Y = bp.Cursor.Loc.Y-2})
            micro.InfoBar():Message("Autocompleted boilerplate")
            return            
        end
        
        local tag = line:match("<([%w]+)[^>]*>$")
        if tag == nil then return end

        if line:match("</"..tag..">") then return end

        local self_closing = false
        for _, i in ipairs(selfclosing_tags) do
            if i == tag then self_closing = true end
        end

        if not self_closing then
            local loc = {Y = bp.Cursor.Loc.Y, X = bp.Cursor.Loc.X}
            bp.Buf:Insert(loc, "</"..tag..">")
            bp.Cursor:GotoLoc(loc)
        else
            local loc = {Y = bp.Cursor.Loc.Y, X = bp.Cursor.Loc.X-1}
            bp.Cursor:GotoLoc(loc)
            bp.Buf:Insert(loc, " /")
            bp.Cursor:GotoLoc(loc)
        end
        micro.InfoBar():Message("Autocompleted tag")
    end
end

function init()
end
