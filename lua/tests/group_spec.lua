local Group = require("colorbuddy.group").Group
local groups = require("colorbuddy.group").groups

local Color = require("colorbuddy.color").Color
local colors = require("colorbuddy.color").colors

local styles = require("colorbuddy.style").styles

local helper = require("tests.helper")

describe("Group object", function()
  before_each(function()
    helper.clear()

    Color.new("red", "#d47d7d")
    Color.new("yellow", "#f0c674")
    Color.new("gray0", "#1d1f21")
  end)

  it("should send an nvim command", function()
    Group.new("test_01", colors.yellow, colors.gray0, styles.bold)
  end)

  it("should send a comma list", function()
    Group.new("test_02", colors.yellow, colors.gray0, styles.bold + styles.italic)
  end)

  it("should be able to add a group to fg and bg", function()
    Group.new("func", colors.yellow, colors.gray0, styles.bold)
    Group.new("italicFunction", groups.func, groups.func, styles.italic)
    Group.new("copyFunc", groups.func, groups.func, groups.func)
  end)

  it("should have its fg change when it's parent's fg changes", function()
    -- TODO: Test changing a color and having it update
    Color.new("changing", "#aabbcc")
    Group.new("changingFunc", colors.changing, colors.gray0)

    Color.new("changing", "#ffccff")
    Group.new("copyFunc", groups.changingFunc, groups.changingFunc)
    assert.are.same(colors.changing, groups.copyfunc.fg)
    assert.are.same(groups.copyfunc.fg, groups.changingFunc.fg)
    assert.are.same("#ffccff", groups.copyfunc.fg:to_vim())
  end)

  it("should handle mixed addition", function()
    Group.new("start", colors.yellow, colors.gray0, styles.none)
    Color.new("adder", "#010101")
    Group.new("finish", groups.start + colors.adder, groups.start, groups.start)

    -- #f0c674 + #010101
    assert.are.same("#f1c775", groups.finish.fg:to_vim())
    assert.are_not.same(groups.start.fg, groups.finish.fg)
    assert.are.same(groups.start.bg, groups.finish.bg)
  end)

  it("should handle mixed addition: styles", function()
    Group.new("original", colors.yellow, colors.gray0, styles.bold)
    Group.new("addition", groups.original, groups.original, groups.original + styles.italic)

    assert.are.same(styles.bold + styles.italic, groups.addition.style)
  end)

  it("should handle mixed addition", function()
    Group.new("start", colors.yellow, colors.gray0, styles.none)
    Color.new("adder", "#010101")
    Group.new("finish", groups.start + colors.adder, groups.start, groups.start)

    -- #f0c674 + #010101
    assert.are.same("#f1c775", groups.finish.fg:to_vim())
    assert.are_not.same(groups.start.fg, groups.finish.fg)
    assert.are.same(groups.start.bg, groups.finish.bg)
  end)

  describe("Group.default", function()
    it("should send a default highlight link", function() end)

    it("should not overwrite an existing highlight", function()
      Group.new("test", colors.yellow, colors.gray0)
      Group.default("test", colors.gray0, colors.yellow)

      -- Should be original color
      assert.are.same(colors.yellow, groups.test.fg)
    end)

    it("should be overwritten by a new highlight", function()
      Group.default("test", colors.gray0, colors.yellow)
      assert.are.same(colors.gray0, groups.test.fg)

      Group.new("test", colors.yellow, colors.gray0)
      assert.are.same(colors.yellow, groups.test.fg)

      -- No change again
      Group.default("test", colors.gray0, colors.yellow)
      assert.are.same(colors.yellow, groups.test.fg)
    end)
  end)

  describe("Should be able to add mixed groups", function()
    it("should handle multiple mixed groups", function()
      Group.new("base1", colors.yellow, colors.gray0)
      Group.new("base2", colors.gray0, colors.red)

      Group.new("mixed1", groups.base1 + groups.base1, colors.gray0)

      -- Should work on the left
      Group.new("mixed2", groups.base1 + groups.base2 + groups.base1, colors.gray0)
      local mixed = (groups.base1.fg + groups.base1.fg + groups.base2.fg)
      assert.are.same(mixed:to_hsl().H, groups.mixed2.fg:to_hsl().H)
      assert.are.same(mixed:to_hsl().S, groups.mixed2.fg:to_hsl().S)
      assert.are.same(mixed:to_hsl().L, groups.mixed2.fg:to_hsl().L)

      -- Should work on the right
      Group.new("mixed3", groups.base1 + (groups.base1 + groups.base2), colors.gray0)
      assert.are.same(mixed:to_hsl().H, groups.mixed3.fg:to_hsl().H)
      assert.are.same(mixed:to_hsl().S, groups.mixed3.fg:to_hsl().S)
      assert.are.same(mixed:to_hsl().L, groups.mixed3.fg:to_hsl().L)
    end)

    it("should handle adding and subtracting mixed groups", function()
      Group.new("base1", colors.yellow, colors.gray0)
      Group.new("base2", colors.gray0, colors.red)

      Group.new("mixed1", groups.base1 - groups.base1, colors.gray0)
      helper.eq_float(0, groups.mixed1.fg:to_hsl().H)
      helper.eq_float(0, groups.mixed1.fg:to_hsl().S)
      helper.eq_float(0, groups.mixed1.fg:to_hsl().L)

      Group.new("mixed2", colors.red, groups.base1 + groups.base2 - groups.base1)
      helper.eq_float(groups.base2.bg:to_hsl().H, groups.mixed2.bg:to_hsl().H)
      helper.eq_float(groups.base2.bg:to_hsl().S, groups.mixed2.bg:to_hsl().S)
      helper.eq_float(groups.base2.bg:to_hsl().L, groups.mixed2.bg:to_hsl().L)
    end)
  end)

  describe("Parent -> Child relationships", function()
    it("should have children follow the parents changes", function()
      Group.new("parentChanger", colors.yellow, colors.gray0)
      Group.new("childChanger", groups.parentChanger, groups.parentChanger)

      -- Change yellow -> red
      Group.new("parentChanger", colors.red, colors.gray0)

      assert.are.same(colors.red, groups.parentChanger.fg)
      assert.are.same(colors.red, groups.childChanger.fg)
      assert.are.same(groups.childChanger.fg, groups.parentChanger.fg)
    end)
  end)
end)
