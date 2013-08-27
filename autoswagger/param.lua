local Param = {}

local MAX_VALUES_STORED = 3

function Param.new(kind, name)
  return setmetatable({
    kind = kind,
    name = name,
    last_values = {}
  }, {
    __index = Param
  })
end

function Param:add_value(value)
  self.last_values[#self.last_values + 1] = value
  if #self.last_values > MAX_VALUES_STORED then
    table.remove(self.last_values, 1)
  end
end



return Param
