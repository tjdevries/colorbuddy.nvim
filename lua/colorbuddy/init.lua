-- colorbuddy.vim
-- @author: TJ DeVries
-- Inspired HEAVILY by @tweekmonster's colorpal.vim

vim.fn = vim.fn
  or setmetatable({}, {
    __index = function(t, key)
      local function _fn(...)
        return vim.api.nvim_call_function(key, { ... })
      end
      t[key] = _fn
      return _fn
    end,
  })

local groups = require("colorbuddy.group").groups
local colors = require("colorbuddy.color").colors

local M = {
  groups = groups,
  Group = require("colorbuddy.group").Group,
  colors = colors,
  Color = require("colorbuddy.color").Color,
  styles = require("colorbuddy.style").styles,
}

-- Returns the most common and useful items.
--  Probably don't even want this anymore... oh well.
function M.setup()
  return M.Color, M.colors, M.Group, M.groups, M.styles
end

function M.colorscheme(name, light, opts)
  opts = opts or {}

  if not opts.disable_defaults then
    require("colorbuddy.plugins")
  end

  local bg
  if light then
    bg = "light"
  else
    bg = "dark"
  end

  vim.api.nvim_command("set termguicolors")
  vim.api.nvim_command(string.format('let g:colors_name = "%s"', name))
  vim.api.nvim_command(string.format("set background=%s", bg))

  local ok = pcall(require, name)
  if not ok then
    vim.api.nvim_command(string.format("colorscheme %s", name))
  end
end

return M
