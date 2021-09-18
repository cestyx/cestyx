## Cestyx
HTTP Proxy-cache based on Tarantool

### Installation
1. Install [Tarantool](https://github.com/tarantool/tarantool) or `brew install tarantool`
3. Install [HTTP](https://github.com/tarantool/http) or `tarantoolctl rocks install http`
4. `git clone https://github.com/cestyx/cestyx.git`
5. Edit config:

```Lua
local Config = {}

-- TNT configuration
Config.tarantool = {
  node = {
    memtx_memory         = 1024 * 1024 * 1024 * 2,   -- 2Gb
    memtx_max_tuple_size = 1024 * 1024 * 10,         -- 5Mb
    pid_file             = 'tmp/cestyx.pid',
    memtx_dir            = 'tmp',
    wal_dir              = 'tmp',
    -- log                  = 'tmp/cestyx.log',
    background           = false,
    custom_proc_title    = 'cestyx',
    log_level            = 5,
    feedback_enabled     = false,
    -- wal_mode             = 'none',
    -- checkpoint_interval  = 0,
  }
}

-- HTTP Server
Config.http = {
  root         = '/api/v1',
  host         = '127.0.0.1',
  port         = '7000',
  token        = 'ca438b',
  log_requests = true,
  log_errors   = true
}

Config.cestyx = {
  default_expiration = 5 * 60,   -- 5 min
  space_prefix       = 'cestyx', -- Spaces will created with name cestyx_<some_passed_name>
  clearing_interval  = 5,        -- Interval between clearing spaces in sec.
}

return Config
```

Run Cestix
```
tarantool init.lua
```

### Usage

```sh
curl --silent -X POST \
  -H "X-AUTH-TOKEN: ca438b" \
  -H "X-Space: some_space" \
  -H "X-Key: some_unique_key" \
  -H "X-Expires: 1631937866" \
  -H "Content-Type: application/json" \
  --data "@request.json" \
  http://127.0.0.1:7000/api/v1/_proxy
```

request.json
```json
{
  "url": "http://127.0.0.1:4567/some_path",
  "method": "GET",
  "headers": ["Accept: text/html"],
  "body": {}
}
```
