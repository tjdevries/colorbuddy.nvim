
local colors = require('colorbuddy.color').colors
local next_color = require('colorbuddy.color')._next_color

local actions = {}

local apply_action = function(action_name)
  local updated = {}

  for _, c in next_color(colors) do
    if not updated[c] then
      local new_updates = c:modifier_apply(action_name)

      updated[c] = true
      for child, _ in pairs(new_updates) do
        updated[child] = true
      end
    end
  end
end

actions.lighter = function()
  apply_action('light')
end

actions.darker = function()
  apply_action('dark')
end

return actions
