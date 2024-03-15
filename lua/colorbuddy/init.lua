-- colorbuddy.nvim
-- @author: TJ DeVries
-- Inspired originally by @tweekmonster's colorpal.vim

local group = require("colorbuddy.group")
local color = require("colorbuddy.color")

local M = {
  groups = group.groups,
  Group = group.Group,
  colors = color.colors,
  Color = color.Color,
  styles = require("colorbuddy.style").styles,
}

-- Returns the most common and useful items.
--  Probably don't even want this anymore... oh well.
function M.setup() end

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
end

return M
