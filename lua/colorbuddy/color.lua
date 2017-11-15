
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

local color_arithmetic = function(operation)
    return function(left, right)
        return Color.__private_create(nil, unpack(modifiers[operation](left.H, left.S, left.L, right, 1)))
    end
end

local color_object_add = function(left, right)
    return color_arithmetic('add')(left, right)
end

local color_object_sub = function(left, right)
    return color_arithmetic('subtract')(left, right)
end

local __local_mt = {
    __type__ = 'color',
    __metatable = {},
    __index = IndexColor,
    __tostring = color_object_to_string,

    -- FIXME: Determine what the basic arithmetic operators should do for colors...
    __add = color_object_add,
    __sub = color_object_sub,
}

Color.__private_create = function(name, H, S, L, mods)
    return setmetatable({
        __type__ = 'color',
        name = name,
        H = H,
        S = S,
        L = L,
        modifiers = mods,

        -- Objects that depend on what this color is
        --  When "self" is changed, we update the attributes of these colors.
        --  See: |modifier_apply|
        children = {},

        -- Objects that we depend on
        --  When "self" is changed, we wait until these have been updated
        parents = {},

    }, __local_mt)
end
Color.new = function(name, H, S, L, mods)
    -- Color:
    --  name
    --  H, S, L
    --  children: A table of all the colors that depend on this color
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

        -- FIXME: Alert any colors that depend on this object that we have a new definition
        -- and then apply the modifiers correctly

        for child, _ in pairs(object.children) do
            log.info('Updating child:', child)
            child:update()
        end
    else
        object = Color.__private_create(name, H, S, L, mods)
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
Color.modifier_result = function(self, ...)
    -- Accepts arguments of:
    --  string: The name of a modifier for a color
    --  table: the {name, [arguments]} of a modifier
    local hsl_table = {self.H, self.S, self.L}

    for i, current_modifier in ipairs({...}) do
        if type(current_modifier) == 'string' then
            if modifiers[current_modifier] ~= nil then
                log.debug('Applying string: ', i, current_modifier)
                hsl_table = modifiers[current_modifier](unpack(hsl_table))
            else
                error(string.format('Invalid key: "%s". Please use a valid key', current_modifier))
            end
        elseif type(current_modifier) == 'table' then
            local modifier_key = current_modifier[1]
            local modifier_arguments = table.slice(current_modifier, 2)

            if modifiers[modifier_key] ~= nil then
                local new_arg_table = table.extend(hsl_table, modifier_arguments)
                hsl_table = modifiers[modifier_key](unpack(new_arg_table))
            end
        end
    end

    return hsl_table
end
Color.modifier_apply = function(self, ...)
    log.debug('Applying Modifier for:', self.name, ' / ', ...)
    local new_hsl = self:modifier_result(...)
    self.H, self.S, self.L = unpack(new_hsl)

    -- Update all of the children.
    for _, child in pairs(self.children) do
        child:modifier_apply(...)
    end
    -- FIXME: Check for loops within the children.
    -- FIXME: Call an event to update any color groups
end
Color._add_child = function(self, child)
    self.children[child] = true
end
Color.new_child = function(self, name, ...)
    if self.children[string.lower(name)] ~= nil then
        print('ERROR: must not use same name')
        return nil
    end

    log.debug('New Child: ', self, name, ...)
    local hsl_table = self:modifier_result(...)

    local kid_args = {unpack(hsl_table)}
    kid_args[4] = {}
    for index, passed_arg in ipairs({...}) do
        kid_args[4][index] = passed_arg
    end

    local kid = Color.new(name, unpack(kid_args))

    self:_add_child(kid)

    return kid
end
Color.update = function(self, updated)

    return
end

local is_color_object = function(c)
    if c == nil then
        return false
    end

    return c.__type__ == 'color'
end

local _clear_colors = function() color_hash = {} end


return {
    colors = colors,
    Color = Color,
    is_color_object = is_color_object,
    _clear_colors = _clear_colors,
}
