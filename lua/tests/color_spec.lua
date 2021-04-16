-- Imports
local colors = require("colorbuddy.color").colors
local Color = require("colorbuddy.color").Color

local modifiers = require("colorbuddy.modifiers").modifiers

local helper = require("tests.helper")

local log = require("colorbuddy.log")
-- log.level = log.level_enum.debug

describe("Color class", function()
  before_each(helper.clear)

  it("should create something with a name", function()
    local test_color = Color.new("foobar", 0.5, 0.5, 0.5)
    assert.are.same("foobar", test_color.name)
  end)
  it("should add it to colors", function()
    local test_color = Color.new("foobar", 0.5, 0.5, 0.5)
    assert.are.same(colors.foobar, test_color)
  end)
  it("should be accessible via weird caps", function()
    local test_color = Color.new("foobar", 0.5, 0.5, 0.5)
    assert.are.same(colors.FooBar, test_color)
    assert.are.same(colors.fooBar, test_color)
    assert.are.same(colors.FOOBAR, test_color)
  end)
  it("should be accessible via weird caps from naming", function()
    local test_color = Color.new("fooBar", 0.5, 0.5, 0.5)
    assert.are.same(colors.FooBar, test_color)
    assert.are.same(colors.fooBar, test_color)
    assert.are.same(colors.FOOBAR, test_color)
  end)
  it("should convert rgb", function()
    local test_color = Color.new("foobar", "#123456")
    assert.are.same("#123456", test_color:to_rgb())
  end)
  it("should lighten rgb", function()
    local test_color = Color.new("foobar", "#123456")
    local lighter_color = test_color:light()
    assert.are.same("#123456", test_color:to_rgb())

    assert.are.same(test_color.H, lighter_color.H)
    assert.are.same(test_color.L + 0.1, lighter_color.L)
  end)
  it("should create children", function()
    local test_color = Color.new("foobar", 180, 0.5, 0.5)
    local child_color = test_color:new_child("kiddo", "dark")

    assert.are.same("kiddo", child_color.name)
    assert.are.same(0.4, child_color.L)
  end)
  it("should create children with arguments", function()
    local test_color = Color.new("foobar_no_arg", 180, 0.5, 0.5)
    local child_color = test_color:new_child("kiddo", { "dark", 0.2 })

    assert.are.same("kiddo", child_color.name)
    assert.are.same(0.3, child_color.L)
    assert.are.same(test_color.children[child_color], true)
  end)
  it("should create children with multiple arguments", function()
    local test_color = Color.new("foobar", 180, 0.5, 0.5)
    local child_color = test_color:new_child("kiddo", { "dark", 0.2 }, { "light", 0.2 })
    assert.are.same({ { "dark", 0.2 }, { "light", 0.2 } }, child_color.mods)

    assert.are.same("kiddo", child_color.name)
    assert.are.same(0.5, child_color.L)
    assert.are.same(test_color.children[child_color], true)
  end)
  it("should update children when parent is updated", function()
    local test_color = Color.new("fooBar", 180, 0.5, 0.5)
    local child_color = test_color:new_child("kiddo", "dark")
    local light_color = test_color:new_child("lighter", "light")

    test_color:modifier_apply("dark")

    assert.are.same(0.5 - 0.1 - 0.1, child_color.L)
    assert.are.same(0.5 + 0.1 - 0.1, light_color.L)
  end)
  it("should update grand children when parent is updated", function()
    local test_color = Color.new("fooBar", 180, 0.5, 0.5)
    local child_color = test_color:new_child("kiddo", "dark")
    local grandchild_color = child_color:new_child("grandkiddo", { "dark", 0.2 })

    test_color:modifier_apply("dark")

    helper.eq_float(0.5 - 0.1 - 0.1, child_color.L)
    helper.eq_float(child_color.L - 0.2, grandchild_color.L)
  end)
  it("should be able to subtract rgb values", function()
    local test_color = Color.new("mixed", "#888888")
    local subtract_color = Color.new("subtractor", "#0000FF")

    local result = modifiers.subtract(test_color.H, test_color.S, test_color.L, subtract_color)
    local final_color = Color.new("result", unpack(result))
    assert.are.same(test_color:to_rgb(), "#888888")
    assert.are.same(subtract_color:to_rgb(), "#0000ff")
    assert.are.same(final_color:to_rgb(), "#888800")
  end)
  it("should be able to subtract rgb values with variable intensity", function()
    local test_color = Color.new("mixed", "#888888")
    local subtract_color = Color.new("subtractor", "#0000FF")

    local result = modifiers.subtract(
      test_color.H,
      test_color.S,
      test_color.L,
      subtract_color,
      68 / 255 -- 68 / 255 since that's the difference between 0x88 and 0x44
    )
    local final_color = Color.new("result", unpack(result))
    assert.are.same("#888888", test_color:to_rgb())
    assert.are.same("#0000ff", subtract_color:to_rgb())
    assert.are.same("#888844", final_color:to_rgb())
  end)
  it("should be able to add rgb values", function()
    local test_color = Color.new("mixed", "#000001")
    local subtract_color = Color.new("subtractor", "#00FF00")

    local result = modifiers.add(
      test_color.H,
      test_color.S,
      test_color.L,
      subtract_color,
      68 / 255 -- 68 / 255 since that's the difference between 0x88 and 0x44
    )
    local final_color = Color.new("result", unpack(result))
    assert.are.same(final_color:to_rgb(), "#004401")
  end)
end)
