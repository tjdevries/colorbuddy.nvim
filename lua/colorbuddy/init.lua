-- colorbuddy.vim
-- @author: TJ DeVries
-- Inspired HEAVILY by @tweekmonster's colorpal.vim

vim.fn = vim.fn or setmetatable({}, {
  __index = function(t, key)
    local function _fn(...)
      return vim.api.nvim_call_function(key, {...})
    end
    t[key] = _fn
    return _fn
  end
})



local groups = require('colorbuddy.group').groups
local colors = require('colorbuddy.color').colors

-- if vim then
--     require('colorbuddy.plugins')
-- end

local M = {
    groups = groups,
    Group = require('colorbuddy.group').Group,
    colors = colors,
    Color = require('colorbuddy.color').Color,
    styles = require('colorbuddy.style').styles,
}

--- Exports globals so you can use them in a script.
--- Optionally returns them if you'd prefer to use them that way.
function M.setup(settings)
    if vim and settings ~= nil and settings.override ~= true then require('colorbuddy.plugins') end

    Color = M.Color
    c = M.colors
    colors = M.colors

    Group = M.Group
    g = M.groups
    groups = M.groups

    s = M.styles
    styles = M.styles

    return Color, c, Group, g, s
end

function M.colorscheme(name, light)
    local bg
    if light then
        bg = 'light'
    else
        bg =  'dark'
    end

    vim.api.nvim_command('set termguicolors')
    vim.api.nvim_command(string.format('let g:colors_name = "%s"', name))
    vim.api.nvim_command(string.format('set background=%s', bg))

    require(name)
end

return M
