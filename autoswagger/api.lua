local PATH = (...):match("(.+%.)[^%.]+$") or ""

local straux  = require(PATH .. 'straux')
local array   = require(PATH .. 'array')
local base    = require(PATH .. 'base')
local Param   = require(PATH .. 'param')

local EOL      = base.EOL
local WILDCARD = base.WILDCARD

local API = {}

function API.new(path)
  return setmetatable({
    path = path,
    tokens = straux.tokenize(path),
    methods = {}
  }, {
    __index = API
  })
end

function API:parse_path_params(path)
  local tokens = straux.tokenize(path)

  local result = {}

  for i=0, #self.tokens do
    local my_token = self.tokens[i]
    if my_token == WILDCARD then
      local param_name   = straux.make_id(i > 1 and tokens[i-1] or "param")
      result[param_name] = tokens[i]
    end
  end

  return result
end

function API:add_method(method)
  method = string.upper(method)
  if not array.includes(self.methods, method) then
    self.methods[#self.methods + 1] = method
    table.sort(self.methods)
  end
end

function API:add_parameter_info(path, query, body, headers)
  local pa
end

return API
