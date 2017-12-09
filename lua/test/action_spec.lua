
local a = require('colorbuddy.actions').actions

local Color = require('colorbuddy.color').Color
local colors = require('colorbuddy.color').colors

local helper = require('test.helper')
local eq = helper.eq_float

describe('Actions', function()
    before_each(function()
        helper.clear()
    end)
    it('should interact with colors', function()
        Color.new('this', '#121212')
        Color.new('that', '#343434')

        local original_this_L = colors.this.L
        local original_that_L = colors.that.L

        a.lighter()

        eq(original_this_L, colors.this.L - 0.1)
        eq(original_that_L, colors.that.L - 0.1)
    end)
    it('should not update children twice', function()
        Color.new('parent', '#343434')
        colors.parent:new_child('child', 'light')

        local parent_L = colors.parent.L
        local child_L = colors.child.L

        a.lighter()

        eq(parent_L, colors.parent.L - 0.1)
        --- Note, not twice as light, just one time. We didn't update twice
        eq(child_L, colors.child.L - 0.1)
    end)
end)
