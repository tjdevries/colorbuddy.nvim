local c = require("colorbuddy.color").colors
local Group = require("colorbuddy.group").Group
local s = require("colorbuddy.style").styles

Group.new("StartifyBracket", c.red)
Group.new("StartifyFile", c.red:dark())
Group.new("StartifyNumber", c.blue)
Group.new("StartifyPath", c.green:dark())
Group.new("StartifySlash", c.cyan, nil, s.bold)
Group.new("StartifySection", c.yellow:light())
Group.new("StartifySpecial", c.orange)
Group.new("StartifyHeader", c.orange)
Group.new("StartifyFooter", c.gray2)
