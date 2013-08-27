local PATH = (...):match("(.+%.)[^%.]+$") or ""

local Parameter   = require(PATH .. 'parameter')


local Operation = {}

local function add_parameters(self, param_kind, params)
  for name, value in pairs(params) do
    self:add_parameter(param_kind, name, value)
  end
end

local function count_table_elements(t)
  local count = 0
  for _,_ in pairs(t) do count = count + 1 end
  return count
end

local function get_body_params_kind(body_params)
  if body_params.__body and count_table_elements(body_params) == 1 then
    return 'body'
  end
  return 'query'
end

function Operation.new(api, method)
  return setmetatable({
    api    = api,
    method = method,
    parameters = {}
  }, {
    __index = Operation
  })
end

function Operation:add_parameters(path_params, query_params, body_params, headers)
  add_parameters(self, 'header', headers)
  add_parameters(self, 'path',   path_params)
  add_parameters(self, 'query',  query_params)
  add_parameters(self, get_body_params_kind(body_params), body_params)
end

function Operation:add_parameter(kind, name, value)
  self.parameters[name] = self.parameters[name] or Parameter.new(kind, name)
  local p = self.parameters[name]

  p.kind = kind
  p:add_value(value)
end

return Operation
