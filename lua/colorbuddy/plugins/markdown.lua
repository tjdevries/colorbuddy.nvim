local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

local s = require("colorbuddy.style").styles

-- Group.new('mkdLineBreak', g.normal, g.normal, g.normal)
Group.new("mkdLineBreak", nil, nil, nil)

Group.new("htmlh1", c.blue)
Group.new("markdownH1", g.htmlh1, nil, s.bold + s.italic)
Group.new("markdownH2", g.markdownH1.fg:light(), nil, s.bold)
Group.new("markdownH3", g.markdownH2.fg:light(), nil, s.italic)
