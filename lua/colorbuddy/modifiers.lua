
local log = require('colorbuddy.log')
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

local operator_intensity = function(operand)
    local supported_metamethods = {
        ['-'] = true,
        ['+'] = true,
    }
    local operand_metamethod = supported_metamethods[operand]

    if operand_metamethod == nil then
        return nil
    end

    return function(H, S, L, color_object, intensity)
        if color_object == nil then
            return {H, S, L}
        end

        if intensity == nil then
            intensity = 1.0
        end

        local original = {util.hsl_to_rgb(H, S, L)}
        local mixin = {util.hsl_to_rgb(color_object.H, color_object.S, color_object.L)}

        local result_rgb = {0, 0, 0}
        for i, _ in ipairs(result_rgb) do
            if operand == '-' then
                result_rgb[i] = util.clamp(original[i] - (intensity * mixin[i]), 0, 1)
            elseif operand == '+' then
                result_rgb[i] = util.clamp(original[i] + (intensity * mixin[i]), 0, 1)
            end

            log.debug(
                'subt:', original[i], mixin[i],
                'res', result_rgb[i]
            )
        end

        return {util.rgb_to_hsl(unpack(result_rgb))}
    end
end

modifiers.subtract = function(H, S, L, color_object, intensity)
    return operator_intensity('-')(H, S, L, color_object, intensity)
end

modifiers.add = function(H, S, L, color_object, intensity)
    return operator_intensity('+')(H, S, L, color_object, intensity)
end


return {
    modifiers = modifiers
}
