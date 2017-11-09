-- Some table setup... as always
-- luacheck: globals table.extend
-- luacheck: globals table.slice

table.slice = function(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

table.extend = function(t1, t2)
    local t3 = {}
    for i = 1,#t1 do
        t3[i] = t1[i]
    end

    for i = 1,#t2 do
        t3[#t1 + i] = t2[i]
    end

    return t3
end


-- Pretty much all of the util functions come from:
--      https://github.com/yuri/lua-colors/blob/master/lua/colors.lua
local util = {}

util.rgb_string_to_hsl = function(rgb)
    return util.rgb_to_hsl(
        tonumber(rgb:sub(2, 3), 16)  /256
        , tonumber(rgb:sub(4, 5), 16) / 256
        , tonumber(rgb:sub(6, 7), 16)  /256
    )
end

-----------------------------------------------------------------------------
-- Converts an RGB triplet to HSL.
-- (see http://easyrgb.com)
--
-- @param r              red (0.0-1.0)
-- @param g              green (0.0-1.0)
-- @param b              blue (0.0-1.0)
-- @return               corresponding H, S and L components
-----------------------------------------------------------------------------
util.rgb_to_hsl = function(r, g, b)
   --r, g, b = r/255, g/255, b/255
   local min = math.min(r, g, b)
   local max = math.max(r, g, b)
   local delta = max - min

   local h, s, l = 0, 0, ((min+max)/2)

   if l > 0 and l < 0.5 then s = delta/(max+min) end
   if l >= 0.5 and l < 1 then s = delta/(2-max-min) end

   if delta > 0 then
      if max == r and max ~= g then h = h + (g-b)/delta end
      if max == g and max ~= b then h = h + 2 + (b-r)/delta end
      if max == b and max ~= r then h = h + 4 + (r-g)/delta end
      h = h / 6;
   end

   if h < 0 then h = h + 1 end
   if h > 1 then h = h - 1 end

   return h * 360, s, l
end

-----------------------------------------------------------------------------
-- Converts an HSL triplet to RGB
-- (see http://homepages.cwi.nl/~steven/css/hsl.html).
--
-- @param H              hue (0-360)
-- @param S              saturation (0.0-1.0)
-- @param L              lightness (0.0-1.0)
-- @return               an R, G, and B component of RGB
-----------------------------------------------------------------------------
util.hsl_to_rgb = function(h, s, L)
   h = h/360
   local m1, m2
   if L<=0.5 then
      m2 = L*(s+1)
   else
      m2 = L+s-L*s
   end
   m1 = L*2-m2

   local function _h2rgb(_m1, _m2, _h)
     if _h<0 then _h = _h+1 end
     if _h>1 then _h = _h-1 end
     if _h*6<1 then
       return _m1+(_m2-_m1)*h*6
     elseif _h*2<1 then
       return _m2
     elseif _h*3<2 then
       return _m1+(_m2-_m1)*(2/3-h)*6
     else
       return _m1
     end
   end

   return _h2rgb(m1, m2, h+1/3), _h2rgb(m1, m2, h), _h2rgb(m1, m2, h-1/3)
end

return util
