-- colorbuddy.vim
-- @author: TJ DeVries
-- Inspired HEAVILY by @tweekmonster's colorpal.vim


local groups = require('colorbuddy.group').groups
local colors = require('colorbuddy.color').colors

return {
    groups = groups,
    Group = require('colorbuddy.group').Group,
    colors = colors,
    Color = require('colorbuddy.color').Color,
    styles = require('colorbuddy.style').styles,
}
