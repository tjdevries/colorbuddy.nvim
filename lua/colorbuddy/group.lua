
local nvim = require('colorbuddy.nvim')

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


-- {{{1 Arithmetic Functions
-- {{{2 MixedGroup
local MixedGroup = {}
-- {{{2 Addition
local group_handle_mixed_addition = function(left, right)
    local mixed = {
        __type__ = 'mixed',
    }

    mixed.parents = {
        group = {},
        color = {},
        style = {},
        mixed = {},
    }

    if left.__type__ == nil then
        error(string.format('You cannot add these: -> nil type %s, %s', left, right))
    end

    if right.__type__ == nil then
        error(string.format('You cannot add these: %s, %s <- nil type', left, right))
    end

    mixed.parents[left.__type__][left.name] = left
    mixed.parents[right.__type__][right.name] = right

    mixed.left = left
    mixed.right = right

    return mixed
end

local apply_mixed_addition = function(group_attr, mixed)
    local left_item, right_item

    if is_group_object(mixed.left) then
        left_item = mixed.left[group_attr]
    else
        left_item = mixed.left
    end

    if is_group_object(mixed.right) then
        right_item = mixed.right[group_attr]
    else
        right_item = mixed.right
    end

    return left_item + right_item
end

local is_mixed_object = function(m)
    if m == nil then
        return false
    end

    return m.__type__ == 'mixed'
end

-- {{{2 Final creation of mixed group
local __mixed_group_mt = {
    __metatable = {},

    __add = group_handle_mixed_addition,
}
setmetatable(MixedGroup, __mixed_group_mt)

local group_object_to_string = function(self) -- {{{1
    return string.format('[%s: fg=%s, bg=%s, s=%s]',
        self.name
        , self.fg.name
        , self.bg.name
        , self.style.name
    )
end


local Group = {} -- {{{1
local __local_mt = {
    __metatable = {},
    -- __index =
    __tostring = group_object_to_string,

    -- FIXME: Subtraction for (Group - Group), (Group -> modifier(color)), and (Group - Style)
    -- FIXME: Addition for (Group + Group), (Group -> modifier(color)), and (Group + Style)
    __add = group_handle_mixed_addition,
}

Group.new = function(name, fg, bg, style) -- {{{2
    name = string.lower(name)

    -- FIXME: Handle using a Group as an fg
    local fg_color
    if is_group_object(fg) then
        -- FIXME: Keep track of this kiddo
        fg_color = fg.fg
    elseif is_color_object(fg) then
        -- FIXME: Link colors objects to this group
        fg_color = fg
    elseif is_mixed_object(fg) then
        fg_color = apply_mixed_addition('fg', fg)
    else
        error('Not a valid foreground color: ' .. tostring(fg))
    end

    local bg_color
    if is_group_object(bg) then
        -- FIXME: Keep track of this group
        bg_color = bg.bg
    elseif is_color_object(bg) then
        -- FIXME: Link colors objects to this group
        bg_color = bg
    elseif is_mixed_object(bg) then
        bg_color = apply_mixed_addition('bg', bg)
    else
        error('Not a valid background color: ' .. tostring(bg))
    end

    local style_style
    if is_group_object(style) then
        style_style = style.style
    elseif is_style_object(style) then
        style_style = style
    elseif style == nil then
        style_style = styles.none
    else
        error('Not a valid style: ' .. tostring(style))
    end

    -- FIXME: Handle using a Group as a style

    local obj = setmetatable({
        __type__ = 'group',
        name = name,
        fg = fg_color,
        bg = bg_color,
        style = style_style,
        group_children = {},
        color_children = {},
        -- Don't think I need this... Leaving it here as a reminder for when I'm wrong
        -- style_children = {}
    }, __local_mt)

    group_hash[name] = obj
    Group.apply(obj)

    return obj
end

Group.apply = function(self) -- {{{2
    nvim.nvim_command(
        string.format('highlight %s guifg=%s guibg=%s gui=%s',
            self.name,
            self.fg:to_rgb(),
            self.bg:to_rgb(),
            self.style:to_nvim()
        )
    )
end



return { -- {{{1
    groups = groups,
    Group = Group,
    is_group_object = is_group_object,
}
