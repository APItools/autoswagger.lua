local PATH = (...):match("(.+%.)[^%.]+$") or ""

local array     = require(PATH .. 'lib.array')
local md5       = require(PATH .. 'lib.md5')

local MAX_VALUES_STORED = 3

local function to_s(value, appearances)
  if type(value) == 'string' then return "'" .. tostring(value) .. "'" end
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
