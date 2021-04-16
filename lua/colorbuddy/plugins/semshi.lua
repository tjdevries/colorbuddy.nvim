local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

--  Semshi
-- Original hi semshiSelf            ctermfg=249 guifg=#b2b2b2
Group.new("semshiSelf", g.pythonSelf, g.pythonSelf, g.pythonSelf)

-- Original hi semshiLocal           ctermfg=209 guifg=#ff875f
Group.new("semshiLocal", nil, nil, nil)
-- Original hi semshiImported        ctermfg=214 guifg=#ffaf00 cterm=bold gui=bold
Group.new("semshiImported", c.blue, nil)
-- Original hi semshiSelected        ctermfg=231 guifg=#ffffff ctermbg=161 guibg=#d7005f
Group.new("semshiSelected", nil, c.background:light())

-- This one doesn't seem to be very reliable.
-- Original hi semshiFree            ctermfg=218 guifg=#ffafd7
Group.new("semshiFree", nil, nil, nil)

-- TODO:
-- Original hi semshiGlobal          ctermfg=214 guifg=#ffaf00
-- Original hi semshiParameter       ctermfg=75  guifg=#5fafff
-- Original hi semshiParameterUnused ctermfg=117 guifg=#87d7ff cterm=underline gui=underline
-- Original hi semshiBuiltin         ctermfg=207 guifg=#ff5fff
-- Original hi semshiAttribute       ctermfg=49  guifg=#00ffaf
-- Original hi semshiUnresolved      ctermfg=226 guifg=#ffff00 cterm=underline gui=underline
-- Original hi semshiErrorSign       ctermfg=231 guifg=#ffffff ctermbg=160 guibg=#d70000
-- Original hi semshiErrorChar       ctermfg=231 guifg=#ffffff ctermbg=160 guibg=#d70000
-- sign define semshiError text=E> texthl=semshiErrorSign
