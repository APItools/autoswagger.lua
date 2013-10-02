local PATH = (...):match("(.+%.)[^%.]+$") or ""

local array     = require(PATH .. 'lib.array')
local md5       = require(PATH .. 'lib.md5')

local MAX_VALUES_STORED = 3

local function to_s(value, appearances)
  if type(value) == 'string' then return "'" .. value .. "'" end
  if type(value) ~= 'table' then return tostring(value) end

  appearances = appearances or {}
  if appearances[value] then return "{...}" end
  appearances[value] = true

  local keys, len = {}, 0
  for k,_ in pairs(value) do
    len = len + 1
    keys[len] = k
  end
  table.sort(keys, function(a,b) return to_s(a) < to_s(b) end)

  local items = {}
  for i=1, len do
    local k = keys[i]
    local v = value[k]
    items[i] = '[' .. to_s(k, appearances) .. '] = ' .. to_s(v, appearances)
  end

  return '{' .. table.concat(items, ', ') .. '}'
end

local Parameter = {}
local Parametermt = {__index = Parameter}

function Parameter:new(operation, kind, name)
  return setmetatable({
    operation = operation,
    kind = kind,
    name = name,
    values = {},
    string_values = {}
  }, Parametermt)
end

function Parameter:add_value(value)
  local string_value = to_s(value)
  if not array.includes(self.string_values, string_value) then
    local len = #self.values
    self.values[len + 1]        = value
    self.string_values[len + 1] = string_value
    if len == MAX_VALUES_STORED then
      table.remove(self.values, 1)
      table.remove(self.string_values, 1)
    end
  end
end

function Parameter:get_description()
  if #self.values == 0 then return "No available value suggestions" end
  return "Possible values are: " .. table.concat(self.string_values, ", ")
end

function Parameter:is_required()
  return self.kind == 'path'
end

function Parameter:to_swagger()
  return {
    paramType   = self.kind,
    name        = self.name,
    description = self:get_description(),
    possible_values = self.values,
    required    = self:is_required(),
    ['type']    = 'string'
  }
end

function Parameter:new_from_swagger(operation, swagger)
  if type(swagger) ~= 'table'
  or type(swagger.paramType) ~= 'string'
  or type(swagger.name) ~= 'string' then
    error('swagger must exist and have proper paramType and name attributes')
  end

  local parameter = Parameter:new(operation, swagger.paramType, swagger.name)

  if swagger.possible_values then
    for _,v in ipairs(swagger.possible_values) do
      parameter:add_value(v)
    end
  end

  return parameter
end








return Parameter
