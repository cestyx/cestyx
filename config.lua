local Config = {}

-- TNT configuration
Config.tarantool = {
  node = {
    memtx_memory         = 1024 * 1024 * 1024 * 2,  -- 2Gb
    memtx_max_tuple_size = 1024 * 1024 * 5,         -- 5Mb
    pid_file             = './tmp/qube.pid',
    memtx_dir            = './tmp',
    wal_dir              = './tmp',
    log                  = './tmp/qube.log',
    background           = false,
    custom_proc_title    = 'cestix',
    log_level            = 5,
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

Config.cestix = {
  default_expiration = 5 * 60,  -- 5 min
  allow_create_space = true,    -- Cestix can create new space
  space_prefix       = 'cestix' -- spaces will created with name cestix_<some_passed_name>
}

return Config