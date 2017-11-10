local log = require('colorbuddy.log')

local modifiers = require('colorbuddy.modifiers').modifiers
local util = require('colorbuddy.util')
-- util gives us some new globals:
-- luacheck: globals table.extend
-- luacheck: globals table.slice

local color_hash = {}

local add_color = function(c)
    color_hash[string.lower(c.name)] = c
end

local is_existing_color = function(raw_key)
    return color_hash[string.lower(raw_key)] ~= nil
end
local find_color = function(_, raw_key)
    local key = string.lower(raw_key)

    if is_existing_color(key) then
        return color_hash[key]
    else
        return {}
    end
end

local colors = {}
local __colors_mt = {
    __metatable = {},
    __index = find_color,
}
setmetatable(colors, __colors_mt)

local Color = {}
local IndexColor = function(_, key)
    if Color[key] ~= nil then
        return Color[key]
    end

    -- Return what the modifiers would be if we ran it based on the table's values
    if modifiers[key] then
        return function(s_table, ...) return modifiers[key](s_table.H, s_table.S, s_table.L, ...) end
    end

    return nil
end
local color_object_to_string = function(self)
    return string.format('[%s: (%s, %s, %s)]', self.name, self.H, self.S, self.L)
end

local __local_mt = {
    __type__ = 'color',
    __metatable = {},
    __index = IndexColor,
    __tostring = color_object_to_string,
}

-- Color:
--  name
--  H, S, L
--  children: A table of all the colors that depend on this color
Color.new = function(name, H, S, L, mods)
    assert(__local_mt)

    if type(H) == "string" and H:sub(1, 1) == "#" and H:len() == 7 then
        H, S, L = util.rgb_string_to_hsl(H)
    end

    -- Get an existing color if possible, so that we can update any references to this color
    -- when you use something like 'Color.new('red', ...)' twice
    local object
    if is_existing_color(name) then
        object = find_color(nil, name)
        object.H = H
        object.S = S
        object.L = L
    else
        object = setmetatable({
            __type__ = 'color',
            name = name,
            H = H,
            S = S,
            L = L,
            children = {},
            modifiers = mods,
        }, __local_mt)

        add_color(object)
    end

    return object
end

Color.to_rgb = function(self, H, S, L)
    if H == nil then H = self.H end
    if S == nil then S = self.S end
    if L == nil then L = self.L end

    local rgb = {util.hsl_to_rgb(H, S, L)}
    local buffer = "#"

    for _, v in ipairs(rgb) do
        buffer = buffer .. string.format("%02x", math.floor(v * 256 + 0.1))
    end

    return buffer
end

Color.apply_modifier = function(self, modifier_key, ...)
    log.debug('Applying Modifier for:', self.name, ' / ', modifier_key)
    if modifiers[modifier_key] == nil then
        print('Invalid key:', modifier_key, '. Please use a valid key')
        return nil
    end

    local new_hsl = modifiers[modifier_key](self.H, self.S, self.L, ...)
    self.H, self.S, self.L = unpack(new_hsl)

    -- Update all of the children.
    for _, child in pairs(self.children) do
        child:apply_modifier(modifier_key, ...)
    end
    -- FIXME: Check for loops within the children.
    -- FIXME: Call an event to update any color groups
end

Color._add_child = function(self, child)
    self.children[string.lower(child.name)] = child
end


Color.new_child = function(self, name, ...)
    if self.children[string.lower(name)] ~= nil then
        print('ERROR: must not use same name')
        return nil
    end

    log.debug('New Child: ', self, name, ...)
    local hsl_table = {self.H, self.S, self.L}

    for i, v in ipairs({...}) do
        log.debug('(i, v)', i, v)
        if type(v) == 'string' then
            if modifiers[v] ~= nil then
                log.debug('Applying string: ', i, v)
                hsl_table = modifiers[v](unpack(hsl_table))
            end
        elseif type(v) == 'table' then
            if modifiers[v[1]] ~= nil then
                local new_arg_table = table.extend(hsl_table, table.slice(v, 2))
                hsl_table = modifiers[v[1]](unpack(new_arg_table))
            end
        end
    end
    local kid = Color.new(name, unpack(hsl_table))

    self:_add_child(kid)

    return kid
end

local is_color_object = function(c)
    if c == nil then
        return false
    end

    return c.__type__ == 'color'
end

return {
    colors = colors,
    Color = Color,
    is_color_object = is_color_object,
}
