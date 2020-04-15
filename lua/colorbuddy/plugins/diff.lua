local c = require('colorbuddy.color').colors
local Group = require('colorbuddy.group').Group

Group.new('gitDiff', c.gray6:dark())

Group.new('DiffChange', nil, c.gray7 - c.red)
Group.new('DiffText', nil, c.red)
Group.new('DiffDelete', c.gray3, c.gray0)
Group.new('DiffAdded', c.green:dark())
Group.new('DiffRemoved', c.violet)
