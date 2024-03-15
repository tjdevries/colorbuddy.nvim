local Color = require("colorbuddy.color").Color
local c = require("colorbuddy.color").colors

local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups

local s = require("colorbuddy.style").styles

local background_string = "#111111"
Color.new("background", background_string)
Color.new("gray0", background_string)

Color.new("superwhite", "#E0E0E0")
Color.new("softwhite", "#ebdbb2")
Color.new("teal", "#018080")
Color.new("black", "#000000")

Color.new("lightyellow", c.NvimLightYellow:to_hsl())
Color.new("lightcyan", c.NvimLightCyan:to_hsl())

--1 Vim Editor
Group.new("Normal", c.superwhite, c.gray0)
Group.new("InvNormal", c.gray0, c.gray5)
Group.new("NormalFloat", g.normal.fg:light(), g.normal.bg:dark())
Group.new("FloatBorder", c.gray0:light(), g.NormalFloat)

Group.new("EndOfBuffer", c.gray3)

Group.new("LineNr", c.gray1, c.gray0)
Group.new("SignColumn", g.LineNr.fg:light(), g.LineNr)

Group.new("Cursor", g.normal.bg, g.normal.fg)
Group.new("CursorLine", nil, g.normal.bg:light(0.05))
Group.new("PMenu", c.gray4, c.gray2)
Group.new("PMenuSel", c.gray0, c.yellow:light())
Group.new("PMenuSbar", nil, c.gray0)
Group.new("PMenuThumb", nil, c.gray4)
Group.new("qfFileName", c.yellow, nil, s.bold)
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

Group.new("Special", c.purple:light(), nil, s.bold)
Group.new("SpecialChar", c.brown)
Group.new("NonText", c.gray2:light(), nil, s.italic)
Group.new("WhiteSpace", c.purple)
Group.new("Conceal", g.Normal.bg, c.gray2:light(), s.italic)
Group.new("Search", c.gray1, c.yellow)
Group.new("TabLine", c.blue:dark(), c.gray1, s.none)
Group.new("TabLineFill", c.softwhite, c.gray3, s.none)
Group.new("TabLineSel", c.gray7:light(), c.gray1, s.bold)

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
Group.new("Label", c.yellow)
Group.new("Operator", c.red:light():light())
Group.new("PreProc", c.yellow)
Group.new("Repeat", c.red)
Group.new("Repeat", c.red)
Group.new("Statement", c.red:dark(0.1))
Group.new("StorageClass", c.yellow)
Group.new("Structure", c.violet)
Group.new("Tag", c.yellow)
Group.new("Todo", c.yellow)
Group.new("Typedef", c.yellow)

Group.new("Type", c.violet, nil, s.italic)
Group.new("Folded", c.gray3:dark(), c.gray2:light())
Group.new("Function", c.yellow, nil, s.bold)

Group.new("MatchParen", c.cyan)

Group.new("@field", c.red)
Group.new("@include", g.include)
Group.new("@constant", c.blue)
Group.new("@function", g.Function)
Group.new("@namespace", c.blue:light())

do -- # Identifiers {{{
  -- @variable ; various variable names
  Group.new("variable", g.Normal)
  Group.link("@variable", g.variable)

  -- @variable.builtin ; built-in variable names (e.g. `this`)
  Group.new("@variable.builtin", c.yellow)

  -- @variable.parameter  ; parameters of a function
  -- @variable.member     ; object and struct fields

  -- @constant          ; constant identifiers
  -- @constant.builtin  ; built-in constant values
  -- @constant.macro    ; constants defined by the preprocessor

  -- @module            ; modules or namespaces
  -- @module.builtin    ; built-in modules or namespaces
  -- @label             ; GOTO and other labels (e.g. `label:` in C), including heredoc labels
end -- }}}

do -- # Literals {{{
  -- @string                 ; string literals
  Group.new("string", c.green)

  -- @string.documentation   ; string documenting code (e.g. Python docstrings)
  -- @string.regexp          ; regular expressions
  -- @string.escape          ; escape sequences
  -- @string.special         ; other special strings (e.g. dates)
  -- @string.special.symbol  ; symbols or atoms
  -- @string.special.url     ; URIs (e.g. hyperlinks)
  -- @string.special.path    ; filenames

  -- @character              ; character literals
  -- @character.special      ; special characters (e.g. wildcards)

  -- @boolean                ; boolean literals
  -- @number                 ; numeric literals
  -- @number.float           ; floating-point number literals
end -- }}}

--[[
#### Types

```query
@type             ; type or class definitions and annotations
@type.builtin     ; built-in types
@type.definition  ; identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)
@type.qualifier   ; type qualifiers (e.g. `const`)

@attribute        ; attribute annotations (e.g. Python decorators)
@property         ; the key in key/value pairs
```

#### Functions

```query
@function             ; function definitions
@function.builtin     ; built-in functions
@function.call        ; function calls
@function.macro       ; preprocessor macros

@function.method      ; method definitions
@function.method.call ; method calls

@constructor          ; constructor calls and definitions
@operator             ; symbolic operators (e.g. `+` / `*`)
```
-- ]]

do -- #### Keywords
  Group.new("@keyword", c.violet) -- ; keywords not fitting into specific categories
  -- @keyword.coroutine         ; keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
  -- @keyword.function          ; keywords that define a function (e.g. `func` in Go, `def` in Python)
  -- @keyword.operator          ; operators that are English words (e.g. `and` / `or`)
  -- @keyword.import            ; keywords for including modules (e.g. `import` / `from` in Python)
  -- @keyword.storage           ; modifiers that affect storage in memory or life-time
  -- @keyword.repeat            ; keywords related to loops (e.g. `for` / `while`)
  -- @keyword.return            ; keywords like `return` and `yield`
  -- @keyword.debug             ; keywords related to debugging
  -- @keyword.exception         ; keywords related to exceptions (e.g. `throw` / `catch`)
  --
  -- @keyword.conditional         ; keywords related to conditionals (e.g. `if` / `else`)
  -- @keyword.conditional.ternary ; ternary operator (e.g. `?` / `:`)
  --
  -- @keyword.directive         ; various preprocessor directives & shebangs
  -- @keyword.directive.define  ; preprocessor definition directives
end

--[[
#### Punctuation

```query
@punctuation.delimiter ; delimiters (e.g. `;` / `.` / `,`)
@punctuation.bracket   ; brackets (e.g. `()` / `{}` / `[]`)
@punctuation.special   ; special symbols (e.g. `{}` in string interpolation)
```

#### Comments

```query
@comment               ; line and block comments
@comment.documentation ; comments documenting code

@comment.error         ; error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED:`)
@comment.warning       ; warning-type comments (e.g. `WARNING:`, `FIX:`, `HACK:`)
@comment.todo          ; todo-type comments (e.g. `TODO:`, `WIP:`, `FIXME:`)
@comment.note          ; note-type comments (e.g. `NOTE:`, `INFO:`, `XXX`)
```

#### Markup

Mainly for markup languages.

```query
@markup.strong         ; bold text
@markup.italic         ; italic text
@markup.strikethrough  ; struck-through text
@markup.underline      ; underlined text (only for literal underline markup!)

@markup.heading        ; headings, titles (including markers)

@markup.quote          ; block quotes
@markup.math           ; math environments (e.g. `$ ... $` in LaTeX)
@markup.environment    ; environments (e.g. in LaTeX)

@markup.link           ; text references, footnotes, citations, etc.
@markup.link.label     ; link, reference descriptions
@markup.link.url       ; URL-style links

@markup.raw            ; literal or verbatim text (e.g. inline code)
@markup.raw.block      ; literal or verbatim text as a stand-alone block
                       ; (use priority 90 for blocks with injections)

@markup.list           ; list markers
@markup.list.checked   ; checked todo-style list markers
@markup.list.unchecked ; unchecked todo-style list markers
```

```query
@diff.plus       ; added text (for diff files)
@diff.minus      ; deleted text (for diff files)
@diff.delta      ; changed text (for diff files)
```

```query
@tag           ; XML-style tag names (and similar)
@tag.attribute ; XML-style tag attributes
@tag.delimiter ; XML-style tag delimiters
```
--]]

do -- Diagnostics {{{
  Group.new("DiagnosticError", c.red, nil, s.bold)
  Group.new("DiagnosticWarn", c.lightyellow, nil, nil)
  Group.new("DiagnosticInfo", c.lightcyan, nil, nil)
end -- }}}
do -- Diff {{{
  Color.new("Changed", "#33423e")
  Color.new("ChangedText", "#3e4a47")

  Color.new("RedBg", "#3f0001")
  Color.new("Deleted", "#24282f")

  Group.new("gitDiff", c.gray6:dark())

  Group.new("DiffChange", nil, c.Changed)
  Group.new("DiffText", nil, c.ChangedText)
  Group.new("DiffAdd", nil, g.DiffChange.bg)
  Group.new("DiffDelete", c.Deleted:light(), c.Deleted)

  -- commitia highlights
  Group.new("DiffRemoved", c.red)
  Group.new("DiffAdded", c.green, nil)

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
end -- }}}
do -- Files {{{
  Group.new("Directory", c.orange:light())
end -- }}}
do -- HTML Syntax {{{
  Group.new("htmlH1", c.blue:dark(), nil, s.bold)
  -- }}}
end -- }}}
do -- LSP {{{
  Group.new("LspReferenceRead", nil, c.gray0:light())
  Group.link("LspReferenceWrite", g.LspReferenceRead)
end -- }}}
do -- Markdown {{{
  -- Group.new('mkdLineBreak', g.normal, g.normal, g.normal)
  Group.new("mkdLineBreak", nil, nil, nil)

  Group.new("htmlh1", c.blue)
  Group.new("markdownH1", g.htmlh1, nil, s.bold + s.italic)
  Group.new("markdownH2", g.markdownH1.fg:light(), nil, s.bold)
  Group.new("markdownH3", g.markdownH2.fg:light(), nil, s.italic)
end -- }}}

-- TODO:
Group.new("TelescopeMatching", c.orange:saturate(0.20), c.None, s.bold)

Group.link("@normal", g.Normal)
Group.link("@tag.attribute.html", g.type)
Group.link("@tag.delimiter.html", g["@namespace"])
