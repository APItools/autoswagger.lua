local PATH = (...):match("(.+%.)[^%.]+$") or ""

local straux     = require(PATH .. 'straux')
local array      = require(PATH .. 'array')
local base       = require(PATH .. 'base')
local Operation  = require(PATH .. 'operation')

local EOL      = base.EOL
local WILDCARD = base.WILDCARD

local API = {}

local function parse_body_params(body, headers)
  if type(headers) == 'table' and headers['Content-Type'] == "application/x-www-form-urlencoded" then
    if type(body) == 'table' then return body end
    return straux.parse_query(body)
  else
    return {__body = body}
  end
end

local function parse_query_params(query)
  if type(query) == 'table' then return query end
  return straux.parse_query(query)
end

function API.new(path)
  return setmetatable({
    path = path,
    tokens = straux.tokenize(path),
    operations = {}
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


function API:add_operation_info(method, path, query, body, headers)
  method   = string.upper(method)
  query    = query or ""
  body     = body or ""
  headers  = headers or {}

  local path_params  = self:parse_path_params(path)
  local query_params = parse_query_params(query)
  local body_params  = parse_body_params(body, headers)

  self.operations[method] = self.operations[method] or Operation.new(method)
  self.operations[method]:add_parameters(path_params, query_params, body_params, headers)
end

return API
