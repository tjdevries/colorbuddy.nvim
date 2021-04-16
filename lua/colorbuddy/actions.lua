local _c = require("colorbuddy.color")
local Color = require("colorbuddy.color").Color
local colors = require("colorbuddy.color").colors

local log = require("colorbuddy.log")

local actions = {}

actions.lighter = function()
  local updated = {}

  for _, c in pairs(colors) do
    if not updated[c] then
      updated = Color.modifier_apply(c, "light")
    end
  end
end

actions.darker = function()
  local updated = {}

  for _, c in pairs(colors) do
    if not updated[c] then
      updated = Color.modifier_apply(c, "dark")
    end
  end
end

return {
  actions = actions,
}
