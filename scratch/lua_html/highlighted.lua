local template = require("resty.template")
template.caching(false)

local highlighted = {}
local compiled = {
  element = template.compile("templates/element.html"),
  line = template.compile("templates/vim_line.html"),
  file = template.compile("templates/file.html"),
}

highlighted.element = function(group)
  return compiled.element({ group })
end

highlighted.line = function(line, groups)
  return compiled.line({ line = line, groups = groups })
end

highlighted.file = function(start_line, lines, required_groups, syntax_attributes, syn_ids)
  return compiled.file({
    startLine = start_line,
    lines = lines,
    requiredGroups = required_groups,
    syntaxAttributes = syntax_attributes,
    synIDs = syn_ids,
  })
end

return highlighted
