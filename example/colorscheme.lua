
local Color = require('colorbuddy.init').Color
local colors = require('colorbuddy.init').colors

local Group = require('colorbuddy.init').Group
local groups = require('colorbuddy.init').groups

local styles = require('colorbuddy.init').styles

Color.new('red', '#cc6666')
Color.new('green', '#99cc99')
Color.new('yellow', '#f0c674')

Group.new('Function', colors.yellow, nil, styles.bold)
Group.new('mFunction', groups.Function, groups.Function, groups.Function)
