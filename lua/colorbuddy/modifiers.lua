
local util = require('colorbuddy.util')

-- Modifier table
-- Must have signature of (H, S, L, ...)
-- and then return {H, S, L}
local modifiers = {}

modifiers.dark = function(H, S, L, amount)
    if amount == nil or amount == {} then
        amount = 0.1
    end

    return {H, S, L - amount}
end

modifiers.light = function(H, S, L, amount)
    if amount == nil then
        amount = 0.1
    end

    return {H, S, L + amount}
end

modifiers.subtract = function(H, S, L, color_object, intensity)
    if color_object == nil then
        return {H, S, L}
    end

    if intensity == nil then
        intensity = 1.0
    end

    local original = {util.hsl_to_rgb(H, S, L)}
    local mixin = {util.hsl_to_rgb(color_object.H, color_object.S, color_object.L)}

    local result_rgb = {0, 0, 0}
    print()
    for i, _ in ipairs(result_rgb) do
        print('subt:', original[i], mixin[i], 'res', util.clamp(original[i] - (intensity * mixin[i]), 0, 1))
        result_rgb[i] = util.clamp(original[i] - (intensity * mixin[i]), 0, 1)
    end

    print(unpack(result_rgb))
    return {util.rgb_to_hsl(unpack(result_rgb))}
end


return {
    modifiers = modifiers
}
