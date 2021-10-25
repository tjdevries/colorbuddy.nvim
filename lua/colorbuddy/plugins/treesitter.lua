local Color = require("colorbuddy.color").Color
local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

Group.new("TSInclude", g.include)

Group.new("TSConstant", c.blue)
Group.new("TSVariable", g.Normal)
Group.new("TSFunction", g.Function)

Group.new("TSVariableBuiltin", c.yellow)

Group.new("graphqlTSProperty", c.blue)
