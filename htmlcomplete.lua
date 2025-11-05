local micro = import("micro")
local config = import("micro/config")

local selfclosing_tags = {
    "meta", "link", "img", "input", "br",
    "hr", "area", "base", "col", "source",
    "track", "embed", "param", "wbr"
}

-- Common attributes
local attrs = {
    "class", "id", "src", "href",
    "alt", "title", "style",
    "name", "value", "type", "for"
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

function onRune(bp, rune)
    if bp.Buf:FileType() ~= "html" then return end
    if rune == ">" then
        local buf = bp.Buf
        local line = buf:Line(bp.Cursor.Loc.Y)
        line = line:sub(1, bp.Cursor.Loc.X)
        line = line:gsub("^%s*(.-)%s*$", "%1")

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
