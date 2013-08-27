local Operation = require 'autoswagger.operation'

describe('Operation', function()
  it('can be created', function()
    local api = {}
    local o = Operation.new(api, 'GET')
    assert.equals(o.method, 'GET')
    assert.equals(o.api, api)
  end)
end)
