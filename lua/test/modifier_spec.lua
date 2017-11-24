
local modifiers = require('colorbuddy.modifiers').modifiers
local util = require('colorbuddy.util')

describe('modifiers', function()
    it('should return averages well', function()
        -- mix(#15293E, #012549, 50%)
        local obj1 = {util.rgb_string_to_hsl('#15293E')}
        local obj2 = {util.rgb_string_to_hsl('#012549')}

        local hsl1 = {
            H = obj1[1],
            S = obj1[2],
            L = obj1[3]
        }
        local hsl2 = {
            H = obj2[1],
            S = obj2[2],
            L = obj2[3]
        }

        local result = modifiers.average(hsl1.H, hsl1.S, hsl1.L, hsl2)
        local rgb_result = util.hsl_to_rgb_string(unpack(result))


        assert.are.same('#0e2643', rgb_result)
    end)
end)
