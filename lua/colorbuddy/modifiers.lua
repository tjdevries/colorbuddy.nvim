local log = require("colorbuddy.log")
local util = require("colorbuddy.util")

local operator_intensity = function(operand)
  local supported_metamethods = {
    ["-"] = true,
    ["+"] = true,
  }
  local operand_metamethod = supported_metamethods[operand]

  if operand_metamethod == nil then
    return nil
  end

  return function(H, S, L, color_object, intensity)
    if color_object == nil then
      return { H, S, L }
    end

    if intensity == nil then
      intensity = 1.0
    end

    local original = { util.hsl_to_rgb(H, S, L) }
    local mixin = { util.hsl_to_rgb(color_object.H, color_object.S, color_object.L) }

    local result_rgb = { 0, 0, 0 }
    for i, _ in ipairs(result_rgb) do
      if operand == "-" then
        result_rgb[i] = util.clamp(original[i] - (intensity * mixin[i]), 0, 1)
      elseif operand == "+" then
        result_rgb[i] = util.clamp(original[i] + (intensity * mixin[i]), 0, 1)
      end

      log.debug("subt:", original[i], mixin[i], "res", result_rgb[i])
    end

    return { util.rgb_to_hsl(unpack(result_rgb)) }
  end
end

-- Modifier table
-- Must have signature of (H, S, L, ...)
-- and then return {H, S, L}
local modifiers = {}
modifiers.dark = function(H, S, L, amount)
  if amount == nil or amount == {} then
    amount = 0.1
  end

  return { H, S, math.max(0, L - amount) }
end

modifiers.light = function(H, S, L, amount)
  if amount == nil then
    amount = 0.1
  end

  return { H, S, L + amount }
end

modifiers.saturate = function(H, S, L, amount)
  if amount == nil then
    amount = 0.1
  end

  return { H, S + amount, L }
end

modifiers.subtract = function(H, S, L, color_object, intensity)
  return operator_intensity("-")(H, S, L, color_object, intensity)
end

modifiers.add = function(H, S, L, color_object, intensity)
  return operator_intensity("+")(H, S, L, color_object, intensity)
end

modifiers.negative = function(H, S, L)
  local rgb = { util.hsl_to_rgb(H, S, L) }

  return { util.rgb_to_hsl(1 - rgb[1], 1 - rgb[2], 1 - rgb[3]) }
end

modifiers.average = function(H, S, L, color_object)
  local r1, g1, b1, r2, g2, b2

  if H == nil then
    log.warn("Passed H was nil", H, S, L)
    return H, S, L
  end

  r1, g1, b1 = util.hsl_to_rgb(H, S, L)

  if color_object.H == nil then
    log.warn("H was nil", unpack(color_object))
    return { H, S, L }
  elseif color_object.S == nil then
    log.warn("S was nil", unpack(color_object))
    return { H, S, L }
  elseif color_object.L == nil then
    log.warn("L was nil", unpack(color_object))
    return { H, S, L }
  end

  r2, g2, b2 = util.hsl_to_rgb(color_object.H, color_object.S, color_object.L)

  r1 = r1 * 255
  g1 = g1 * 255
  b1 = b1 * 255
  r2 = r2 * 255
  g2 = g2 * 255
  b2 = b2 * 255

  local r_average = ((r1 ^ 2 + r2 ^ 2) / 2) ^ (1 / 2) / 255
  local g_average = ((g1 ^ 2 + g2 ^ 2) / 2) ^ (1 / 2) / 255
  local b_average = ((b1 ^ 2 + b2 ^ 2) / 2) ^ (1 / 2) / 255

  -- local r_average = math.floor(((r1^2 + r2^2) / 2)^(1/2)) / 255
  -- local g_average = math.floor(((g1^2 + g2^2) / 2)^(1/2)) / 255
  -- local b_average = math.floor(((b1^2 + b2^2) / 2)^(1/2)) / 255

  return { util.rgb_to_hsl(r_average, g_average, b_average) }
end

modifiers.complement = function(H, S, L)
  return { (180.0 + H) % 360, S, L }
end

return {
  modifiers = modifiers,
}
