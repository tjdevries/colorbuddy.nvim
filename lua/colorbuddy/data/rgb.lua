local util = require("colorbuddy.util")

---@class ColorbuddyRGB
---@field r number: red value: 0.0 - 1.0
---@field g number: green value: 0.0 - 1.0
---@field b number: blue value: 0.0 - 1.0
local RGB = {}
RGB.__index = RGB

--- Create an RGB from rgb values
---@param r number: 0.0 - 1.0
---@param g number: 0.0 - 1.0
---@param b number: 0.0 - 1.0
---@return ColorbuddyRGB
function RGB:new(r, g, b)
  assert(util.between(r, 0, 1), "r must be between 0 and 1")
  assert(util.between(g, 0, 1), "g must be between 0 and 1")
  assert(util.between(b, 0, 1), "b must be between 0 and 1")

  return setmetatable({
    r = r,
    g = g,
    b = b,
  }, self)
end

function RGB:from_string(str)
  assert(str:sub(1, 1) == "#", "string color: improperly formatted #RRGGBB")
  assert(str:len() == 7, "string color: improper length, must be 7")

  return RGB:new(
    tonumber(str:sub(2, 3), 16) / 255,
    tonumber(str:sub(4, 5), 16) / 255,
    tonumber(str:sub(6, 7), 16) / 255
  )
end

function RGB.is_rgb(val)
  return val and type(val) == "table" and getmetatable(val) == RGB
end

--- Create a new RGB type from an HSL type
---@param hsl ColorbuddyHSL
function RGB:from_hsl(hsl)
  local h = assert(hsl.H, "Must have H")
  local s = assert(hsl.S, "Must have S")
  local l = assert(hsl.L, "Must have L")

  -- h = (h % 360) / 360
  h = (h / 360) % 1

  if s == 0 then
    -- Achromatic result
    return RGB:new(l, l, l)
  end

  local m1, m2
  if l <= 0.5 then
    m2 = l * (s + 1)
  else
    m2 = (l + s) - (l * s)
  end

  m1 = l * 2 - m2

  local function hue_to_rgb(p, q, hue)
    if hue < 0 then
      hue = hue + 1
    end
    if hue > 1 then
      hue = hue - 1
    end

    if hue < 1 / 6 then
      return p + (q - p) * hue * 6
    end
    if hue < 1 / 2 then
      return q
    end
    if hue < 2 / 3 then
      return p + (q - p) * (2 / 3 - hue) * 6
    end
    return p
  end

  return RGB:new(
    util.clamp(hue_to_rgb(m1, m2, h + 1 / 3), 0, 1),
    util.clamp(hue_to_rgb(m1, m2, h), 0, 1),
    util.clamp(hue_to_rgb(m1, m2, h - 1 / 3), 0, 1)
  )
end

local round = function(x)
  return math.floor(x + 0.5)
end

--- Take an RGB value and convert a vim value of #RRGGBB
function RGB:to_vim()
  -- TODO(limits)
  return string.format("#%02x%02x%02x", round(self.r * 255), round(self.g * 255), round(self.b * 255))
end

return RGB
