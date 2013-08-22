local Host = require 'host'

describe('Host', function()
  describe('.new', function()
    it("expects a hostname, and a pathfinder", function()
      local pf = {}
      local host = Host.new('google.com', pf)
      assert.equal(host.hostname, 'google.com')
      assert.equal(host.path_finder, pf)
      assert.same(host.apis, {})
    end)
  end)

end)



