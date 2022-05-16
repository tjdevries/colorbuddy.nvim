local Color = require("colorbuddy.color").Color
local colors = require("colorbuddy.color")._color_hash

local actions = {}

actions.lighter = function()
  local updated = {}

  print("lighter...")
  for _, c in pairs(colors) do
    if not updated[c] then
      vim.tbl_extend("force", updated, c:modifier_apply("light"))
    end
  end

  print("... done")
  print("____")
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
