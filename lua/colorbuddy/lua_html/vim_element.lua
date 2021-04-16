local attributes = {
  name = true,
  fg = true,
  bg = true,
  font = true,
  sp = true,
  ["fg#"] = true,
  ["bg#"] = true,
  bold = true,
  italic = true,
  reverse = true,
  inverse = true,
  standout = true,
  underline = true,
  undercurl = true,
}

local __vim_element_mt = {
  __index = function(self, key)
    if rawget(self, key) ~= nil then
      return rawget(self, key)
    end

    if attributes[key] ~= nil then
      return rawget(self, "syntax_attribute")[key]
    end

    return nil
  end,
}

local VimElement = {}

VimElement.new = function(self, line, start_column, end_column, text, syntax_attribute)
  return setmetatable({
    line = line,
    start_column = start_column,
    end_column = end_column,
    text = text,
    syntax_attribute = syntax_attribute,
  }, __vim_element_mt)
end

return VimElement
