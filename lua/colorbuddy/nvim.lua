local log = require('colorbuddy.log')

-- luacheck: globals vim
vim = vim or {}

nvim = vim.api or setmetatable({}, {
    __index = function(_, key)
        return function(...)
            log.debug(string.format('[nvim.%s]', key), ...)
        end
    end
})

return nvim
