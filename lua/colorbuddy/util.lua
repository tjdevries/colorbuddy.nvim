-- TODO: Use newer `vim.tbl_` methods when I get a chance.

-- Pretty much all of the util functions come from:
--      https://github.com/yuri/lua-colors/blob/master/lua/colors.lua
local util = {}

util.tbl_slice = function(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced + 1] = tbl[i]
  end

  return sliced
end

util.tbl_extend = function(t1, t2)
  local t3 = {}
  for i = 1, #t1 do
    t3[i] = t1[i]
  end

  for i = 1, #t2 do
    t3[#t1 + i] = t2[i]
  end

  return t3
end

util.rgb_string_to_hsl = function(rgb)
  return util.rgb_to_hsl(
    tonumber(rgb:sub(2, 3), 16) / 255,
    tonumber(rgb:sub(4, 5), 16) / 255,
    tonumber(rgb:sub(6, 7), 16) / 255
  )
end

--- Converts an RGB triplet to HSL.
-- (see http://easyrgb.com)
--
-- @param r              red (0.0-1.0)
-- @param g              green (0.0-1.0)
-- @param b              blue (0.0-1.0)
-- @return               corresponding H, S and L components
util.rgb_to_hsl = function(r, g, b)
  r = r or 0
  g = g or 0
  b = b or 0

  local min = math.max(math.min(r, g, b), 0)
  local max = math.min(math.max(r, g, b), 1)
  local delta = max - min

  local h, s, l = 0, 0, ((min + max) / 2)

  -- Achromatic, can skip the rest
  if max == min then
    return max * 359, 0, l
  end

  if l < 0.5 then
    s = delta / (max + min)
  end
  if l >= 0.5 then
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
  return h * 360, s, l
end

--- Converts an HSL triplet to RGB
-- (see http://homepages.cwi.nl/~steven/css/hsl.html).
--
-- @param H              hue (0-359)
-- @param S              saturation (0.0-1.0)
-- @param L              lightness (0.0-1.0)
-- @return               an R, G, and B component of RGB
util.hsl_to_rgb = function(h, s, L)
  -- h = (h % 360) / 360
  h = (h / 360) % 1

  if s == 0 then
    -- Achromatic result
    return L, L, L
  end

  local m1, m2
  if L <= 0.5 then
    m2 = L * (s + 1)
  else
    m2 = (L + s) - (L * s)
  end

  m1 = L * 2 - m2

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

  return util.clamp(hue_to_rgb(m1, m2, h + 1 / 3), 0, 1),
    util.clamp(hue_to_rgb(m1, m2, h), 0, 1),
    util.clamp(hue_to_rgb(m1, m2, h - 1 / 3), 0, 1)
end

util.hsl_to_rgb_string = function(H, S, L)
  local r, g, b = util.hsl_to_rgb(H, S, L)

  r = r * 255
  g = g * 255
  b = b * 255

  return string.format("#%02x%02x%02x", r, g, b)
end

util.clamp = function(val, min, max)
  if val >= min and val <= max then
    return val
  end
  if val < min then
    return min
  end
  if val > max then
    return max
  end
end

util.key_concat = function(t, str)
  local key_table = {}
  local index = 1

  for key, _ in pairs(t) do
    key_table[index] = key
    index = index + 1
  end

  table.sort(key_table)
  return table.concat(key_table, str)
end

util.between = function(val, low, high)
  assert(type(val) == "number", "can only pass numbers to between")
  return val >= low and val <= high
end

util.fmt_percent = function(val)
  assert(util.between(val, 0, 1), "percentages have to be between 0 and 1")
  return string.format("%0.2f%%", val * 100)
end

util.round = function(val)
  return math.floor(val + 0.5)
end

util.toHex = (function()
  local ok, bit = pcall(require, "bit")
  if ok then
    return bit.tohex
  else
    return function(num, width)
      if num == 0 then
        return string.rep("0", width)
      end

      local hexChars = "0123456789abcdef"
      local hex = ""
      local remainder
      while num > 0 do
        remainder = num % 16
        hex = string.sub(hexChars, remainder + 1, remainder + 1) .. hex
        num = math.floor(num / 16)
      end

      if #hex < width then
        hex = string.rep("0", width - #hex) .. hex
      end

      return hex
    end
  end
end)()

return util
