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