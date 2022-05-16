# Breaking Changes

- Color.new
  - Now only accepts string `#RRGGBB` OR `ColorbuddyHSL` OR `ColorbuddyRGB`
  - Old usages of `Color.new("name", "#ffffff")` will still work (which was as many as I could find)
