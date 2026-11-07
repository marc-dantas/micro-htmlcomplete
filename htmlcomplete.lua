local micro = import("micro")
local config = import("micro/config")

local selfclosing_tags = {
	"meta",
	"link",
	"img",
	"input",
	"br",
	"hr",
	"area",
	"base",
	"col",
	"source",
	"track",
	"embed",
	"param",
	"wbr",
}

function is_inside_tag(before, after)
	local b = before:match("<%w+%s*.*>$")
	if b == nil then
		return false
	end
	local e = after:match("^</%w+>")
	if e == nil then
		return false
	end
	return true
end

function strip(x)
	return x:gsub("^%s*(.*)%s*$", "%1")
end

function preInsertNewline(bp)
	if bp.Buf:FileType() ~= "html" then
		return true
	end
	if bp.Cursor.Loc.Y <= 0 then
		return true
	end
	local tabsize = bp.Buf.Settings["tabsize"]
	local line = bp.Buf:Line(bp.Cursor.Loc.Y)

	local before = string.sub(line, 1, bp.Cursor.Loc.X)
	local after = string.sub(line, bp.Cursor.Loc.X+1, #line)
	
	if is_inside_tag(before, after) then
		local indent_end = string.find(before, "%S")
		local indent = string.sub(before, 1, indent_end-1)
		
		bp:InsertNewline()
		bp:InsertNewline()
		bp.Cursor:GotoLoc({ X = 0, Y = bp.Cursor.Loc.Y-1 })
		bp.Buf:Insert({ X = bp.Cursor.Loc.X, Y = bp.Cursor.Loc.Y }, indent .. string.rep(" ", tabsize))
		bp.Cursor:End()
		return false
	end
	return true
end

function onRune(bp, rune)
	if bp.Buf:FileType() ~= "html" then
		return
	end

	local buf = bp.Buf
	local line = buf:Line(bp.Cursor.Loc.Y)
	line = line:sub(1, bp.Cursor.Loc.X)
	line = strip(line)

	local tabsize = bp.Buf.Settings["tabsize"]
	local tab = string.rep(" ", tabsize)
	local boilerplate = [[
<!DOCTYPE html>
<html lang="en">
<head>
]] .. tab .. [[<meta charset="UTF-8">
]] .. tab .. [[<meta name="viewport" content="width=device-width, initial-scale=1.0">
]] .. tab .. [[<meta http-equiv="X-UA-Compatible" content="ie=edge">
]] .. tab .. [[<title>Document</title>
</head>
<body>

</body>
</html>]]

	local boilerplate_trigger = "html>"
	if rune == ">" then
		if string.sub(line, #line - #boilerplate_trigger+1, #line) == boilerplate_trigger then
			bp.Buf:Remove({ Y = bp.Cursor.Loc.Y - 1 }, { X = #line })
			bp.Buf:Insert({ Y = bp.Cursor.Loc.Y, X = bp.Cursor.Loc.X }, boilerplate)
			bp.Buf:Insert({ Y = bp.Cursor.Loc.Y - 2, X = bp.Cursor.Loc.X }, tab)
			bp.Cursor:GotoLoc({ X = tabsize, Y = bp.Cursor.Loc.Y - 2 })
			micro.InfoBar():Message("Autocompleted boilerplate")
			return
		end

		local tag = line:match("<([%w]+)[^>]*>$")
		if tag == nil then
			return
		end

		if line:match("</" .. tag .. ">") then
			return
		end

		local self_closing = false
		for _, i in ipairs(selfclosing_tags) do
			if i == tag then
				self_closing = true
			end
		end

		if not self_closing then
			local loc = { Y = bp.Cursor.Loc.Y, X = bp.Cursor.Loc.X }
			bp.Buf:Insert(loc, "</" .. tag .. ">")
			bp.Cursor:GotoLoc(loc)
		else
			local loc = { Y = bp.Cursor.Loc.Y, X = bp.Cursor.Loc.X - 1 }
			bp.Cursor:GotoLoc(loc)
			bp.Buf:Insert(loc, " /")
			bp.Cursor:GotoLoc(loc)
		end
		micro.InfoBar():Message("Autocompleted tag")
	end
end

function init() end
