local redis_util = require "module.redis_util"

local key = ngx.var[1]
local value = redis_util:getValue(key)
ngx.say(value)