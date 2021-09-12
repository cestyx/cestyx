require('strict').on()

local config = require('config')
box.cfg(config.tarantool.node)

local json        = require('json')
local http_router = require('http.router')
local http_server = require('http.server')
local tsgi        = require('http.tsgi')
local cestyx      = require('lib.cestyx')

-- Push response to client
local function send_response(code, payload)
  if not type(payload) == 'table' then
    return { status = code, body = json.encode({ message = tostring(payload) }) }
  else
    return { status = code, body = json.encode(payload) }
  end
end

-- Forward request to handle accordingly to table 'routes'
local function forward_request(controller, request)
  local success, result = pcall(cestyx[controller], request)
  if not success then
    return send_response(500, result)
  else
    return send_response(200, result)
  end
end

-- Authenticate request before process
local function auth_request(env)
  local request_token = env:header('x-auth-token')
  if not request_token == config.http.token then
    return send_response(403, 'Failed to authenticate request')
  else
    return tsgi.next(env)
  end
end

-- List of supported routes
local routes = {
  { method = 'POST', path = '/_proxy', controller = 'process_request' }
}

local router = http_router.new()
local auth_opts = {
  preroute = true,  name = 'auth',
  method   = 'GET', path = '/api/.*'
}
router:use(auth_request, auth_opts)

local server_opts = {
  log_requests = config.http.log_requests,
  log_errors   = config.http.log_errors
}
local server = http_server.new(config.http.host, config.http.port, server_opts)

for _, r in ipairs(routes) do
  router:route({ method = r.method, path = config.http.root .. r.path }, function(request)
    return forward_request(r.controller, request)
  end)
end

server:set_router(router)
server:start()