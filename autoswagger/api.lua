local PATH = (...):match("(.+%.)[^%.]+$") or ""

local straux     = require(PATH .. 'lib.straux')
local array      = require(PATH .. 'lib.array')
local md5        = require(PATH .. 'lib.md5')
local Operation  = require(PATH .. 'operation')

local WILDCARD = straux.WILDCARD

local API = {}
local APImt = {__index = API}

-- transforms /foo/{user_id}.xml into /foo/*.xml
local function parse_swagger_path(swagger_path)
  return swagger_path:gsub('{[^{}]+}', '*')
end

function API:new(host, path)
  return setmetatable({
    host = host,
    path = path,
    tokens = straux.tokenize(path),
    operations = {},
    guid = md5.sumhexa(host.base_path .. path)
  }, APImt)
end

function API:add_operation_info(method, path, query, body, headers)
  method   = string.upper(method)

  self.operations[method] = self.operations[method] or Operation:new(self, method)
self.operations[method]:add_parameter_info(path, query, body, headers)
end

function API:get_methods()
  local methods = {}
  for method,_ in pairs(self.operations) do
    methods[#methods + 1] = method
  end
  return array.sort(methods)
end

function API:get_swagger_path()
  local tokens = self.tokens
  local buffer = {}

  for i=1,#tokens do
    local token = tokens[i]
    if token == WILDCARD then
      local id = straux.make_id(i > 1 and tokens[i-1] or 'param')
      buffer[i] = '{'.. id .. '}'
    else
      buffer[i] = token
    end
  end

  return array.untokenize(buffer)
end

function API:to_swagger()
  local operations = {}
  for _,method in ipairs(self:get_methods()) do
    operations[#operations + 1] = self.operations[method]:to_swagger()
  end

  return {
    path        = self:get_swagger_path(),
    guid        = self.guid,
    description = "Automatically generated API spec",
    operations  = operations
  }
end

function API:new_from_swagger(host, swagger)
  if type(swagger) ~= 'table' or type(swagger.path) ~= 'string' then
    error('the swagger parameter must be a table containig at least a path')
  end

  local api = API:new(host, parse_swagger_path(swagger.path))

  if type(swagger.operations) == 'table' then
    for _,operation_swagger in ipairs(swagger.operations) do
      local operation = Operation:new_from_swagger(api, operation_swagger)
      api.operations[operation.method] = operation
    end
  end

  return api
end

return API
