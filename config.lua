local Config = {}

-- TNT configuration
Config.tarantool = {
  node = {
    memtx_memory         = 1024 * 1024 * 1024 * 2,  -- 2Gb
    memtx_max_tuple_size = 1024 * 1024 * 5,         -- 5Mb
    pid_file             = 'tmp/cestyx.pid',
    memtx_dir            = 'tmp',
    wal_dir              = 'tmp',
    -- log                  = 'tmp/cestyx.log',
    background           = false,
    custom_proc_title    = 'cestyx',
    log_level            = 5
  }
}

-- HTTP Server
Config.http = {
  root         = '/api/v1',
  host         = '127.0.0.1',
  port         = '7000',
  token        = 'ca438b3f1abc25bf9a404a5136faaabc',
  log_requests = true,
  log_errors   = true
}

Config.cestyx = {
  default_expiration = 5 * 60,   -- 5 min
  space_prefix       = 'cestyx', -- Spaces will created with name cestyx_<some_passed_name>
}

return Config