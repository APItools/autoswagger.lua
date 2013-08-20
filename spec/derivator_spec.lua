local Derivator = require 'derivator'

describe('Derivator', function()
  describe(':add', function()
    it('builds the expected paths', function()
      local g = Derivator.new()

      g:add("/users/foo/activate.xml")
      g:add("/applications/foo/activate.xml")

      g:add("/applications/foo2/activate.xml")
      g:add("/applications/foo3/activate.xml")

      g:add("/users/foo4/activate.xml")
      g:add("/users/foo5/activate.xml")

      g:add("/applications/foo4/activate.xml")
      g:add("/applications/foo5/activate.xml")

      g:add("/services/foo5/activate.xml")
      g:add("/fulanitos/foo5/activate.xml")

      g:add("/fulanitos/foo6/activate.xml")
      g:add("/fulanitos/foo7/activate.xml")
      g:add("/fulanitos/foo8/activate.xml")

      g:add("/services/foo6/activate.xml")
      g:add("/services/foo7/activate.xml")
      g:add("/services/foo8/activate.xml")

      local v = g:get_paths()

      assert.same(v, {
        "/*/foo/activate.xml",
        "/*/foo5/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      --[[
      assert_equal ["/fulanitos/#{Derivator::WILDCARD}/activate.xml"], g.find("/fulanitos/whatever/activate.xml")
      assert_equal g.paths.sort, g.find("/#{Derivator::WILDCARD}/#{Derivator::WILDCARD}/activate.xml").sort
      assert_equal g.paths.sort, g.find("/#{Derivator::WILDCARD}/#{Derivator::WILDCARD}/#{Derivator::WILDCARD}.xml").sort
      assert_equal [], g.find("/")
      assert_equal [], g.find("/#{Derivator::WILDCARD}/#{Derivator::WILDCARD}/activate.xml.whatever")
      assert_equal ["/#{Derivator::WILDCARD}/foo/activate.xml"], g.find("/whatever/foo/activate.xml")
      assert_equal ["/#{Derivator::WILDCARD}/foo5/activate.xml"], g.find("/whatever/foo5/activate.xml")
      assert_equal [], g.find("/whatever/foo_not_there/activate.xml")
      ]]
    end)
  end)
end)
