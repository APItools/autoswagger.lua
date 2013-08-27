local PATH = (...):match("(.+%.)[^%.]+$") or ""

local straux     = require(PATH .. 'straux')
local Operation  = require(PATH .. 'operation')

local API = {}

function API.new(host, path)
  return setmetatable({
    host = host,
    path = path,
    tokens = straux.tokenize(path),
    operations = {}
  }, {
    __index = API
  })
end

function API:add_operation_info(method, path, query, body, headers)
  method   = string.upper(method)

  self.operations[method] = self.operations[method] or Operation.new(self, method)
  self.operations[method]:add_parameter_info(path, query, body, headers)
end

return API
