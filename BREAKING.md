# Breaking Changes

- Color.new
  - Now only accepts string `#RRGGBB` OR `ColorbuddyHSL` OR `ColorbuddyRGB`
  - Old usages of `Color.new("name", "#ffffff")` will still work (which was as many as I could find)
- Color:new_child
  - If you were using this (not thinking anyone actually was though, it wasn't really required)
    then you need to now pass modifiers as a table.
