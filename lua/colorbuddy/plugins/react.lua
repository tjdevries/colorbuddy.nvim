local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups
local c = require("colorbuddy.color").colors
local s = require("colorbuddy.style").styles

Group.new("tsGenerics", c.blue:dark(), nil, s.italic)
Group.new("tsxTypes", c.blue:light(), nil, s.bold + s.italic)
Group.new("typescriptBraces", c.blue:dark(), nil, nil)
Group.new("tsxElseOperator", c.yellow, nil, nil)

Group.new("typescriptType", g.Type, nil, g.Type.style + s.bold)
-- Group.new('typescriptStorageClass', c.teal:light())
Group.new("typescriptStorageClass", c.purple:light())

Group.new("tsxTagName", c.orange)
Group.new("tsxCloseTagName", g.tsxTagName)
Group.new("tsxTag", g.tsxTagName.fg:light(), nil, s.italic)
Group.new("tsxCloseTag", g.tsxTag)
Group.new("tsxComponentName", c.orange)
Group.new("tsxCloseComponentName", g.tsxComponentName)

Group.new("foldbraces", c.white)

Group.new("typescriptDecorators", c.green:dark())
Group.new("typescriptEndColons", c.purple:light())

--[[
hi ReactState guifg=#C176A7
hi ReactProps guifg=#D19A66
hi ApolloGraphQL guifg=#CB886B
hi Events ctermfg=204 guifg=#56B6C2
hi ReduxKeywords ctermfg=204 guifg=#C678DD
hi ReduxHooksKeywords ctermfg=204 guifg=#C176A7
hi WebBrowser ctermfg=204 guifg=#56B6C2
hi ReactLifeCycleMethods ctermfg=204 guifg=#D19A66
--]]
