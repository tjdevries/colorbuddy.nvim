local Color = require('colorbuddy.color').Color
local c = require('colorbuddy.color').colors

local Group = require('colorbuddy.group').Group
local g = require('colorbuddy.group').groups

local s = require('colorbuddy.style').styles

Group.new("TSInclude", g.include)

Group.new("TSConstant", c.blue)
Group.new("TSVariable", g.Normal)
Group.new("TSFunction", g.Function)

Group.new("TSVariableBuiltin", c.purple:light(), nil, s.italic)

