local log = require("colorbuddy.log")

local Color = require("colorbuddy.color").Color
local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

local s = require("colorbuddy.style").styles

Group.new("LspReferenceRead", nil, c.gray0:light())
Group.link("LspReferenceWrite", g.LspReferenceRead)
