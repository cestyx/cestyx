local json    = require('json')
local http    = require('http.client')
local fiber   = require('fiber')
local math    = require('math')
local batches = require('lib.batches')
-- local xray    = require('lib.xray')

local M = {}

M.config = require('config')

M.space_prefix      = M.config.cestyx.space_prefix
M.clearing_interval = M.config.cestyx.clearing_interval
M.cleaner_process   = nil

M.space_format = {
  { name = 'key',     type = 'string' },
  { name = 'data',    type = 'string', is_nullable = true },
  { name = 'expires', type = 'number' },
}

M.space_index_primary = {
  unique = true,
  type   = 'hash',
  parts  = {
    { field = 1, type = 'string' },
  }
}

M.space_index_expiration = {
  unique = false,
  type   = 'tree',
  parts  = {
    { field = 3, type = 'number' },
  }
}

-- Entry point
function M.process_request(request)
  local data = M.unpack(request)
  return M.fetch(data)
end

-- Unpack client request
function M.unpack(request)
  local request_body = json.decode(request:read())
  local request_headers = request:headers()
  return {
    expires = tonumber(request_headers['x-expires']),
    space   = request_headers['x-space'],
    key     = request_headers['x-key'],
    method  = request_body['method'],
    url     = request_body['url'],
    headers = request_body['headers'],
    body    = request_body['body'],
  }
end

-- Get space by name or create new
function M.get_space(name)
  local space_name = M.space_prefix .. '_' .. name
  if box.space[space_name] ~= nil then
    return box.space[space_name]
  else
    return M.create_space(name)
  end
end

-- Create space
function M.create_space(name)
  local space_name = M.space_prefix .. '_' .. name
  local space = box.schema.space.create(space_name, { engine = 'memtx', format = M.space_format })
        space:create_index('primary', M.space_index_primary)
        space:create_index('expiration', M.space_index_expiration)
  return space
end

-- Get tuple from space
function M.get(space_name, key)
  return M.get_space(space_name).index.primary:get{key}
end

-- Insert data to space
function M.set(space_name, key, data, expires)
  local space = M.get_space(space_name)
  return space:replace{key, data, expires}
end

-- Fetch data from local space
function M._fetch_from_local(data)
  return M.get(data['space'], data['key'])
end

-- Fetch data from remote source
function M._fetch_from_remote(data)
  local client   = http.new()
  local headers  = M._parse_headers(data['headers'])
  local options  = { ['headers'] = headers }
  local body     = nil

  if data['method'] ~= 'GET' then
    body = json.encode(data['body'])
  end

  local response = client:request(data['method'], data['url'], body, options)
  return response.status, response.body
end

-- Public function to fetch data
function M.fetch(data)
  local record = M._fetch_from_local(data)
  if record ~= nil then
    return record['data']
  else
    local code, body = M._fetch_from_remote(data)
    if code == 200 then
      M.set(data['space'], data['key'], body, data['expires'])
      return { status = 'success', body = body }
    else
      return { status = 'failed', code = code }
    end
  end
end

-- Convert headers to http_client format
function M._parse_headers(data)
  local headers = {}
  for _,v in ipairs(data) do
    local tbl = string.split(v, ':')
    headers[tbl[1]] = tbl[2]
  end
  return headers
end

-- Get list of spaces
function M.get_spaces()
  local spaces = {}
  for _, space in box.space._space:pairs() do
    local space_name = space[3]
    if string.find(space_name, M.space_prefix) then
      table.insert(spaces, box.space[space_name])
    end
  end
  return spaces
end

-- Spaces cleaner
function M.cleaner()
  local spaces    = M.get_spaces()
  local timestamp = math.ceil(fiber.time())
  for _, space in pairs(spaces) do
    local expired  = space.index.expiration
    batches.atomic(100, expired:pairs(timestamp, { iterator = box.index.LE }),
      function(tuple)
        print(tuple[1], space.name)
        local tuple_key = tuple[1]
        space:delete{ tuple_key }
      end
    )
  end
end

-- Run cleaner on schedule
function M.start()
  fiber.create(function()
    while true do
      M.cleaner_process = fiber.create(M.cleaner)
      fiber.sleep(M.clearing_interval)
    end
  end)
  return M
end

return M