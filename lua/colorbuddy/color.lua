
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

local next_color = function(_)

    local stateless_iterator = function(_, k)
        local v

        k, v = next(color_hash, k)

        if k == 'none' then
            k, v = next(color_hash, k)
        end

        if v then return k, v end
    end

    return stateless_iterator, color_hash, nil
end

local colors = {}
local __colors_mt = {
    __metatable = {},
    __index = find_color,
    __pairs = next_color,
}
setmetatable(colors, __colors_mt)

local Color = {}
local __current_index = 0
local getIndexColorNumber = function()
    __current_index = __current_index + 1
    return __current_index
end

local IndexColor = function(_, key)
    if Color[key] ~= nil then
        return Color[key]
    end

    -- Return what the modifiers would be if we ran it based on the table's values
    if modifiers[key] then
        return function(s_table, ...)
            if s_table == nil then
                print(debug.traceback())
                return nil
            end

            local kiddo = s_table:new_child(
                s_table.name .. '-' .. tostring(getIndexColorNumber()), {key, unpack({...})}
            )

            return kiddo
        end
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
    if type(mods) == type({}) and mods ~= {} then
        H, S, L = unpack(Color.modifier_result({H=H, S=S, L=L}, unpack(mods)))
    end

    return setmetatable({
        __type__ = 'color',
        name = name,
        H = H,
        S = S,
        L = L,
        mods = mods,

        -- Objects that depend on what this color is
        --  When "self" is changed, we update the attributes of these colors.
        --  See: |modifier_apply|
        children = {},

        -- TODO: Maybe make more than one of these?
        -- The parent of this object
        --  When "self" is changed, we wait until these have been updated
        parent = {},

    }, __local_mt)
end
Color.new = function(name, H, S, L, mods)
    -- Color:
    --  name
    --  H, S, L
    --  children: A table of all the colors that depend on this color
    assert(__local_mt)

    if H == nil then
        local obj =  {
            __type__ = 'color',
            name = name,
            _add_child = function(...) return {...} end,
            to_rgb = Color.to_rgb
        }

        add_color(obj)

        return obj
    elseif type(H) == "string" and H:sub(1, 1) == "#" and H:len() == 7 then
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

        object.mods = mods

        -- FIXME: Alert any colors that depend on this object that we have a new definition
        -- and then apply the modifiers correctly

        for child, _ in pairs(object.children) do
            log.debug('Updating child:', child)

            if child.update ~= nil then
                child:update()
            else
                log.warn('No update method found for:', child)
            end
        end
    else
        object = Color.__private_create(name, H, S, L, mods)
        add_color(object)
    end

    return object
end
Color.to_rgb = function(self, H, S, L)
    if self.name == 'none' then
        return 'none'
    end

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
            else
                error(string.format('Invalid key: "%s". Please use a valid key', modifier_key))
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
    local updated = {}

    for child, _ in pairs(self.children) do
        if child.update ~= nil then
            child:update(updated)
        else
            log.warn('No update method found for:', child)
            log.warn('TYPE WAS: ', child.__type__)
        end
    end
    -- FIXME: Check for loops within the children.
    -- FIXME: Call an event to update any color groups

    return updated
end
Color._add_child = function(self, child)
    self.children[child] = true
    child.parent = self
end
Color.new_child = function(self, name, ...)
    if self.children[string.lower(name)] ~= nil then
        print('ERROR: must not use same name')
        return nil
    end

    log.debug('New Child: ', self, name, ...)
    local kid_args = {self.H, self.S, self.L}
    kid_args[4] = {}
    for index, passed_arg in ipairs({...}) do
        kid_args[4][index] = passed_arg
    end

    local kid = Color.new(name, unpack(kid_args))

    self:_add_child(kid)

    return kid
end
Color.update = function(self, updated)
    -- TODO: We don't full handle loops right now, since we  don't pass updated to anywhere
    if updated == nil then
        updated = {}
    end

    if updated[self] then
        return
    end

    updated[self] = true

    self.H = self.parent.H
    self.S = self.parent.S
    self.L = self.parent.L

    if type(self.mods) == type({})  then
        self:modifier_apply(unpack(self.mods))
    end

    return updated
end

local is_color_object = function(c)
    if c == nil then
        return false
    end

    return c.__type__ == 'color'
end

local _clear_colors = function() color_hash = {} end


Color.new('none')

return {
    colors = colors,
    Color = Color,
    is_color_object = is_color_object,
    _clear_colors = _clear_colors,
}
