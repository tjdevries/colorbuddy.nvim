# colorbuddy.nvim

NOTE: now requires neovim 0.9 or nightly

(If you were using old version, you can use the tag `v1.0.0`)

A colorscheme helper for Neovim.

Written in Lua! Quick & Easy Color Schemes :smile:

Sincerely, your color buddy.

# Installation

Install the plugin with your preferred package manager:

## [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- Lua
{
  "tjdevries/colorbuddy.nvim",
}
```

## [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use "tjdevries/colorbuddy.nvim"
```

## [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'tjdevries/colorbuddy.nvim'
```


# Basic Usage

```lua
vim.cmd.colorscheme("colorbuddy")
-- or
vim.cmd.colorscheme("gruvbuddy")
```

## Example

Your color buddy for making cool neovim color schemes. Write your colorscheme in lua!

You can see one example for gruvbox-esque styles [here](https://github.com/tjdevries/gruvbuddy.nvim).

Example:

```lua
-- file: colors/my-colorscheme-name.lua

local colorbuddy = require('colorbuddy')

-- Set up your custom colorscheme if you want
colorbuddy.colorscheme("my-colorscheme-name")

-- And then modify as you like
local Color = colorbuddy.Color
local colors = colorbuddy.colors
local Group = colorbuddy.Group
local groups = colorbuddy.groups
local styles = colorbuddy.styles

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
Group.new('Error'           , colors.red:light() , nil               , styles.bold)

-- If you want multiple styles, just add them!
Group.new('italicBoldFunction', colors.green, groups.Function, styles.bold + styles.italic)

-- If you want the same style as a different group, but without a style: just subtract it!
Group.new('boldFunction', colors.yellow, colors.background, groups.italicBoldFunction - styles.italic)
```

## Made with Colorbuddy

See the wiki!
