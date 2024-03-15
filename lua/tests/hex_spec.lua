local toHex = require("colorbuddy.util").toHex

local eq = assert.are.same
local bit = require("bit")
describe("toHex", function()
  it("should work", function()
    eq(bit.tohex(0, 6), "000000")
    eq(bit.tohex(255, 6), "0000ff")

    eq(bit.tohex(0, 8), toHex(0, 8))
    eq(bit.tohex(255, 8), toHex(255, 8))

    for i = 0, 1000 do
      for j = 6, 8 do
        eq(bit.tohex(i, j), toHex(i, j))
      end
    end
  end)
end)
