-- TODO: Check out
--  - vim.api.nvim_get_color_map()
--  - vim.api.nvim_get_color_by_name()
--
-- These may allow some cool integrations.

local log = require("colorbuddy.log")
log.level = "debug"

local modifiers = require("colorbuddy.modifiers").modifiers
local util = require("colorbuddy.util")

local HSL = require("colorbuddy.data.hsl")
local RGB = require("colorbuddy.data.rgb")

local M = {}

---@class ColorbuddyMod
-- TODO
local _mod = {}

local special_colors = {
  none = "none",
  bg = "bg",
  background = "background",
  fg = "fg",
  foreground = "foreground",
}

---@class ColorbuddyColor
---@field name string: The name of the color (case insensitive)
---@field base ColorbuddyHSL: The base color, will be modified by `mods`.
---@field children ColorbuddyColor[]: The children of the color
---@field parent ColorbuddyColor?: Possible color
---@field mods ColorbuddyMod[]: List of modifications applied to this color
local Color = {}

--[[
Some Notes:
- ColorbuddyColor.base will not change regarldess of what modifiers
  are sent to the color. This value is immutable throughout the execution
  UNLESS a new color value is passed to represent this value.

  >>> x = Color.new('example', '#112233')
  >>> x:light()

  >>> -- x.base is unchanged.
  >>> x.base

  >>> Color.new('example', '#ffffff')
  >>> -- now the new base would be changed.

- ColorbuddyColor.mods will only be added / removed from when new
  modifiers are applied. This should make it very simple to calculate
  the "effective" color that a color is, and also simple to chain them
  together

--]]

local mt_colorstore = {
  __index = function(self, k)
    local original_k = k

    k = string.lower(k)

    local existing = rawget(self, k)
    if k then
      return existing
    else
      local nvim_color = vim.api.nvim_get_color_by_name(k)
      if nvim_color >= 0 then
        return Color.new(original_k, "#" .. bit.tohex(nvim_color, 6))
      end
    end

    return nil
  end,

  __newindex = function(self, k, v)
    rawset(self, string.lower(k), v)
  end,
}
local colors = setmetatable({}, mt_colorstore)

local current_color_idx = 0
local get_next_color_number = function()
  current_color_idx = current_color_idx + 1
  return current_color_idx
end

local color_arithmetic = function(operation)
  return function(left, right)
    assert(false, "color_arithmetic: not currently implemented")
    return create_new_color(nil, unpack(modifiers[operation](left.H, left.S, left.L, right, 1)))
  end
end

local mt_color = {
  __type__ = "color",
  __index = function(self, key)
    if Color[key] ~= nil then
      return Color[key]
    end

    -- Return what the modifiers would be if we ran it based on the table's values
    -- TODO(base)
    if modifiers[key] then
      return function(s_table, ...)
        if s_table == nil then
          return nil
        end

        local kiddo = s_table:new_child(s_table.name .. "-" .. tostring(get_next_color_number()), { key, ... })

        return kiddo
      end
    end

    return nil
  end,

  --- tostring for ColorbuddyColor
  ---@param self ColorbuddyColor:
  ---@return string
  __tostring = function(self)
    return string.format("[%s: %s]", self.name, tostring(self.base))
  end,

  -- FIXME: Determine what the basic arithmetic operators should do for colors...
  __add = color_arithmetic("add"),
  __sub = color_arithmetic("subtract"),
}

--- Create a new Color instance
---@param name string: Name of the new child
---@param base ColorbuddyHSL:
---@param mods any
---@return ColorbuddyColor
local function create_new_color(name, base, mods)
  -- if type(mods) == type({}) and mods ~= {} then
  --   base = M.Color.modifier_result(base, unpack(mods))
  -- end

  assert(type(name) == "string", "name must be a string")
  assert(HSL.is_hsl(base), "base must be an HSL value" .. vim.inspect(base))

  if mods then
    assert(type(mods) == "table", "mods must be a table or nil")
  end

  return setmetatable({
    __type__ = "color",
    name = name,
    base = base,
    mods = mods,

    -- Objects that depend on what this color is
    --  When "self" is changed, we update the attributes of these colors.
    --  See: |modifier_apply|
    children = {},

    -- TODO: Maybe make more than one of these?
    -- The parent of this object
    --  When "self" is changed, we wait until these have been updated
    parent = {},
  }, mt_color)
end

--- Create a new color
---@param name string: Name of the new child
---@param base string|ColorbuddyHSL|ColorbuddyColor: The base color information
---@param mods ColorbuddyMod[]: List of modifications
---@return ColorbuddyColor
function Color.new(name, base, mods)
  -- Color:
  --  name
  --  H, S, L
  --  children: A table of all the colors that depend on this color

  if base == nil then
    assert(special_colors[name], "Only allowed to pass `nil` color when special")

    -- TODO: Change this to add_special_color
    local obj = setmetatable({
      __type__ = "color",
      name = name,
      children = {},
      -- TODO: self.base?
    }, mt_color)

    colors[obj.name] = obj

    return obj
  end

  ---@type ColorbuddyHSL
  local hsl

  if type(base) == "string" then
    log.debug("Generating HSL from rgb string: ", name, base)
    hsl = HSL:from_rgb(RGB:from_string(base))
    print(hsl)
  elseif HSL.is_hsl(base) then
    hsl = base
  else
    error("We haven't implemented this other thing yet")
  end

  -- Get an existing color if possible, so that we can update any references to this color
  -- when you use something like 'Color.new('red', ...)' twice

  ---@type ColorbuddyColor
  local object

  if colors[name] then
    log.debug("Updating existing color...", name, hsl)
    object = colors[name]

    -- Update object in place
    object.base = hsl
    object.mods = mods

    -- Update any children
    for child, _ in pairs(object.children) do
      log.debug("Updating child:", child)

      assert(child.update, "All children must be ColorbuddyColor")
      child:update()
    end
  else
    log.debug("Creating new color...", name, hsl)
    object = create_new_color(name, hsl, mods)
    log.debug("... Created")
    colors[object.name] = object
  end

  return object
end

--- Returns the effective color as a string #RRGGBB or special name
---@return string
function Color:to_vim()
  if special_colors[self.name] then
    return special_colors[self.name]
  end

  local hsl = self:to_hsl()
  return RGB:from_hsl(hsl):to_vim()
end

--- Returns the effective HSL value
---@return ColorbuddyHSL
function Color:to_hsl()
  -- return { self.H, self.S, self.L }
  return self:modifier_result(self.mods)
end

--- Apply all the modifiers on a base
function Color:modifier_result(mods)
  if true then
    return self.base
  end

  -- Accepts arguments of:
  --  string: The name of a modifier for a color
  --  table: the {name, [arguments]} of a modifier
  local hsl_table = self.base

  -- TODO: add self.mods as well?
  for i, current_modifier in ipairs(mods) do
    if type(current_modifier) == "string" then
      if modifiers[current_modifier] ~= nil then
        log.debug("Applying string: ", i, current_modifier)
        hsl_table = modifiers[current_modifier](unpack(hsl_table))
      else
        error(string.format('Invalid key: "%s". Please use a valid key', current_modifier))
      end
    elseif type(current_modifier) == "table" then
      local modifier_key = current_modifier[1]
      local modifier_arguments = util.tbl_slice(current_modifier, 2)

      if modifiers[modifier_key] ~= nil then
        local new_arg_table = util.tbl_extend(hsl_table, modifier_arguments)
        hsl_table = modifiers[modifier_key](unpack(new_arg_table))
      else
        error(string.format('Invalid key: "%s". Please use a valid key', modifier_key))
      end
    end
  end

  return hsl_table
end

Color.modifier_apply = function(self, ...)
  if true then
    return self
  end

  log.debug("Applying Modifier for:", self.name, " / ", ...)

  local new_hsl = self:modifier_result(...)
  self.H, self.S, self.L = unpack(new_hsl)

  -- Update all of the children.
  local updated = {}

  for child, _ in pairs(self.children) do
    if child.update ~= nil then
      child:update(updated)
    else
      log.warn("No update method found for:", child)
      log.warn("TYPE WAS: ", child.__type__)
    end
  end
  -- FIXME: Check for loops within the children.
  -- FIXME: Call an event to update any color groups

  return updated
end

Color._add_child = function(self, child)
  self.children[child] = true
  child.parent = self
end

--- Create a new child of the current color
---@param name string: Name of the new child
---@param ... any
---@return ColorbuddyColor
function Color:new_child(name, ...)
  if self.children[string.lower(name)] ~= nil then
    print("ERROR: must not use same name")
    return nil
  end

  log.debug("New Child: ", self, name, ...)

  -- TODO: This might not be right, because it won't apply original modifiers to base
  local kid = Color.new(name, self.base, ...)
  self:_add_child(kid)

  return kid
end

--- Update a color and all of its dependencies
---@param updated table|nil: A map of colors that have been updated.
---@return table: A map of colors that have been updated (can be `updated` if passed)
function Color:update(updated)
  if updated == nil then
    updated = {}
  end

  if updated[self] then
    return
  end

  updated[self] = true

  self.H = self.parent.H
  self.S = self.parent.S
  self.L = self.parent.L

  if type(self.mods) == type({}) then
    self:modifier_apply(unpack(self.mods))
  end

  return updated
end

M.is_color_object = function(c)
  if c == nil or type(c) ~= "table" then
    return false
  end

  return getmetatable(c) == mt_color
end

M._clear_colors = function()
  colors = setmetatable({}, mt_colorstore)
end

M.Color = Color
M.colors = colors

Color.new("none")
Color.new("gray0", "#282c34")
Color.new("gray1", "#282a2e")
Color.new("gray2", "#373b41")
Color.new("gray3", "#969896")
Color.new("gray4", "#b4b7b4")
Color.new("gray5", "#c5c8c6")
Color.new("gray6", "#e0e0e0")
Color.new("gray7", "#ffffff")

-- TODO: Could use this for the modifiers
-- local next_color = function(tbl)
--   local stateless_iterator = function(tbl, k)
--     local v
--     k, v = next(color_hash, k)
--
--     if k == "none" then
--       k, v = next(color_hash, k)
--     end
--
--     while k and string.find(k, "__") == 1 do
--       k, v = next(color_hash, k)
--     end
--
--     if v ~= nil then
--       return k, v
--     end
--   end
--
--   return stateless_iterator, tbl, nil
-- end

return M
