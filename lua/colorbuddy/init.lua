-- colorbuddy.vim
-- @author: TJ DeVries
-- Inspired HEAVILY by @tweekmonster's colorpal.vim


local groups = require('colorbuddy.group').groups
local colors = require('colorbuddy.color').colors

if vim and not vim.g.colorbuddy_disable_auto_import then
    require('colorbuddy.plugins')
end

local M = {
    groups = groups,
    Group = require('colorbuddy.group').Group,
    colors = colors,
    Color = require('colorbuddy.color').Color,
    styles = require('colorbuddy.style').styles,
}

--- Exports globals so you can use them in a script.
--- Optionally returns them if you'd prefer to use them that way.
M.setup = function()
    Color = M.Color
    c = M.colors

    Group = M.Group
    g = M.groups

    s = M.styles

    return Color, c, Group, g, s
end

return M
