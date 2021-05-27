local _M = {}

_M.redis = {
    ip = "127.0.0.1",
    port = 6379,
    connect_timeout = 1000,
    send_timeout = 1000,
    read_timeout = 1000,
    pool_size = 100,
    keepalive = 10000
}

return _M;