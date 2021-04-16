if true then
  return
end

local html = require("colorbuddy.lua_html.init")

local helper = require("tests.helper")
local eq = helper.eq_float

describe("Basic Syntax", function()
  before_each(function()
    helper.clear()
  end)

  it("should get syntax attributes", function()
    local attrs = html.syntax_attributes

    eq(attrs["comment"]["bg"], "")
  end)
end)
