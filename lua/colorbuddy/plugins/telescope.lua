local c = require("colorbuddy.color").colors
-- local Color = require('colorbuddy.color').Color

-- local g = require('colorbuddy.group').groups
local Group = require("colorbuddy.group").Group

local s = require("colorbuddy.style").styles

-- Group.new('TelescopeMatching', g.LuaFunctionCall.fg, nil)
-- Group.new('TelescopeMatching', c.blue:light(), nil, s.bold)
-- Group.new('TelescopeMatching', g.LuaBuiltin.fg, nil, s.bold)
Group.new("TelescopeMatching", c.orange:saturate(0.20), c.None, s.bold)
