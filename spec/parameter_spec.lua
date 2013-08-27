local Parameter = require 'autoswagger.parameter'

describe('Parameter', function()

  it('can be created', function()
    local o = {}
    local p = Parameter.new(o, 'query', 'user_id')
    assert.equal(p.operation, o)
    assert.equal(p.kind, 'query')
    assert.equal(p.name, 'user_id')
  end)

  describe(':add_value', function()
    it('accepts values', function()
      local p = Parameter.new({}, 'query', 'user_id')
      p:add_value('peter')
      assert.same(p.values, {'peter'})
    end)
    it('discards older values if there are more than 3', function()
      local p = Parameter.new({}, 'query', 'user_id')
      p:add_value('peter')
      p:add_value('marcus')
      p:add_value('john')
      p:add_value('lucas')
      assert.same(p.values, {'marcus', 'john', 'lucas'})
    end)
  end)

end)
