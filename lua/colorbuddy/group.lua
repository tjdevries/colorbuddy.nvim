local execute = require('colorbuddy.execute')
local log = require('colorbuddy.log')
local nvim = require('colorbuddy.nvim')
local util = require('colorbuddy.util')

local is_color_object = require('colorbuddy.color').is_color_object
local is_style_object = require('colorbuddy.style').is_style_object

local styles = require('colorbuddy.style').styles

local is_group_object = function(g)
    if g == nil then
        return false
    end

    return g.__type__ == 'group'
end

local group_hash = {}
local find_group = function(_, raw_key)
    local key = string.lower(raw_key)

    if group_hash[key] ~= nil then
        return group_hash[key]
    end

    return {}
end

local groups = {}
local __groups_mt = {
    __metatable = {},
    __index = find_group,
}
setmetatable(groups, __groups_mt)

local MixedGroup = {}

local group_handle_arithmetic = function(operation)
    return function(left, right)
        local mixed = {
            __type__ = 'mixed',
            __operation__ = operation,
        }
        -- TODO: Determine if this is actually required or not
        -- setmetatable(mixed, getmetatable(MixedGroup))

        mixed.parents = {
            group = {},
            color = {},
            style = {},
            mixed = {},
        }

        if left.__type__ == nil or mixed.parents[left.__type__] == nil then
            error(string.format('You cannot add these: -> nil type %s, %s', left, right))
        end

        if right.__type__ == nil or mixed.parents[right.__type__] == nil then
            error(string.format('You cannot add these: %s, %s <- nil type', left, right))
        end

        if left.name == nil then
            error(string.format('"Left" has no name: %s', tostring(left)))
        end

        if right.name == nil then
            error(string.format('"Right" has no name: %s', tostring(right)))
        end


        mixed.parents[left.__type__][left.name] = left
        mixed.parents[right.__type__][right.name] = right

        mixed.left = left
        mixed.right = right

        mixed.name = string.format('%s:<%s>,%s:<%s>', left.__type__, left.name, right.__type__, right.name)

        return mixed
    end
end
local is_mixed_object = function(m)
    if m == nil then
        return false
    end

    return m.__type__ == 'mixed'
end

local __mixed_group_mt = {
    __metatable = {},

    __add = group_handle_arithmetic('+'),
    __sub = group_handle_arithmetic('-'),
}
setmetatable(MixedGroup, __mixed_group_mt)

local Group = {}
Group.__defaults = {}

Group.apply_mixed_arithmetic = function(handler, group_attr, mixed)
    local left_item, right_item

    handler[group_attr] = {
        left = mixed.left,
        right = mixed.right,
    }

    if is_group_object(mixed.left) then
        left_item = mixed.left[group_attr]
    elseif is_mixed_object(mixed.left) then
        left_item = Group.apply_mixed_arithmetic(handler, group_attr, mixed.left)
    else
        left_item = mixed.left
    end

    if is_group_object(mixed.right) then
        right_item = mixed.right[group_attr]
    elseif is_mixed_object(mixed.right) then
        right_item = Group.apply_mixed_arithmetic(handler, group_attr, mixed.right)
    else
        right_item = mixed.right
    end

    return execute.map(mixed.__operation__, left_item, right_item)
end
Group.set_default = function(property, value)
    Group.__defaults[property] = value
end
Group.get_default = function(property)
    return Group.__defaults[property]
end
Group.handle_group_argument = function(handler, val, property, valid_object_function, err_string)
    -- TODO: Keep track of the dependencies here?
    -- If the value is nil, and we have a default, just use that instead
    if val == nil and Group.get_default(property) ~= nil then
        return Group.get_default(property)
    end

    -- Return the property of the group object
    if is_group_object(val) then
        return val[property], val
    end

    -- Return the result of a mixed value
    if is_mixed_object(val) then
        return Group.apply_mixed_arithmetic(handler, property, val)
    end

    -- Return a valid value
    if valid_object_function(val) then
        return val
    end

    -- Special casing:
    if property == 'style' then
        if val == nil then
            return styles.none
        end
    end

    local val_repr = tostring(val)
    if type(val) == 'table' then
        val_repr = '{table}: ' .. tostring(val) .. table.concat(val, ',') .. ' / ' .. util.key_concat(val, ',')
    end

    print(debug.traceback())
    error(err_string .. ': ' .. val_repr)
end

Group.__tostring = function(self)
    if self == nil then
        return ''
    end

    return string.format('[%s: fg=%s, bg=%s, s=%s]',
        tostring(self.name)
        , tostring(self.fg.name)
        , tostring(self.bg.name)
        , tostring(self.style.name)
    )
end

local __local_mt = {
    __metatable = {},
    __index = Group,
    __tostring = Group.__tostring,

    -- FIXME: Handle color modifiers --> lighten, darken, etc.
    __add = group_handle_arithmetic('+'),
    __sub = group_handle_arithmetic('-'),
}

Group.is_existing_group = function(key) return group_hash[string.lower(key)] ~= nil end

Group.__private_create = function(name, fg, bg, style, default, bang)
    name = string.lower(name)

    local handler = {}

    local fg_color, fg_parent = Group.handle_group_argument(
        handler, fg, 'fg', is_color_object,
        'Not a valid foreground color'
    )
    local bg_color, bg_parent = Group.handle_group_argument(
        handler, bg, 'bg', is_color_object,
        'Not a valid background color'
    )
    local style_style, style_parent = Group.handle_group_argument(
        handler, style, 'style', is_style_object,
        'Not a valid style'
    )

    if not is_color_object(fg_color) then
        error('Bad foreground color: ' .. debug.traceback())
    end

    if not is_color_object(bg_color) then
        error('Bad background color: ' .. debug.traceback())
    end

    local obj
    if Group.is_existing_group(name) then
        obj = find_group(nil, name)

        -- Only apply the updates if it isn't a default
        if default then
            return obj
        end

        obj.fg = fg_color
        obj.bg = bg_color
        obj.style = style_style

        obj:update()
    else
        obj = setmetatable({
            -- Define "colorbuddy" type of "group"
            __type__ = 'group',

            -- It should not be set to a "default" highlight unless set by Group.default
            __default__ = default or false,
            __bang__ = bang or false,

            name = name,
            fg = fg_color,
            bg = bg_color,
            style = style_style,

            children = {
                fg = {},
                bg = {},
                style = {},
            },

            -- TODO: Should there be fg, bg, style?
            parents = {},
        }, __local_mt)

        group_hash[name] = obj
    end

    -- Notify producers they have a new consumer
    obj.fg:_add_child(obj)
    obj.bg:_add_child(obj)

    if fg_parent then
        -- table.insert(fg_parent.children, obj)
        fg_parent.children.fg[obj] = true
    end

    if bg_parent then
        -- table.insert(bg_parent.children, obj)
        bg_parent.children.bg[obj] = true
    end

    if style_parent then
        -- table.insert(style_parent.children, obj)
        style_parent.children.style[obj] = true
    end

    -- Send Neovim our updated group
    Group.apply(obj)

    return obj
end

Group.default = function(name, fg, bg, style, bang)
    return Group.__private_create(name, fg, bg, style, true, bang)
end

Group.new = function(name, fg, bg, style)
    return Group.__private_create(name, fg, bg, style, false, false)
end

Group.link = function(name, linked_group)
  return Group.new(name, linked_group, linked_group, linked_group)
end

function Group:apply()
    -- Only clear old highlighting if we're not the default
    if self.__default__ == false then
        -- Clear the current highlighting
        nvim.nvim_command(
            string.format('highlight %s NONE', self.name)
        )
    end

    -- Apply the new highlighting
    nvim.nvim_command(
        string.format('highlight%s %s %s guifg=%s guibg=%s gui=%s'
            , execute.fif(self.__bang__, '!', '')
            , execute.fif(self.__default__, 'default', '')
            , self.name
            , self.fg:to_rgb()
            , self.bg:to_rgb()
            , self.style:to_nvim()
        )
    )
end

Group.update = function(self, updated)
    log.debug("Group Updating...", self.name)

    -- The hash map we'll be using to track the updates already completed
    if updated == nil then
        updated = {}
    end

    -- We've already updated this grouop, just skip it
    if updated[self] then
        return
    end

    -- FIXME: Should make sure that all my dependencies have been updated first.
    --          Would have to have some pretty weird depdencies for that to happen though.

    -- Let neovim know that we've updated
    self:apply()
    updated[self] = true

    -- FIXME: Should alert any depdencies of me that they need to update
    local children_to_update = {}
    for _, property in ipairs({"fg", "bg", "style"}) do
        for child, _ in pairs(self.children[property]) do
            -- Update the child's property
            child[property] = self[property]

            -- Track the children that we're going to update
            children_to_update[child] = true
        end
    end

    for child, _ in pairs(children_to_update) do
        if child.update ~= nil then
            child:update(updated)
        else
            log.warn('No update method found for:', child)
        end
    end

end

local _clear_groups = function() group_hash = {} end

return {
    groups = groups,
    Group = Group,
    is_group_object = is_group_object,
    _clear_groups = _clear_groups,
}
