local RGB = require("colorbuddy.data.rgb")
local HSL = require("colorbuddy.data.hsl")

local modifiers = require("colorbuddy.modifiers").modifiers
local util = require("colorbuddy.util")

describe("modifiers", function()
  it("should return averages well", function()
    -- mix(#15293E, #012549, 50%)
    local hsl1 = HSL:from_vim("#15293E")
    local hsl2 = HSL:from_vim("#012549")

    local result = modifiers.average(hsl1, hsl2)
    local rgb_result = RGB:from_hsl(result)

    assert.are.same("#0f2744", rgb_result:to_vim())
  end)

  it("should know how to do negatives", function()
    local obj1 = HSL:from_vim("#808080")
    assert.are.same("#7f7f7f", modifiers.negative(obj1):to_vim())

    local obj2 = HSL:from_vim("#000000")
    assert.are.same("#ffffff", modifiers.negative(obj2):to_vim())

    local obj3 = HSL:from_vim("#ffffff")
    assert.are.same("#000000", modifiers.negative(obj3):to_vim())
  end)

  -- Pending: Some dumb float drift that I don't want to deal w/ right now.
  it("should do complements to nice colors", function()
    local original_string = "#325abd"
    assert.are.same(original_string, modifiers.complement(modifiers.complement(HSL:from_vim(original_string))):to_vim())
  end)
end)
