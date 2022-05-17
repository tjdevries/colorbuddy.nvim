local eq = assert.are.same
local colors = require("colorbuddy.color").colors

local Color = require("colorbuddy.color").Color
local HSL = require("colorbuddy.data.hsl")
local modifiers = require("colorbuddy.modifiers").modifiers
local helper = require("tests.helper")

describe("Color class", function()
  before_each(helper.clear)

  it("should create something with a name", function()
    local test_color = Color.new("foobar", HSL:new(0.5, 0.5, 0.5))
    eq("foobar", test_color.name)
  end)

  it("should add it to colors", function()
    local test_color = Color.new("foobar", HSL:new(0.5, 0.5, 0.5))
    eq(colors.foobar, test_color)
  end)

  it("should be accessible via weird caps", function()
    local test_color = Color.new("foobar", HSL:new(0.5, 0.5, 0.5))
    eq(colors.FooBar, test_color)
    eq(colors.fooBar, test_color)
    eq(colors.FOOBAR, test_color)
  end)

  it("should be accessible via weird caps from naming", function()
    local test_color = Color.new("fooBar", HSL:new(0.5, 0.5, 0.5))
    eq(colors.FooBar, test_color)
    eq(colors.fooBar, test_color)
    eq(colors.FOOBAR, test_color)
  end)

  it("should convert rgb", function()
    local test_color = Color.new("foobar", "#123456")
    eq("#123456", test_color:to_vim())
  end)

  it("should lighten rgb", function()
    local test_color = Color.new("foobar", "#123456")
    local lighter_color = test_color:light()
    eq("#123456", test_color:to_vim())

    eq(test_color:to_hsl().H, lighter_color:to_hsl().H)
    eq(test_color:to_hsl().L + 0.1, lighter_color:to_hsl().L)
  end)

  it("should create children", function()
    local test_color = Color.new("foobar", HSL:new(180, 0.5, 0.5))
    local child_color = test_color:new_child("kiddo", { "dark" })

    eq("kiddo", child_color.name)
    eq(0.4, child_color:to_hsl().L)
  end)

  it("should create children with arguments", function()
    local test_color = Color.new("foobar_no_arg", HSL:new(180, 0.5, 0.5))
    local child_color = test_color:new_child("kiddo", { { "dark", 0.2 } })

    eq("kiddo", child_color.name)
    eq(0.3, child_color:to_hsl().L)
    eq(test_color.children[child_color], true)
  end)

  it("should create children with multiple arguments", function()
    local test_color = Color.new("foobar", HSL:new(180, 0.5, 0.5))
    local child_color = test_color:new_child("kiddo", { { "dark", 0.2 }, { "light", 0.2 } })
    eq({ { "dark", 0.2 }, { "light", 0.2 } }, child_color.mods)

    eq("kiddo", child_color.name)
    eq(0.5, child_color:to_hsl().L)
    eq(test_color.children[child_color], true)
  end)

  it("should update children when parent is updated", function()
    local base_color = Color.new("fooBar", HSL:new(180, 0.5, 0.5))
    local child_color = base_color:new_child("kiddo", { "dark" })
    local light_color = base_color:new_child("lighter", { "light" })

    base_color:modifier_apply({ "dark" })

    eq(0.5 - 0.1 - 0.1, child_color:to_hsl().L)
    eq(0.5 + 0.1 - 0.1, light_color:to_hsl().L)
  end)

  it("should update grand children when parent is updated", function()
    local starting_L = 0.5

    local test_color = Color.new("fooBar", HSL:new(180, 0.5, starting_L))
    local child_color = test_color:new_child("kiddo", { "dark" })
    local grandchild_color = child_color:new_child("grandkiddo", { { "dark", 0.2 } })

    test_color:modifier_apply({ "dark" })

    helper.eq_float(starting_L - 0.1 - 0.1, child_color:to_hsl().L)
    helper.eq_float(child_color:to_hsl().L - 0.2, grandchild_color:to_hsl().L)
  end)

  it("should be able to subtract rgb values", function()
    local test_color = Color.new("mixed", "#888888")
    local subtract_color = Color.new("subtractor", "#0000FF")

    local result = modifiers.subtract(test_color:to_hsl(), subtract_color)
    local final_color = Color.new("result", result)

    eq(test_color:to_vim(), "#888888")
    eq(subtract_color:to_vim(), "#0000ff")
    eq(final_color:to_vim(), "#888800")
  end)

  it("should be able to subtract rgb values with variable intensity", function()
    local test_color = Color.new("mixed", "#888888")
    local subtract_color = Color.new("subtractor", "#0000FF")

    local result = modifiers.subtract(
      test_color:to_hsl(),
      subtract_color,
      68 / 255 -- 68 / 255 since that's the difference between 0x88 and 0x44
    )

    local resulting_color = Color.new("result", result)
    eq("#888888", test_color:to_vim())
    eq("#0000ff", subtract_color:to_vim())
    eq("#888844", resulting_color:to_vim())
  end)

  it("should be able to add rgb values", function()
    local test_color = Color.new("mixed", "#000001")
    local subtract_color = Color.new("subtractor", "#00FF00")

    local result = modifiers.add(
      test_color:to_hsl(),
      subtract_color,
      68 / 255 -- 68 / 255 since that's the difference between 0x88 and 0x44
    )
    local final_color = Color.new("result", result)
    eq(final_color:to_vim(), "#004401")
  end)
end)
