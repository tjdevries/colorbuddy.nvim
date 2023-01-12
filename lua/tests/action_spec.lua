local a = require("colorbuddy.actions")

local Color = require("colorbuddy.color").Color
local colors = require("colorbuddy.color").colors

local helper = require("tests.helper")

local function precision(x)
  return string.format("%.4f", x)
end

describe("Actions", function()
  before_each(function()
    helper.clear()
  end)

  it("should interact with colors", function()
    Color.new("this", "#121212")
    Color.new("that", "#343434")

    local og_this = colors.this:to_hsl()
    local og_that = colors.that:to_hsl()

    a.lighter()

    local new_this = colors.this:to_hsl()
    local new_that = colors.that:to_hsl()

    assert.are.same(colors.this.mods, { "light" })

    -- assert.are.same("expected", "actual")
    assert.are.same(precision(og_that.L), precision(new_that.L - 0.1))
    assert.are.same(precision(og_this.L), precision(new_this.L - 0.1))
  end)

  it("should not update children twice, from module", function()
    Color.new("parent", "#343434")
    colors.parent:new_child("child", { "light" })

    local parent_L = colors.parent:to_hsl().L
    local child_L = colors.child:to_hsl().L

    a.lighter()

    --- NOTE: not twice as light, just one time. We didn't update twice
    assert.are.same(precision(parent_L), precision(colors.parent:to_hsl().L - 0.1))
    assert.are.same(precision(child_L), precision(colors.child:to_hsl().L - 0.1))

    a.darker()

    assert.are.same(precision(parent_L), precision(colors.parent:to_hsl().L))
    assert.are.same(precision(child_L), precision(colors.child:to_hsl().L))
  end)

  it("should not update children twice, from locals", function()
    local parent = Color.new("parent", "#343434")
    parent:new_child("child", { "light" })

    local parent_L = colors.parent:to_hsl().L
    local child_L = colors.child:to_hsl().L

    a.lighter()

    --- NOTE: not twice as light, just one time. We didn't update twice
    assert.are.same(precision(parent_L), precision(colors.parent:to_hsl().L - 0.1))
    assert.are.same(precision(child_L), precision(colors.child:to_hsl().L - 0.1))
  end)
end)
