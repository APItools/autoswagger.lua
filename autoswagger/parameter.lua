local PATH = (...):match("(.+%.)[^%.]+$") or ""

local array     = require(PATH .. 'array')

local MAX_VALUES_STORED = 3

local function to_s(value, appearances)
  if type(value) == 'string' then return "'" .. tostring(value) .. "'" end
  if type(value) ~= 'table' then return tostring(value) end

  appearances = appearances or {}
  if appearances[value] then return "{...}" end
  appearances[value] = true

  local items = {}
  for k,v in pairs(value) do
    array.append(items, {'[', to_s(k, appearances), '] = ', to_s(v, appearances)})
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
    values = {}
  }, Parametermt)
end

function Parameter:add_value(value)
  value = to_s(value)
  if not array.includes(self.values, value) then
    self.values[#self.values + 1] = value
    if #self.values > MAX_VALUES_STORED then
      table.remove(self.values, 1)
    end
  end
end

function Parameter:get_description()
  if #self.values == 0 then return "No available value suggestions" end
  local values_str = table.concat(self.values, ", ")
  return "Possible values are: " .. values_str
end

function Parameter:is_required()
  return self.kind == 'path'
end

function Parameter:to_swagger()
  return {
    paramType   = self.kind,
    name        = self.name,
    description = self:get_description(),
    required    = self:is_required(),
    ['type']    = 'string'
  }
end



return Parameter
