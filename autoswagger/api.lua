local PATH = (...):match("(.+%.)[^%.]+$") or ""

  local straux     = require(PATH .. 'straux')
  local base       = require(PATH .. 'base')
  local array      = require(PATH .. 'array')
  local Operation  = require(PATH .. 'operation')

  local WILDCARD = base.WILDCARD

  local API = {}
  local APImt = {__index = API}

  function API:new(host, path)
    return setmetatable({
      host = host,
      path = path,
      tokens = straux.tokenize(path),
      operations = {}
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
    description = "Automatically generated API spec",
    operations  = operations
  }
end

return API
