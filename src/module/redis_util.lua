local redis = require "resty.redis"
local config = require "config"

local _M = {}

function _M.getValue(self, key) 
    local func = function(rd, table_params)
        local value = rd:get(table_params[1])
        return value
    end
    return self:exec(func, key)
end

function _M.exec(self, func, ...)
    local rd = redis:new()
    rd:set_timeouts(config.redis.connect_timeout, config.redis.send_timeout, config.redis.read_timeout)
    local ok, err = rd:connect(config.redis.ip, config.redis.port)
    if not ok then 
        ngx.say("failed to connect redis: ", err)
        return
    end
    if func then
        return func(rd, {...})
    end
    local ok, err = rd:set_keepalive(config.redis.keepalive, config.redis.pool_size)
    if not ok then 
        ngx.say("failed to set keepalive: ", err)
        return
    end 
end

return _M;