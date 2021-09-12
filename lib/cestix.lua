-- local digest = require('digest')

local M = {}

M.config = require('config')
M.space_prefix = M.config.cestix.space_prefix

M.space_format = {
  { name = 'crc',     type = 'number' },
  { name = 'key',     type = 'number' },
  { name = 'expires', type = 'number' },
  { name = 'url',     type = 'string' },
  { name = 'data',    type = 'string', is_nullable = true },
}

M.space_index_primary = {
  'primary', {
    unique = true,
    type   = 'HASH',
    parts  = {
      { field = 2, type = 'number' },
      { field = 3, type = 'number' },
    }
  }
}

function M.process_request()
end

function M.space(name)
  local space_name = M.space_prefix .. '_' .. name
  if box.space[space_name] ~= nil then
    return box.space[space_name]
  else
    return M.create_space(name)
  end
end

function M.create_space(name)
  local space_name = M.space_prefix .. '_' .. name
  local space = box.schema.space.create(space_name, { engine = 'memtx', format = M.space_format })
        space:create_index(M.space_index_primary)
  return space
end

function M.spaces()
  -- local spaces = box.spaces
end