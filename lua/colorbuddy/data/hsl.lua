local util = require("colorbuddy.util")

---@class ColorbuddyHSL
---@field H number: Hue, 0-359 (cannot be 360, wraps around)
---@field S number: Saturation, 0.0 - 1.0, (0 is gray, 1 is full saturation)
---@field L number: Lightness, 0.0 - 1.0 (0 is black, 1 is white)
local HSL = {}

HSL.__index = HSL
HSL.__tostring = function(self)
  return string.format("hsl(%s, %s, %s)", self.H, util.fmt_percent(self.S), util.fmt_percent(self.L))
end

function HSL:new(h, s, l)
  assert(util.between(h, 0, 360), "h must be between 0 and 360")
  assert(util.between(s, 0, 1), "s must be between 0 and 1")
  assert(util.between(l, 0, 1), "l must be between 0 and 1")

  if h == 360 then
    h = 0
  end

  return setmetatable({
    H = h,
    S = s,
    L = l,
  }, self)
end

function HSL.is_hsl(val)
  return val and type(val) == "table" and getmetatable(val) == HSL
end

--- Create a new HSL from an RGB type
---@param rgb ColorbuddyRGB: RGB value (already validated)
---@return ColorbuddyHSL
function HSL:from_rgb(rgb)
  local r = rgb.r
  local g = rgb.g
  local b = rgb.b

  local min = math.max(math.min(r, g, b), 0)
  local max = math.min(math.max(r, g, b), 1)
  local delta = max - min

  local h, s, l = 0, 0, ((min + max) / 2)

  -- Achromatic, can skip the rest
  if max == min then
    return HSL:new(max * 360, 0, l)
  end

  if l < 0.5 then
    s = delta / (max + min)
  else
    s = delta / (2 - max - min)
  end

  if delta > 0 then
    -- if max == r and max ~= g then h = h + (g-b)/delta end

    if max == r then
      h = (g - b) / delta
      if g < b then
        h = h + 6
      end
    elseif max == g then
      h = 2 + (b - r) / delta
    elseif max == b then
      h = 4 + (r - g) / delta
    end
    h = h / 6
  end

  if h < 0 then
    h = h + 1
  end
  if h > 1 then
    h = h - 1
  end

  -- return math.floor(h * 360), s, l
  assert(util.between(h, 0, 1), "h must not be negative by now")
  assert(util.between(s, 0, 1), "s must be between 0 and 1")
  assert(util.between(l, 0, 1), "l must be between 0 and 1")
  return self:new(h * 360, s, l)
end

--- Return an HSL from a #RRGGBB string
---@param str string
---@return ColorbuddyHSL
function HSL:from_vim(str)
  return HSL:from_rgb(require("colorbuddy.data.rgb"):from_string(str))
end

--- Convert HSL to #RRGGBB string
---@return string
function HSL:to_vim()
  return require("colorbuddy.data.rgb"):from_hsl(self):to_vim()
end

return HSL
