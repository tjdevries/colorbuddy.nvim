local execute = {}

execute.add = function(left, right)
  return left + right
end

execute.subtract = function(left, right)
  return left - right
end

execute.fif = function(condition, t, f)
  if condition then
    return t
  else
    return f
  end
end

local mappings = {
  ["-"] = execute.subtract,
  ["+"] = execute.add,
  ["if"] = execute.fif,
}

execute.map = function(operation, ...)
  if mappings[operation] == nil then
    return nil
  end

  return mappings[operation](...)
end

return execute
