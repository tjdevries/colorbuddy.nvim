local log = require("colorbuddy.log")

local Color = require("colorbuddy.color").Color
local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

local s = require("colorbuddy.style").styles

local background_string = "#282c34"
Color.new("background", background_string)

Color.new("superwhite", "#E0E0E0")
Color.new("softwhite", "#ebdbb2")
Color.new("teal", "#018080")

--1 Vim Editor
Group.new("Normal", c.superwhite, c.gray0)
Group.new("InvNormal", c.gray0, c.gray5)
Group.new("NormalFloat", g.normal.fg:light(), g.normal.bg:dark())
Group.new("FloatBorder", c.gray0:light(), g.NormalFloat)

Group.new("LineNr", c.gray3, c.gray1)
Group.new("EndOfBuffer", c.gray3)

Group.new("SignColumn", c.gray3, c.gray1)
--2 Cursor
Group.new("Cursor", g.normal.bg, g.normal.fg)
Group.new("CursorLine", nil, g.normal.bg:light(0.05))
--2 Popup Menu
Group.new("PMenu", c.gray4, c.gray2)
Group.new("PMenuSel", c.gray0, c.yellow:light())
Group.new("PMenuSbar", nil, c.gray0)
Group.new("PMenuThumb", nil, c.gray4)
--2 Quickfix Menu
Group.new("qfFileName", c.yellow, nil, s.bold)
--2 Statusline Colors
Group.new("StatusLine", c.gray2, c.blue, nil)
Group.new("StatusLineNC", c.gray3, c.gray1:light())
Group.new("User1", c.gray7, c.yellow, s.bold)
Group.new("User2", c.gray7, c.red, s.bold)
Group.new("User3", c.gray7, c.green, s.bold)
Group.new("CommandMode", c.gray7, c.green, s.bold)
Group.new("NormalMode", c.gray7, c.red, s.bold)
Group.new("InsertMode", c.gray7, c.yellow, s.bold)
Group.new("ReplaceMode", c.gray7, c.yellow, s.bold + s.underline)
Group.new("TerminalMode", c.gray7, c.turquoise, s.bold)
Group.new("HelpDoc", c.gray7, c.turquoise, s.bold + s.italic)
Group.new("HelpIgnore", c.green, nil, s.bold + s.italic)

Group.new("Visual", nil, c.blue:dark(0.3))
Group.new("VisualMode", g.Visual, g.Visual)
Group.new("VisualLineMode", g.Visual, g.Visual)

--2 Special Characters
Group.new("Special", c.purple:light(), nil, s.bold)
Group.new("SpecialChar", c.brown)
Group.new("NonText", c.gray2:light(), nil, s.italic)
Group.new("WhiteSpace", c.purple)
Group.new("Conceal", g.Normal.bg, c.gray2:light(), s.italic)
--2 Searching
Group.new("Search", c.gray1, c.yellow)
--2 Tabline
Group.new("TabLine", c.blue:dark(), c.gray1, s.none)
Group.new("TabLineFill", c.softwhite, c.gray3, s.none)
Group.new("TabLineSel", c.gray7:light(), c.gray1, s.bold)
--2 Sign Column
--1 Standard syntax
Group.new("Boolean", c.orange)
Group.new("Comment", c.gray3:light(), nil, s.italic)
Group.new("Character", c.red)
Group.new("Conditional", c.red)
Group.new("Define", c.cyan)
Group.new("Error", c.red:light(), nil, s.bold)

Group.new("Number", c.red)
Group.new("Float", g.Number, g.Number, g.Number)
Group.new("Constant", c.orange, nil, s.bold)

Group.new("Identifier", c.red, nil, s.bold)
Group.new("Include", c.cyan)
Group.new("Keyword", c.violet)
Group.new("Label", c.yellow)
Group.new("Operator", c.red:light():light())
Group.new("PreProc", c.yellow)
Group.new("Repeat", c.red)
Group.new("Repeat", c.red)
Group.new("Statement", c.red:dark(0.1))
Group.new("StorageClass", c.yellow)
Group.new("String", c.green)
Group.new("Structure", c.violet)
Group.new("Tag", c.yellow)
Group.new("Todo", c.yellow)
Group.new("Typedef", c.yellow)

Group.new("Type", c.violet, nil, s.italic)
--2 Folded Items
Group.new("Folded", c.gray3:dark(), c.gray2:light())
--2 Function
Group.new("Function", c.yellow, nil, s.bold)
Group.new("pythonBuiltinFunc", g.Function, g.Function, g.Function)
Group.new("vimFunction", g.Function, g.Function, g.Function)
-- TODO: Change to be able to just do g.Function:dark():dark()
Group.new("vimAutoloadFunction", g.Function.fg:dark():dark(), g.Function, g.Function)

--2 MatchParen
Group.new("MatchParen", c.cyan)

local path_sep = vim.fn.has("win32") ~= 0 and "\\" or "/"

-- Load the rest of the plugins
local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return vim.fn.fnamemodify(str, ":h") .. path_sep
end

local other_plugins = vim.fn.glob(script_path() .. "*.lua", "", true)
for _, v in ipairs(other_plugins) do
  local complete_path = vim.fn.substitute(vim.fn.fnamemodify(v, ":p"), "\\", "/", "g")

  local path_starts = string.find(complete_path, "colorbuddy/plugins", nil, true)
  local relevant_path = string.sub(v, path_starts)

  local individual_requirement
  individual_requirement = string.sub(relevant_path, 1, #relevant_path - 4)
  individual_requirement = string.gsub(individual_requirement, "/", ".")

  if not string.find(individual_requirement, "init") then
    log.debug("Colorbuddy.vim::Requiring: ", individual_requirement)
    require(individual_requirement)
  end
end
