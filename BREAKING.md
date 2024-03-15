# Breaking Changes

### v2

These are the following breaking changes moving from previous version
into the new v2 branch. If I have to make bad breaking changes again in
the future, then we'll move to `v3` i guess

- now requires latest neovim 0.8 (as of august 17)
- now uses "@<group>" names primarily

- Color.new
  - Now only accepts string `#RRGGBB` OR `ColorbuddyHSL` OR `ColorbuddyRGB`
  - Old usages of `Color.new("name", "#ffffff")` will still work (which was as many as I could find)
- Color:new_child
  - If you were using this (not thinking anyone actually was though, it wasn't really required)
    then you need to now pass modifiers as a table.


