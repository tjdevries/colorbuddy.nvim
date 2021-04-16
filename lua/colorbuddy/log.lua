local log = {}
log.level_enum = {
  debug = 1,
  info = 2,
  warn = 3,
}

log.level = "info"

log.debug = function(...)
  if log.level_enum[log.level] <= log.level_enum["debug"] then
    print("[DEBUG]", ...)
  end
end

log.info = function(...)
  if log.level_enum[log.level] <= log.level_enum["info"] then
    print("[INFO ]", ...)
  end
end

log.warn = function(...)
  if log.level_enum[log.level] <= log.level_enum["warn"] then
    print("----------------------------------------------------------------------")
    print("[WARN ]", ...)
    -- print(debug.traceback())
    print("----------------------------------------------------------------------")
  end
end

return log
