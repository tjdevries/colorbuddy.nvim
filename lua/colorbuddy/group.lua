
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


local group_object_to_string = function(self)
    return string.format('[%s: fg=%s, bg=%s, s=%s]',
        self.name
        , self.fg.name
        , self.bg.name
        , self.style.name
    )
end


local Group = {}
local __local_mt = {
    __metatable = {},
    -- __index =
    __tostring = group_object_to_string,

    -- FIXME: Subtraction for (Group - Group), (Group -> modifier(color)), and (Group - Style)
    -- FIXME: Addition for (Group + Group), (Group -> modifier(color)), and (Group + Style)
}

Group.new = function(name, fg, bg, style)
    name = string.lower(name)

    -- FIXME: Handle using a Group as an fg
    local fg_color
    if is_group_object(fg) then
        -- FIXME: Keep track of this kiddo
        fg_color = fg.fg
    elseif is_color_object(fg) then
        -- FIXME: Link colors objects to this group
        fg_color = fg
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

Group.apply = function(self)
    nvim.nvim_command(
        string.format('highlight %s guifg=%s guibg=%s gui=%s',
            self.name,
            self.fg:to_rgb(),
            self.bg:to_rgb(),
            self.style:to_nvim()
        )
    )
end



return {
    groups = groups,
    Group = Group,
    is_group_object = is_group_object,
}
