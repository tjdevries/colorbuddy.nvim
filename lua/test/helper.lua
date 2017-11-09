
local helper = {}

helper.eq_float = function(a, b)
    local epsilon = a * 0.0001

    return assert((a - epsilon < b) and (a + epsilon > b))
end

return helper
