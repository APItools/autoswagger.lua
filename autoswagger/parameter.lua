local Param = {}

local MAX_VALUES_STORED = 3

function Param.new(kind, name)
  return setmetatable({
    kind = kind,
    name = name,
    values = {}
  }, {
    __index = Param
  })
end

function Param:add_value(value)
  self.values[#self.values + 1] = value
  if #self.values > MAX_VALUES_STORED then
    table.remove(self.values, 1)
  end
end



return Param
