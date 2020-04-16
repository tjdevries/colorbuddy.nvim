require("colorbuddy").setup()

-- Function is parent class
Group.new('Function', c.blue, nil, s.bold)

-- Note that luaFunctioncall inherits here:
--                           vvvvvvvvvv
Group.new('luaFunctionCall', g.Function, nil, g.Function + s.italic)
--    ^^^
--    This is a higlighted "luaFunctionCall" syntax

-- If you change the color for the parent,
--   the child will also update -- LIVE!
Group.new('Function', c.yellow, nil, s.bold)
