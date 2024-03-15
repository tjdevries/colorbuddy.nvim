local styles = require("colorbuddy.style").styles

describe("the style object", function()
  it("should print to string well", function()
    assert.are.same("style:<bold>", tostring(styles.bold))
  end)

  it("should print to string well with different names", function()
    assert.are.same("style:<bold>", tostring(styles.BOLD))
    assert.are.same("style:<bold>", tostring(styles.BoLD))
  end)

  it("should add just fine", function()
    assert.are.same("style:<bold + italic>", tostring(styles.bold + styles.italic))
    assert.are.same("style:<bold + underline>", tostring(styles.UNDERLINE + styles.bOlD))
  end)

  it("should add itself to become itself", function()
    assert.are.same("style:<bold>", tostring(styles.bold + styles.bold))
  end)

  it("should concat strings for nvim", function()
    assert.are.same("bold", styles.bold:to_vim())
  end)

  it("should concat strings for nvim even if added", function()
    assert.are.same("bold,italic", (styles.bold + styles.italic):to_vim())
  end)

  -- FIXME: Any way we can assert the order we place them? :)
  -- assert.are.same('style:<italic + bold>', tostring(styles.italic + styles.bold))

  it("should subtract from sets", function()
    local bold_italic = styles.bold + styles.italic
    assert.are.same("bold", (bold_italic - styles.italic):to_vim())
  end)

  it("should multiple subtract from sets", function()
    local bold_italic_underline = styles.bold + styles.italic + styles.underline
    assert.are.same("bold", (bold_italic_underline - styles.italic - styles.underline):to_vim())
    assert.are.same("bold", (bold_italic_underline - styles.underline - styles.italic):to_vim())
  end)

  it("should do nothing with subtract from sets that do not contain the item", function()
    local bold = styles.bold
    assert.are.same("bold", (bold - styles.undercurl):to_vim())
  end)

  it("should default to styles.none when subtract everything", function()
    assert.are.same("none", (styles.bold - styles.bold):to_vim())
  end)

  it("should not do anything when you add styles.none", function()
    assert.are.same("bold", (styles.bold + styles.none):to_vim())
  end)

  it("should not do anything when you subtract styles.none", function()
    assert.are.same("italic", (styles.italic - styles.none):to_vim())
  end)

  it("should not allow you to make new styles", function()
    assert.has.errors(function()
      styles.test = "hello world"
    end)
    assert.has.errors(function()
      styles.bold = "I can't edit existing entries either"
    end)
  end)
end)
