local log_module = require("colorbuddy.lua_html.log")
local debug = log_module.debug
local log = log_module.log

local nvim = vim.api

if debug then
  package.loaded["colorbuddy.lua_html.log"] = nil
  package.loaded["colorbuddy.lua_html.highlighted"] = nil
  package.loaded["colorbuddy.lua_html.vim_element"] = nil
  package.loaded["colorbuddy.lua_html.syntax_group"] = nil
end

log_module.debug = false

local inspect = require("inspect")

local highlighted = require("colorbuddy.lua_html.highlighted")
local VimElement = require("colorbuddy.lua_html.vim_element")
local SyntaxGroup = require("colorbuddy.lua_html.syntax_group")

local __hl_ids = {}
local __syn_ids = {}
local __syntax_attributes = {}

local hl_ids = setmetatable({}, {
  __index = function(self, key)
    if __hl_ids[key] == nil then
      __hl_ids[key] = nvim.nvim_call_function("hlID", { key })
    end

    return __hl_ids[key]
  end,
})

local syn_ids = setmetatable({}, {
  __index = function(self, key)
    if __syn_ids[key] == nil then
      __syn_ids[key] = nvim.nvim_call_function("synIDtrans", { hl_ids[key] })
    end

    return __syn_ids[key]
  end,
})

local syntax_attributes = setmetatable({}, {
  __index = function(self, key)
    if __syntax_attributes[key] == nil then
      log("syntax_attributes => creating new attribute", key)

      __syntax_attributes[key] = SyntaxGroup:new(key)
    end

    return __syntax_attributes[key]
  end,
})

local syn_id_at_location = function(line, column)
  return nvim.nvim_call_function("synIDtrans", { nvim.nvim_call_function("synID", { line, column, 1 }) })
end

local syn_ids_for_line = function(line, buffer_id)
  if buffer_id == nil then
    buffer_id = 0
  end

  local current_line = nvim.nvim_buf_get_lines(0, line - 1, line, false)[1]
  local max_column = #current_line + 1

  local groups = {}
  local previous_id = nil
  local current_text = ""

  local previous_column = 0
  for column = 1, max_column do
    current_id = syn_id_at_location(line, column)
    current_text = current_text .. string.sub(current_line, column - 1, column - 1)

    if current_id ~= previous_id then
      if previous_id ~= nil then
        if current_text ~= "" then
          table.insert(
            groups,
            VimElement:new(line, previous_column, column, current_text, syntax_attributes[previous_id])
          )
        end
      end

      previous_id = current_id
      current_text = ""
      previous_column = column
    end
  end

  if current_text ~= "" then
    table.insert(
      groups,
      VimElement:new(line, previous_column, max_column, current_text, syntax_attributes[previous_id])
    )
  end

  return groups
end

local get_html_line = function(line)
  ids_for_line = syn_ids_for_line(line)

  final_string = ""
  for index, value in ipairs(ids_for_line) do
    final_string = final_string .. highlighted.element(value)
  end

  return highlighted.line(final_string)
end

local convert_to_html = function(line_1, line_2, output_file)
  file = io.open(output_file, "w")

  if file == nil then
    print("File could not be read: ", output_file)
    return
  else
    print("Writing to: ", output_file)
  end

  local parsed_lines = {}
  local __required_groups = {}
  local required_groups = {}

  for line = line_1, line_2 do
    current_ids = syn_ids_for_line(line)
    table.insert(parsed_lines, current_ids)

    for _, synID in ipairs(current_ids) do
      if __required_groups[synID.name] == nil then
        __required_groups[synID.name] = true
        required_groups[synID] = true
      end
    end
  end

  file:write(highlighted.file(line_1, parsed_lines, required_groups, syntax_attributes, syn_ids))
  file:close()
end

-- convert_to_html(5, 100, nvim.nvim_call_function('expand', {'~/test/color_output.html'}))

return {
  syntax_attributes = syntax_attributes,
  convert_to_html = convert_to_html,
}
