local log = require('colorbuddy.log')

-- luacheck: globals vim
local vim = vim or {}

-- TODO: Make this into a cool metamethod index to just print what I want to call
local nvim = vim.api or {
    nvim_call_function = function(...)
        log.debug('[NVIM.call_function]', ...)
    end,

    nvim_command = function(...)
        log.debug('[NVIM.command]', ...)
    end,
}

return nvim
