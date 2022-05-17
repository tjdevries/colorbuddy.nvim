-- TODO: Switch over to `.base` and use HSL directly

local log = require("colorbuddy.log")
local util = require("colorbuddy.util")
local HSL = require("colorbuddy.data.hsl")
local RGB = require("colorbuddy.data.rgb")

local operator_intensity = function(operator)
  local supported_metamethods = {
    ["-"] = true,
    ["+"] = true,
  }
  local operand_metamethod = supported_metamethods[operator]

  if operand_metamethod == nil then
    return nil
  end

  local doit = function(origin, mixin, intensity)
    if operator == "-" then
      return util.clamp(origin - (intensity * mixin), 0, 1)
    elseif operator == "+" then
      return util.clamp(origin + (intensity * mixin), 0, 1)
    end

    error("unsupported operator")
  end

  --- Modifier function
  ---@param hsl ColorbuddyHSL
  ---@param operand ColorbuddyColor
  ---@param intensity number|nil
  ---@return ColorbuddyHSL
  return function(hsl, operand, intensity)
    if operand == nil then
      return hsl
    end

    if intensity == nil then
      intensity = 1.0
    end

    local original = RGB:from_hsl(hsl)
    local operand_hsl = operand:to_hsl()
    local mixin = RGB:from_hsl(operand_hsl)

    local resulting_rgb = RGB:new(
      doit(original.r, mixin.r, intensity),
      doit(original.g, mixin.g, intensity),
      doit(original.b, mixin.b, intensity)
    )

    return HSL:from_rgb(resulting_rgb)
  end
end

-- Modifier table
-- Must have signature of (ColorbuddyHSL, ...)
-- and then return ColorbuddyHSL

local modifiers = {}

--- Darken a color
---@param hsl ColorbuddyHSL
---@param amount number|nil: Amount to darken
---@return ColorbuddyHSL
modifiers.dark = function(hsl, amount)
  if amount == nil or amount == {} then
    amount = 0.1
  end

  return HSL:new(hsl.H, hsl.S, math.max(0, hsl.L - amount))
end

--- Lighten a color
---@param hsl ColorbuddyHSL
---@param amount number|nil: Amount to lighten
---@return ColorbuddyHSL
modifiers.light = function(hsl, amount)
  if amount == nil then
    amount = 0.1
  end

  return HSL:new(hsl.H, hsl.S, math.min(1, hsl.L + amount))
end

--- Lighten a color
---@param hsl ColorbuddyHSL
---@param amount number|nil: Amount to saturate
---@return ColorbuddyHSL
modifiers.saturate = function(hsl, amount)
  if amount == nil then
    amount = 0.1
  end

  return HSL:new(hsl.H, util.clamp(hsl.S + amount, 0, 1), hsl.L)
end

modifiers.subtract = function(hsl, color_object, intensity)
  return operator_intensity("-")(hsl, color_object, intensity)
end

modifiers.add = function(hsl, color_object, intensity)
  return operator_intensity("+")(hsl, color_object, intensity)
end

modifiers.negative = function(hsl)
  local rgb = RGB:from_hsl(hsl)
  local neg = RGB:new(1 - rgb.r, 1 - rgb.g, 1 - rgb.b)
  return HSL:from_rgb(neg)
end

---comment
---@param left ColorbuddyHSL
---@param right ColorbuddyHSL
---@return ColorbuddyHSL
modifiers.average = function(left, right)
  local left_rgb = RGB:from_hsl(left)
  local right_rgb = RGB:from_hsl(right)

  local r1, g1, b1 = left_rgb.r, left_rgb.g, left_rgb.b
  local r2, g2, b2 = right_rgb.r, right_rgb.g, right_rgb.b

  r1 = r1 * 255
  g1 = g1 * 255
  b1 = b1 * 255
  r2 = r2 * 255
  g2 = g2 * 255
  b2 = b2 * 255

  local r_average = ((r1 ^ 2 + r2 ^ 2) / 2) ^ (1 / 2) / 255
  local g_average = ((g1 ^ 2 + g2 ^ 2) / 2) ^ (1 / 2) / 255
  local b_average = ((b1 ^ 2 + b2 ^ 2) / 2) ^ (1 / 2) / 255

  return HSL:from_rgb(RGB:new(r_average, g_average, b_average))
end

modifiers.complement = function(hsl)
  return HSL:new((180 + hsl.H) % 360, hsl.S, hsl.L)
end

return {
  modifiers = modifiers,
}
