local nvim = vim.api

local log_module = require("colorbuddy.lua_html.log")
local log = log_module.log

local __syntax_group_mt = {
  __index = function(obj, key)
    if key == "_" then
      return rawget(obj, "_")
    end

    if obj._[key] == nil then
      log("... accessing neovim // ", obj.name, "//", key)
      obj._[key] = nvim.nvim_call_function("synIDattr", { rawget(obj, "synID"), key, "gui" })
    end

    return obj._[key]
  end,
}

local SyntaxGroup = {}
SyntaxGroup.new = function(self, synID)
  log("making new syntax group:", synID)
  local obj = {
    synID = synID,
    _ = {
      name = nvim.nvim_call_function("synIDattr", { synID, "name", "gui" }),
    },
  }

  return setmetatable(obj, __syntax_group_mt)
end

return SyntaxGroup
