local colors = require("colorbuddy.color").colors

local actions = {}

local global_apply = function(modifier)
  local updated = {}

  for _, c in pairs(colors) do
    if not updated[c] then
      -- Get to the root of all the nodes
      local val = c
      while val.parent do
        val = val.parent
      end

      if not updated[val] then
        vim.tbl_extend("force", updated, val:modifier_apply({ modifier }, updated))
      end

      assert(updated[c], "must have encountered color at some point")
    end
  end
end

actions.lighter = function()
  global_apply("light")
end

actions.darker = function()
  global_apply("dark")
end

return actions
