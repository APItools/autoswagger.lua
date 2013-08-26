local PATH = (...):match("(.+%.)[^%.]+$") or ""

local straux  = require(PATH .. 'straux')
local base    = require(PATH .. 'base')

local EOL      = base.EOL
local WILDCARD = base.WILDCARD

local Endpoint = {}

function Endpoint.new(endpoint)
  return setmetatable({
    endpoint = endpoint,
    tokens = straux.tokenize(endpoint)
  }, {
    __index = Endpoint
  })
end

function Endpoint:parse_path_params(path)
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

function Endpoint:add_parameter_info(path, query, body, headers)
end

return Endpoint
