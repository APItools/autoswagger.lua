local PATH = (...):match("(.+%.)[^%.]+$") or ""

local Parameter   = require(PATH .. 'parameter')
local straux      = require(PATH .. 'straux')
local array       = require(PATH .. 'array')
local base        = require(PATH .. 'base')

local WILDCARD = base.WILDCARD

local Operation = {}

function Operation:new(api, method)
  return setmetatable({
    api    = api,
    method = method,
    parameters = {}
  }, {
    __index = Operation
  })
end

function Operation:parse_path_parameters(path)
  local tokens = straux.tokenize(path)

  local result = {}

  for i=1, #self.api.tokens do
    local my_token = self.api.tokens[i]
    if my_token == WILDCARD then
      local param_name   = straux.make_id(i > 1 and tokens[i-1] or "param")
      result[param_name] = tokens[i]
    end
  end

  return result
end

function Operation:parse_body_parameters(body, headers)
  if type(headers) == 'table' and headers['Content-Type'] == "application/x-www-form-urlencoded" then
    if type(body) == 'table' then return 'body', body end
    return 'body', straux.parse_query(body)
  else
    return 'query', {__body = body}
  end
end

function Operation:parse_query_parameters(query)
  if type(query) == 'table' then return query end
  return straux.parse_query(query)
end

function Operation:add_parameter_info(path, query, body, headers)
  query    = query or ""
  body     = body or ""
  headers  = headers or {}

  self:add_parameters('header',  headers)
  self:add_parameters('path',  self:parse_path_parameters(path))
  self:add_parameters('query', self:parse_query_parameters(query))

  if self.method ~= 'GET' and self.method ~= 'HEAD' then
    local body_kind, body_parameters  = self:parse_body_parameters(body, headers)
    self:add_parameters(body_kind, body_parameters)
  end
end

function Operation:add_parameters(kind, parameters)
  for name, value in pairs(parameters) do
    self:add_parameter(kind, name, value)
  end
end

function Operation:add_parameter(kind, name, value)
  self.parameters[name] = self.parameters[name] or Parameter:new(self, kind, name)
  local p = self.parameters[name]

  p.kind = kind
  p:add_value(value)
end

function Operation:get_parameter_names()
  local names = {}
  for name,_ in pairs(self.parameters) do
    names[#names + 1] = name
  end
  return array.sort(names)
end

function Operation:get_nickname()
  return 'unavailable'
end

function Operation:get_summary()
  return 'unavailable'
end

function Operation:to_swagger()
  local parameters = {}

  for _,name in ipairs(self:get_parameter_names()) do
    parameters[#parameters + 1] = self.parameters[name]:to_swagger()
  end

  return {
    method      = self.method,
    nickname    = self:get_nickname(),
    summary     = self:get_summary(),
    notes       = 'Automatically generated Operation spec',
    parameters  = parameters
  }
end

return Operation
