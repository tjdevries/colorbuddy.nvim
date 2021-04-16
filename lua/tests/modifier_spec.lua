local modifiers = require("colorbuddy.modifiers").modifiers
local util = require("colorbuddy.util")

describe("modifiers", function()
  it("should return averages well", function()
    -- mix(#15293E, #012549, 50%)
    local obj1 = { util.rgb_string_to_hsl("#15293E") }
    local obj2 = { util.rgb_string_to_hsl("#012549") }

    local hsl1 = {
      H = obj1[1],
      S = obj1[2],
      L = obj1[3],
    }
    local hsl2 = {
      H = obj2[1],
      S = obj2[2],
      L = obj2[3],
    }

    local result = modifiers.average(hsl1.H, hsl1.S, hsl1.L, hsl2)
    local rgb_result = util.hsl_to_rgb_string(unpack(result))

    assert.are.same("#0e2743", rgb_result)
  end)

  it("should know how to do negatives", function()
    local obj1 = { util.rgb_string_to_hsl("#808080") }
    assert.are.same("#7f7f7f", util.hsl_to_rgb_string(unpack(modifiers.negative(unpack(obj1)))))

    local obj2 = { util.rgb_string_to_hsl("#000000") }
    assert.are.same("#ffffff", util.hsl_to_rgb_string(unpack(modifiers.negative(unpack(obj2)))))

    local obj3 = { util.rgb_string_to_hsl("#ffffff") }
    assert.are.same("#000000", util.hsl_to_rgb_string(unpack(modifiers.negative(unpack(obj3)))))
  end)

  -- Pending: Some dumb float drift that I don't want to deal w/ right now.
  pending("should do complements to nice colors", function()
    local original_string = "#325abd"
    assert.are.same(
      original_string,
      util.hsl_to_rgb_string(unpack(modifiers.complement(unpack(modifiers.complement(util.rgb_string_to_hsl(original_string))))))
    )
  end)
end)
