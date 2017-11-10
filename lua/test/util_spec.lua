

local util = require('colorbuddy.util')

local helper = require('test.helper')

describe('hsl <-> rgb functions', function()
    it('should convert between hsl and rgb just fine', function()
        local start = {180, 0.5, 0.5}
        helper.eq_float(start, {util.rgb_to_hsl(util.hsl_to_rgb(unpack(start)))})
    end)

    it('should convert between hsl and rgb with 0s', function()
        local start = {0.0, 0.0, 0.0}
        helper.eq_float(start, {util.rgb_to_hsl(util.hsl_to_rgb(unpack(start)))})
    end)

    it('should convert between hsl and rgb with 1s', function()
        local start = {359, 0, 1}
        helper.eq_float(start, {util.rgb_to_hsl(util.hsl_to_rgb(unpack(start)))})
    end)
end)
