local Color = require("colorbuddy.color").Color
local colors = require("colorbuddy.color").colors

local actions = {}

actions.lighter = function()
  local updated = {}

  for _, c in pairs(colors) do
    if not updated[c] then
      vim.tbl_extend("force", updated, c:modifier_apply("light"))
    end
  end
end

actions.darker = function()
  local updated = {}

  for _, c in pairs(colors) do
    if not updated[c] then
      vim.tbl_extend("force", updated, Color.modifier_apply(c, "light"))
    end
  end
end

return actions
