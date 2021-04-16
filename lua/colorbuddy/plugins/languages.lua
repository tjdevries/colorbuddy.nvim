local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

local s = require("colorbuddy.style").styles

-- Python syntax {{{
Group.new("pythonSelf", c.violet:light())
Group.new("pythonSelfArg", c.gray3, nil, s.italic)
Group.new("pythonOperator", c.red)

Group.new("pythonNone", c.red:light())
Group.new("pythonNone", c.red:light())
Group.new("pythonBytes", c.green, nil, s.italic)
Group.new("pythonRawBytes", g.pythonBytes, g.pythonBytes, g.pythonBytes)
Group.new("pythonBytesContent", g.pythonBytes, g.pythonBytes, g.pythonBytes)
Group.new("pythonBytesError", g.Error, g.Error, g.Error)
Group.new("pythonBytesEscapeError", g.Error, g.Error, g.Error)
Group.new("pythonBytesEscape", g.Special, g.Special, g.Special)
-- }}}
-- Vim Syntax {{{
Group.new("vimNotFunc", c.blue)
Group.new("vimCommand", c.blue)
Group.new("vimLet", c.purple:light())
Group.new("vimFuncVar", c.purple)
Group.new("vimCommentTitle", c.red, nil, s.bold)
Group.new("vimIsCommand", g.vimLet)

Group.new("vimMapModKey", c.cyan)
Group.new("vimNotation", c.cyan)
Group.new("vimMapLHS", c.yellow)
Group.new("vimNotation", c.cyan)
Group.new("vimBracket", c.cyan:negative():light())
Group.new("vimMap", c.seagreen)
Group.new("nvimMap", g.vimMap)
-- }}}
-- Lua Syntax {{{
Group.new("luaStatement", c.yellow:dark(), nil, s.bold)
Group.new("luaKeyword", c.orange:dark(), nil, s.bold)
Group.new("luaMyKeyword", c.purple:light(), nil, s.bold)
-- Group.new('luaFunction', c.blue:dark(), nil, nil)
Group.new("luaFunctionCall", c.blue:dark(), nil, nil)
Group.new("luaSpecialFunctions", c.blue:light(), nil, nil)
Group.new("luaMetatableEvents", c.purple, nil, nil)
Group.new("luaMetatableArithmetic", g.luaMetatableEvents, g.luaMetatableEvents, g.luaMetatableEvents)
Group.new("luaMetatableEquivalence", g.luaMetatableEvents, g.luaMetatableEvents, g.luaMetatableEvents)
-- }}}
-- SQL Syntax {{{
Group.new("SqlKeyword", c.red)
-- }}}
-- HTML Syntax {{{
Group.new("htmlH1", c.blue:dark(), nil, s.bold)
-- }}}
-- Rust Syntax {{
-- }}}
