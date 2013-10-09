local Parameter = require 'autoswagger.parameter'

describe('Parameter', function()

  it('can be created', function()
    local o = {}
    local p = Parameter:new(o, 'query', 'user_id')
    assert.equal(p.operation, o)
    assert.equal(p.paramType, 'query')
    assert.equal(p.name, 'user_id')
  end)

  describe(':add_value', function()
    it('accepts values', function()
      local p = Parameter:new({}, 'query', 'user_id')
      p:add_value('peter')
      assert.same(p.values, {'peter'})
    end)
    it('discards older values if there are more than 3', function()
      local p = Parameter:new({}, 'query', 'user_id')
      p:add_value('peter')
      p:add_value('marcus')
      p:add_value('john')
      p:add_value('lucas')
      assert.same(p.values, {'marcus', 'john', 'lucas'})
    end)
    it('converts tables to strings', function()
      local p = Parameter:new({}, 'query', 'body')
      p:add_value({1,2,3, a=4})
      assert.same(p.string_values, {"{['a'] = 4, [1] = 1, [2] = 2, [3] = 3}"})
    end)
  end)

  describe(':to_swagger', function()
    it('returns the swagger of 1 parameter', function()
      local p = Parameter:new({}, 'query', 'user_id')
      p:add_value('1')
      p:add_value('2')
      p:add_value('3')
      assert.same(p:to_swagger(), {
        name = 'user_id',
        paramType = 'query',
        description = "Possible values are: '1', '2', '3'" ,
        ['type'] = 'string',
        required = false
      })

    end)
  end)

  describe(':serialize', function()
    it('returns the a table that allows building a param', function()
      local p = Parameter:new({}, 'query', 'user_id')
      p:add_value(1)
      p:add_value(2)
      p:add_value(3)
      assert.same(p:serialize(), {
        name      = 'user_id',
        paramType = 'query',
        values    = {1, 2, 3}
      })

    end)
  end)

  describe(':deserialize', function()
    it('transforms a table into a param', function()
      local swagger = {
        name = 'user_id',
        paramType = 'query',
        values   = {1,2,3},
      }

      local p = Parameter:deserialize({}, swagger)

      assert.equal(p.name, 'user_id')
      assert.equal(p.paramType, 'query')
      assert.same(p.values, {1, 2, 3})
    end)
  end)

end)
