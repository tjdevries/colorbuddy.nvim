local util = require("colorbuddy.util")

-- local helper = require('tests.helper')

describe("hsl <-> rgb functions", function()
  it("should convert between hsl and rgb just fine", function()
    local start = { 180, 0.5, 0.5 }
    assert.are.same(start, { util.rgb_to_hsl(util.hsl_to_rgb(unpack(start))) })
  end)
  it("should convert between hsl and rgb with 0s", function()
    local start = { 0.0, 0.0, 0.0 }
    assert.are.same(start, { util.rgb_to_hsl(util.hsl_to_rgb(unpack(start))) })
  end)
  it("should convert between hsl and rgb with 1s", function()
    local start = { 359, 0, 1 }
    assert.are.same(start, { util.rgb_to_hsl(util.hsl_to_rgb(unpack(start))) })
  end)
  it("should handle FFs", function()
    local start = { util.rgb_string_to_hsl("#0000ff") }
    assert.are.same("#0000ff", util.hsl_to_rgb_string(unpack(start)))
  end)
  it("should convert between hsl and rgb with 0/360", function()
    local start = { 0, 0.5, 0.5 }
    assert.are.same(start, { util.rgb_to_hsl(util.hsl_to_rgb(unpack(start))) })
  end)
end)
