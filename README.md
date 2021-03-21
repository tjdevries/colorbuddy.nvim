# colorbuddy.nvim

A colorscheme helper for Neovim.

Written in Lua! Quick & Easy Color Schemes :smile:

Sincerely, your color buddy.

## Benefits

Live changing of colors (and inherited colors!)

![changing_colors](https://raw.githubusercontent.com/tjdevries/media.repo/3c0eedb38a51e45d2455fc167535de1fd0cfc99d/colorbuddy.nvim/_simple.svg)

Inheritance

![inheritance](https://raw.githubusercontent.com/tjdevries/media.repo/3c0eedb38a51e45d2455fc167535de1fd0cfc99d/colorbuddy.nvim/_inheritance.svg)

## Example

Your color buddy for making cool neovim color schemes. Write your colorscheme in lua!

You can see one example for gruvbox-esque styles [here](https://github.com/tjdevries/gruvbuddy.nvim).

Example:

```lua
local Color, colors, Group, groups, styles = require('colorbuddy').setup()

-- Use Color.new(<name>, <#rrggbb>) to create new colors
-- They can be accessed through colors.<name>
Color.new('background',  '#282c34')
Color.new('red',         '#cc6666')
Color.new('green',       '#99cc99')
Color.new('yellow',      '#f0c674')

-- Define highlights in terms of `colors` and `groups`
Group.new('Function'        , colors.yellow      , colors.background , styles.bold)
Group.new('luaFunctionCall' , groups.Function    , groups.Function   , groups.Function)

-- Define highlights in relative terms of other colors
Group.new('Error'           , colors.red:light() , nil               , s.bold)
```


### Advanced Examples

```lua
-- Optionally, you can just use the globals created when calling `setup()`
-- No need to declare new locals
require('colorbuddy').setup()

-- If you want multiple styles, just add them!
Group.new('italicBoldFunction', colors.green, groups.Function, styles.bold + styles.italic)

-- If you want the same style as a different group, but without a style: just subtract it!
Group.new('boldFunction', colors.yellow, colors.background, groups.italicBoldFunction - styles.italic)
```

## Made with Colorbuddy

- [Gruvbuddy](https://github.com/tjdevries/gruvbuddy.nvim) (Made by me!)

- [Haoren-Nordic](https://github.com/haorenW1025/config/blob/master/.config/nvim/lua/color.lua)

![haoren](https://raw.githubusercontent.com/tjdevries/media.repo/master/colorbuddy.nvim/haoren_nord_scheme.png)

- [Modus-Themes](https://github.com/ishan9299/modus-theme-vim)

- [Spacebuddy](https://github.com/Th3Whit3Wolf/spacebuddy)

- [Onebuddy](https://github.com/Th3Whit3Wolf/onebuddy)

- [Material.nvim](https://github.com/marko-cerovac/material.nvim)
