-- luacheck: globals vim
local vim = vim or {}

-- TODO: Make this into a cool metamethod index to just print what I want to call
local nvim = vim.api or {
    nvim_call_function = function(...)
        print('[NVIM.call_function]', ...)
    end,

    nvim_command = function(...)
        print('[NVIM.command]', ...)
    end,
}

return nvim
