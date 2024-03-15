-- TODO: Check out
--  - vim.api.nvim_get_color_map()
--  - vim.api.nvim_get_color_by_name()
--
-- These may allow some cool integrations.

local log = require("colorbuddy.log")

local modifiers = require("colorbuddy.modifiers").modifiers
local util = require("colorbuddy.util")

local HSL = require("colorbuddy.data.hsl")
local RGB = require("colorbuddy.data.rgb")

local create_new_color
local M = {}

---@class ColorbuddyMod
local _mod = {}

---@class ColorbuddyColor
---@field name string: The name of the color (case insensitive)
---@field base ColorbuddyHSL: The base color, will be modified by `mods`
---@field children table<ColorbuddyColor, boolean>: The children of the color
---@field parent ColorbuddyColor|nil: Possible color
---@field mods ColorbuddyMod[]: List of modifications applied to this color
---[[ Modifiers, wish it was auto generated ]]
---@field light function: Ligthen the current color and children
---@field dark function: Ligthen the current color and children
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
    if existing then
      return existing
    else
      local nvim_color = vim.api.nvim_get_color_by_name(k)
      if nvim_color >= 0 then
        local new_color = create_new_color(original_k, HSL:from_vim("#" .. util.toHex(nvim_color, 6)))
        rawset(self, k, new_color)
        return new_color
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
    return create_new_color(
      left.name .. "-" .. tostring(get_next_color_number()),
      modifiers[operation](left:to_hsl(), right, 1)
    )
  end
end

local banned_access = { H = true, S = true, L = true }

local mt_color = {
  __type__ = "color",
  __index = function(self, key)
    if banned_access[key] then
      error("BANNED ACCESS. BREAKING CHANGES:" .. key)
    end

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
create_new_color = function(name, base, mods)
  -- if type(mods) == type({}) and mods ~= {} then
  --   base = M.Color.modifier_result(base, unpack(mods))
  -- end

  mods = mods or {}

  assert(type(name) == "string", "name must be a string")
  assert(type(mods) == "table", "mods must be a table or nil")
  assert(HSL.is_hsl(base), "base must be an HSL value" .. vim.inspect(base))

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
    parent = nil,
  }, mt_color)
end

--- Create a new color
---@param name string: Name of the new child
---@param base string|ColorbuddyHSL|ColorbuddyColor: The base color information
---@param mods? ColorbuddyMod[]: List of modifications
---@return ColorbuddyColor
function Color.new(name, base, mods)
  -- Color:
  --  name
  --  H, S, L
  --  children: A table of all the colors that depend on this color

  -- Special case `none`, as it removes the value
  if name == "none" then
    -- TODO: Change this to add_special_color
    local obj = setmetatable({
      __type__ = "color",
      name = name,
      children = {},
      mods = {},
      -- TODO: self.base?
    }, mt_color)

    colors[obj.name] = obj

    return obj
  end

  ---@type ColorbuddyHSL
  local hsl

  if type(base) == "string" then
    log.debug("Generating HSL from rgb string: ", name, base)
    hsl = HSL:from_vim(base)
  elseif HSL.is_hsl(base) then
    hsl = base
  else
    error("We haven't implemented this other thing yet")
  end

  -- Get an existing color if possible, so that we can update any references to this color
  -- when you use something like 'Color.new('red', ...)' twice
  mods = mods or {}

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
  -- None must be sent back exactly as "none"
  if self.name == "none" then
    return self.name
  end

  local hsl = self:to_hsl()
  local rgb = RGB:from_hsl(hsl)
  return rgb:to_vim()
end

--- Apply modifiers to an hsl
---@param hsl ColorbuddyHSL
---@param mods ColorbuddyMod[]
---@return ColorbuddyHSL
local function apply_modifiers(hsl, mods)
  local result = hsl
  for _, mod in ipairs(mods) do
    if type(mod) == "string" then
      if modifiers[mod] then
        result = modifiers[mod](result)
      else
        error(string.format('Invalid modifier: "%s". Please use a valid modifier', mod))
      end
    elseif type(mod) == "table" then
      local modifier_key = mod[1]
      local modifier_arguments = util.tbl_slice(mod, 2)

      if modifiers[modifier_key] ~= nil then
        result = modifiers[modifier_key](result, unpack(modifier_arguments))
      else
        error(string.format('Invalid modifier: "%s". Please use a valid modifier', modifier_key))
      end
    else
      -- print("Unsupported modifier type" .. vim.inspect(mod))
    end
  end

  return result
end

--- Returns the effective HSL value
---@return ColorbuddyHSL
function Color:to_hsl()
  if not self.mods then
    error("Must have mods:" .. vim.inspect(self))
  end

  -- Collect all the parent mods, then ours and then apply
  local mods = {}
  local parent = self.parent
  while parent do
    vim.list_extend(mods, parent.mods)
    parent = parent.parent
  end

  vim.list_extend(mods, self.mods)

  return apply_modifiers(self.base, mods)
end

--- Apply modifiers to the current color and its children
---@param mods ColorbuddyMod[]: List of modifications
---@return table: List of colors updated (to prevent modifying multiple times)
function Color:modifier_apply(mods, updated)
  updated = updated or {}
  if updated[self] then
    return updated
  end

  log.debug("Applying Modifier for:", self.name, " / ", mods)
  updated[self] = true
  for _, mod in ipairs(mods) do
    table.insert(self.mods, mod)
  end

  for child, _ in pairs(self.children) do
    child:modifier_apply({}, updated)
  end

  return updated
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

  if self.parent then
    self.base = self.parent.base
  end

  for child, _ in pairs(self.children) do
    child:update(updated)
  end

  return updated
end

Color._add_child = function(self, child)
  self.children[child] = true
  child.parent = self
end

--- Create a new child of the current color
---@param name string: Name of the new child
---@param mods ColorbuddyMod[]: List of modifications
---@return ColorbuddyColor
function Color:new_child(name, mods)
  if self.children[string.lower(name)] ~= nil then
    error("new_child must not re-use an existing name?")
    return nil
  end

  log.debug("New Child: ", name, "with", mods)

  -- TODO: This might not be right, because it won't apply original modifiers to base
  -- local resulting_mods = {}
  -- vim.list_extend(resulting_mods, self.mods)
  -- vim.list_extend(resulting_mods, mods)

  local kid = Color.new(name, self.base, mods)
  self:_add_child(kid)

  return kid
end

M.is_color_object = function(c)
  if c == nil or type(c) ~= "table" then
    return false
  end

  if getmetatable(c) == mt_color then
    return true
  end

  if c.__type__ == "color" then
    log.info("COLOR CHECK")
    return true
  end

  return false
end

M._clear_colors = function()
  for k, _ in pairs(colors) do
    rawset(colors, k, nil)
  end
end

M.Color = Color
M.colors = colors

Color.new("none")
Color.new("gray0", "#111111")
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
