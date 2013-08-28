
local MAX_VALUES_STORED = 3

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
  self.values[#self.values + 1] = value
  if #self.values > MAX_VALUES_STORED then
    table.remove(self.values, 1)
  end
end

function Parameter:get_description()
  return self.name
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
