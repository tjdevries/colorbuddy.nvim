
local find_group = function(i_table, raw_key)
    local key = string.lower(raw_key)
end

local groups = {}
local __groups_mt = {
    __metatable = {},
    __index = find_group,
}
setmetatable(groups, __groups_mt)

local Group = {}
local __local_mt = {}

Group.new = function()
    return setmetatable({}, __local_mt)
end


return {
    groups = groups,
}
