local log = {}
log.debug = true
log.log = function(...)
  if log.debug then
    print("lua_html:", ...)
  end
end

return log
