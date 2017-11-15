
-- local Group = require('colorbuddy.group').Group
-- local groups = require('colorbuddy.group').groups
local Color = require('colorbuddy.color').Color
local colors = require('colorbuddy.color').colors
-- local styles = require('colorbuddy.style').styles
local helper = require('test.helper')

describe('Real time updates', function()
    before_each(function()
        helper.clear()

        Color.new('red', '#d47d7d')
        Color.new('yellow', '#f0c674')
        Color.new('gray0', '#1d1f21')
    end)

    it('should handle a color updating', function()
        colors.red:new_child('light_red', 'light')
        assert.are.same(colors.red.H, colors.light_red.H)
        assert.are.same(colors.red.S, colors.light_red.S)
        assert.are.same(colors.red.L + 0.1, colors.light_red.L)

        -- Make a new red
        Color.new('red', '#d72819')
        assert.are.same(colors.red.H, colors.light_red.H)
        assert.are.same(colors.red.S, colors.light_red.S)
        assert.are.same(colors.red.L + 0.1, colors.light_red.L)
    end)


end)
