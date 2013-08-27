local Operation = require 'autoswagger.operation'

describe('Operation', function()
  it('can be created', function()
    local o = Operation.new('GET')
    assert.equals(o.method, 'GET')
  end)
end)
