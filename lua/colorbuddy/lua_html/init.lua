local nvim = vim.api

local inspect = require('inspect')

local debug = true
local log = function(...) if debug then print('lua_html:', ...) end end

local __hl_ids = {}
local __syn_ids = {}
local __syntax_attributes = {}

local hl_ids = setmetatable({}, {
  __index = function(self, key)
    if __hl_ids[key] == nil then
      __hl_ids[key] = nvim.nvim_call_function('hlID', { key })
    end

    return __hl_ids[key]
  end,
})

local syn_ids = setmetatable({ }, {
  __index = function(self, key)
    if __syn_ids[key] == nil then
      __syn_ids[key] = nvim.nvim_call_function( 'synIDtrans', { hl_ids[key] })
    end

    return __syn_ids[key]
  end,
})

local SyntaxGroup = {}
local syntax_attributes = setmetatable({}, {
  __index = function(self, key)
    if __syntax_attributes[key] == nil then
      log('syntax_attributes => creating new attribute', key)

      __syntax_attributes[key] = SyntaxGroup:new(key)
    end

    return __syntax_attributes[key]
  end,
})

local __syntax_group_mt = {
  __index = function(obj, key)
    if key == '_' then
      return rawget(obj, '_')
    end

    if obj._[key] == nil then
      log('... accessing neovim // ', obj.synID, '//', key)
      obj._[key] = nvim.nvim_call_function('synIDattr', { rawget(obj, 'synID'), key, 'gui' })
    end

    return obj._[key]
  end,
}

SyntaxGroup.new = function(self, synID)
  log('making new syntax group:', synID)
  local obj = {
    synID = synID,
    _ = {}
  }

  return setmetatable(obj, __syntax_group_mt)
end

local syn_id_at_location = function(line, column)
  return nvim.nvim_call_function('synID', { line, column, 1 })
end

local syn_ids_for_line = function(line)
  local max_column = nvim.nvim_call_function('col', { '$' })
  local current_line = nvim.nvim_call_function('getline', { line })

  print(current_line)

  local groups = {}
  local current_group = nil
  local current_text = ''
  for column = 1,max_column do
    current_id = syn_id_at_location(line, column)
    current_text = current_text .. string.sub(current_line, column - 1, column - 1)

    if current_id ~= current_group then
      if current_group ~= nil then
        table.insert(groups, {
          line = line,
          column = column,
          syntax_id = current_group,
          text = current_text,
          syntax_name = syntax_attributes[current_group].name,
        })
      end

      current_group = current_id
      current_text = ''
    end
  end

  return groups
end

local convert_to_html = function(line_1, line_2)
end


-- local comment = syntax_attributes[syn_ids['comment']]
-- print(inspect(comment))
-- print(inspect(comment.bg))
-- local this_id = syn_id_at_location(63, 1)
-- print(this_id)
-- print(nvim.nvim_call_function('synIDattr', { this_id , 'name' }))

-- print(require('inspect')(syn_ids_for_line(6)))

line_6_ids = syn_ids_for_line(6)
lines_to_set = {}

for index, value in ipairs(line_6_ids) do
  table.insert(lines_to_set, string.format('%-20s: %s', value.syntax_name, value.text))
end

print(inspect(lines_to_set))
nvim.nvim_buf_set_lines(14, 0, -1, false, lines_to_set)

return {
  syntax_attributes = syntax_attributes,
}
