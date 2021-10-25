local c = require("colorbuddy.color").colors
local Color = require("colorbuddy.color").Color

local g = require("colorbuddy.group").groups
local Group = require("colorbuddy.group").Group

Color.new("Changed", "#33423e")
Color.new("ChangedText", "#3e4a47")
-- Color.new('ChangedText', '#006000')

Color.new("RedBg", "#3f0001")
Color.new("Black", "#000000")
Color.new("Deleted", "#24282f")

Group.new("gitDiff", c.gray6:dark())

Group.new("DiffChange", nil, c.Changed)
Group.new("DiffText", nil, c.ChangedText)
Group.new("DiffAdd", nil, g.DiffChange.bg)
Group.new("DiffDelete", c.Deleted:light(), c.Deleted)

-- commitia highlights
Group.new("DiffRemoved", c.red)
Group.new("DiffAdded", c.green, nil)

-- TODO: Gotta fix these probably as well.
-- Group.new('SignifyLineAdd', c.green, nil)
-- Group.new('SignifyLineChange', nil, c.blue)
Group.new("SignifySignAdd", c.green, nil)
Group.new("SignifySignChange", c.yellow, nil)
Group.new("SignifySignDelete", c.red, nil)

--[[
This is from the very helpful @recursivechat
Goto above to see who this is from.

hi String ctermbg=0 ctermfg=10 cterm=NONE guibg=#36353d guifg=#7d8a6b gui=NONE
hi Normal ctermbg=0 ctermfg=15 cterm=NONE guibg=#36353d guifg=#a4a4a7 gui=NONE
hi ErrorMsg ctermbg=0 ctermfg=9 cterm=NONE guibg=#36353d guifg=#8e5256 gui=NONE
hi Identifier ctermbg=0 ctermfg=6 cterm=NONE guibg=#36353d guifg=#6c8b94 gui=NONE

hi DiffAdd ctermbg=2 guibg=#414839
hi DiffChange ctermbg=2 guibg=#414839

hi! link diffAdded String
hi! link diffSubname Normal

hi! link DiffDelete ErrorMsg

hi! link DiffText Normal
hi! link diffLine Identifier
--]]
