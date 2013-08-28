local Brain = require('autoswagger.brain')
local Host  = require('autoswagger.host')

describe('Brain', function()

  describe(':new', function()
    it('accepts values', function()
      local b = Brain:new(0.5, {'foo'})
      assert.equal(b.threshold, 0.5)
      assert.same(b.unmergeable_tokens, {'foo'})
    end)

    it('has default values', function()
      local b = Brain:new()
      assert.equal(b.threshold, 1.0)
      assert.same(b.unmergeable_tokens, {})
    end)
  end)

  describe(':learn', function()

    it('creates a host when needed', function()
      local b = Brain:new()
      b:learn('GET', 'google.com', '/foo/bar')
      b:learn('GET', 'facebook.com', '/foo/bar')
      assert.same(b:get_hostnames(), {'facebook.com', 'google.com'})
    end)

  end)

end)
