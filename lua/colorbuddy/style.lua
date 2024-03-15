local key_concat = require("colorbuddy.util").key_concat

local __local_mt

local style_hash = {}
local find_style = function(_, name)
  if style_hash[string.lower(name)] ~= nil then
    return style_hash[string.lower(name)]
  end

  return {}
end

local styles = {}
local __styles_mt = {
  __metatable = {},
  __index = find_style,
}
setmetatable(styles, __styles_mt)

local style_tostring = function(self)
  return string.format("style:<%s>", self.name)
end

local private_create = function(values)
  return setmetatable({
    __type__ = "style",
    name = key_concat(values, " + "),
    values = values,
  }, __local_mt)
end

local style_add = function(left, right)
  local values = {}
  for index, _ in pairs(left.values) do
    values[index] = true
  end
  for index, _ in pairs(right.values) do
    values[index] = true
  end

  -- Never add styles.none to anything
  values[styles.none.name] = nil

  return private_create(values)
end

-- style.foo - style.bar
--      Should just remove style.bar from the set of style.foo
local style_sub = function(left, right)
  local values = {}
  -- Copy original set
  for index, _ in pairs(left.values) do
    values[index] = true
  end
  -- Remove subtracted items
  for index, _ in pairs(right.values) do
    values[index] = nil
  end

  -- if #values == 0 then return styles.none end
  local send_none = true
  for index, _ in pairs(values) do
    if values[index] then
      send_none = false
    end
  end

  -- Return final
  if send_none then
    return styles.none
  else
    return private_create(values)
  end
end

local Style = {}
__local_mt = {
  __metatable = {},
  __index = Style,
  __tostring = style_tostring,
  __add = style_add,
  __sub = style_sub,
}

Style.new = function(name)
  name = string.lower(name)
  local obj = private_create({ [name] = true })

  style_hash[name] = obj

  return obj
end

Style.to_vim = function(self)
  return key_concat(self.values, ",")
end

Style.keys = function(self)
  if self.values.none then
    return {}
  end

  return vim.deepcopy(self.values)
end

local is_style_object = function(s)
  if s == nil then
    return false
  end

  return s.__type__ == "style"
end

-- Setup the valid styles for vim and then lock down "styles"
Style.new("bold")
Style.new("underline")
Style.new("undercurl")
Style.new("strikethrough")
Style.new("reverse")
Style.new("inverse")
Style.new("italic")
Style.new("standout")
Style.new("nocombine")
Style.new("NONE")

return {
  styles = setmetatable({}, {
    __index = find_style,
    __newindex = function(_, k, _)
      error('Attempt to modify "styles", a read-only table, with: ' .. k)
    end,
  }),

  is_style_object = is_style_object,
}
