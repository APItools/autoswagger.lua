local Derivator = require 'derivator'

local function create_derivator_1()
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

  return g
end

describe('Derivator', function()
  describe(':add', function()
    it('builds the expected paths', function()

      local g = create_derivator_1()
      local v = g:get_paths()

      assert.same(v, {
        "/*/foo/activate.xml",
        "/*/foo5/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })
    end)
  end)

  describe(':remove', function()
    it('removes the given path rules', function()

      local g = create_derivator_1()

      assert.truthy(g:remove("/*/foo5/activate.xml"))

      assert.same(g:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.truthy(g:remove("/services/*/activate.xml"))

      assert.same(g:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/users/*/activate.xml"
      })

      -- remove only works for exact paths, not for matches
      assert.equals(false, g:remove("/*/*/activate.xml"))
    end)
  end)

  describe(':find', function()
    it('finds paths', function()
      local g = create_derivator_1()
      local all_paths = g:get_paths()

      assert.same(all_paths, g:find("/*/*/activate.xml"))
      assert.same(all_paths, g:find("/*/*/*.xml"))

      assert.same({"/fulanitos/*/activate.xml"}, g:find("/fulanitos/whatever/activate.xml"))
      assert.same({"/*/foo/activate.xml"}, g:find("/whatever/foo/activate.xml"))
      assert.same({"/*/foo5/activate.xml"}, g:find("/whatever/foo5/activate.xml"))

      assert.same({}, g:find("/"))
      assert.same({}, g:find("/*/*/activate.xml.whatever"))
      assert.same({}, g:find("/whatever/foo_not_there/activate.xml"))
    end)
  end)

  describe(':learn', function()
    it('adds new paths only when they are really new', function()
    end)
  end)

end)
