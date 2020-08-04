local c = require('colorbuddy.color').colors
local Group = require('colorbuddy.group').Group

Group.new('gitDiff', c.gray6:dark())

Group.new('DiffChange', nil, c.gray7 - c.red)
Group.new('DiffText', nil, c.red)
Group.new('DiffDelete', c.gray3, c.gray0)
Group.new('DiffAdded', c.green:dark())
Group.new('DiffRemoved', c.violet)

-- TODO: Gotta fix these probably as well.
-- Group.new('SignifyLineAdd', c.green, nil)
-- Group.new('SignifyLineChange', nil, c.blue)
Group.new('SignifySignAdd', c.green, nil)
Group.new('SignifySignChange', c.yellow, nil)
Group.new('SignifySignDelete', c.red, nil)
