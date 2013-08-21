local Derivator = require 'derivator'
local EOL = Derivator.EOL

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

    it('#hello handles a regression test that happened in the past', function()
      g = Derivator.new()

      g.root = {
        services = {
          ["*"]= {
            activate   = { [".xml"] = {[EOL]={}}},
            deactivate = { [".xml"] = {[EOL]={}}},
            suspend    = { [".xml"] = {[EOL]={}}},
          },
          foo6 = { ["*"] = {[".xml"] = {[EOL]={}}}},
          foo7 = { ["*"] = {[".xml"] = {[EOL]={}}}},
          foo8 = { ["*"] = {[".xml"] = {[EOL]={}}}},
          foo9 = { ["*"] = {[".xml"] = {[EOL]={}}}}
        }
      }

      assert.same(g:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/*/suspend.xml",
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml",
        "/services/foo9/*.xml"
      })

      g:remove("/services/*/activate.xml")

      assert.same(g:get_paths(), {
        "/services/*/deactivate.xml",
        "/services/*/suspend.xml",
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml",
        "/services/foo9/*.xml"
      })

    end)
  end)

  describe(':match', function()
    it('matchs paths', function()
      local g = create_derivator_1()
      local all_paths = g:get_paths()

      assert.same(all_paths, g:match("/*/*/activate.xml"))
      assert.same(all_paths, g:match("/*/*/*.xml"))

      assert.same({"/fulanitos/*/activate.xml"}, g:match("/fulanitos/whatever/activate.xml"))
      assert.same({"/*/foo/activate.xml"}, g:match("/whatever/foo/activate.xml"))
      assert.same({"/*/foo5/activate.xml"}, g:match("/whatever/foo5/activate.xml"))

      assert.same({}, g:match("/"))
      assert.same({}, g:match("/*/*/activate.xml.whatever"))
      assert.same({}, g:match("/whatever/foo_not_there/activate.xml"))
    end)
  end)

  describe(':learn', function()
    it('adds new paths only when they are really new', function()
      g = Derivator.new()

      g:learn("/users/foo/activate.xml")
      assert.same( {"/users/foo/activate.xml"}, g:get_paths())

      g:learn("/applications/foo/activate.xml")
      assert.same( {"/*/foo/activate.xml"}, g:get_paths())

      g:learn("/applications/foo2/activate.xml")
      g:learn("/applications/foo3/activate.xml")
      g:learn("/users/foo4/activate.xml")
      g:learn("/users/foo5/activate.xml")
      g:learn("/users/foo6/activate.xml")
      g:learn("/users/foo7/activate.xml")

      assert.same(g:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      g:learn("/users/foo/activate.xml")

      assert.same( g:get_paths(), {
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      g:learn("/applications/foo4/activate.xml")
      g:learn("/applications/foo5/activate.xml")

      g:learn("/services/bar5/activate.xml")

      g:learn("/fulanitos/bar5/activate.xml")
      g:learn("/fulanitos/bar6/activate.xml")
      g:learn("/fulanitos/bar7/activate.xml")
      g:learn("/fulanitos/bar8/activate.xml")

      g:learn("/services/foo6/activate.xml")
      g:learn("/services/foo7/activate.xml")
      g:learn("/services/foo8/activate.xml")

      g:learn("/applications/foo4/activate.xml")
      g:learn("/applications/foo5/activate.xml")

      g:learn("/services/bar5/activate.xml")
      g:learn("/fulanitos/bar5/activate.xml")

      g:learn("/fulanitos/bar6/activate.xml")
      g:learn("/fulanitos/bar7/activate.xml")
      g:learn("/fulanitos/bar8/activate.xml")

      g:learn("/services/bar6/activate.xml")
      g:learn("/services/bar7/activate.xml")
      g:learn("/services/bar8/activate.xml")


      assert.same( g:get_paths(), {
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.same( {"/services/*/activate.xml"}, g:match("/services/foo8/activate.xml"))
      assert.same( {"/services/*/activate.xml"}, g:match("/services/foo18/activate.xml"))
      assert.same( {}, g:match("/services/foo8/activate.json"))
      assert.same( {}, g:match("/ser/foo8/activate.xml"))
    end)

    it('can handle edge cases', function()
      g = Derivator.new()

      g:learn("/services/foo6/activate.xml")
      g:learn("/services/foo7/activate.xml")
      g:learn("/services/foo8/activate.xml")

      assert.same( {"/services/*/activate.xml"}, g:get_paths())

      g:learn("/services/foo6/deactivate.xml")
      g:learn("/services/foo7/deactivate.xml")
      g:learn("/services/foo8/deactivate.xml")

      assert.same( g:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })

      g:learn("/services/foo/60.xml")
      g:learn("/services/foo/61.xml")
      g:learn("/services/foo/62.xml")

      assert.same( g:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/foo/*.xml"
      })

    end)

    it('understands threshold', function()

      local g = Derivator.new() -- default: threshold = 1

      g:learn("/services/foo6/activate.xml")
      g:learn("/services/foo6/deactivate.xml")
      g:learn("/services/foo7/activate.xml")
      g:learn("/services/foo7/deactivate.xml")
      g:learn("/services/foo8/activate.xml")
      g:learn("/services/foo8/deactivate.xml")

      assert.same( g:get_paths(), {
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml"
      })

      -- never merge
      g = Derivator.new(0.0)

      g:learn("/services/foo6/activate.xml")
      g:learn("/services/foo6/deactivate.xml")
      g:learn("/services/foo7/activate.xml")
      g:learn("/services/foo7/deactivate.xml")
      g:learn("/services/foo8/activate.xml")
      g:learn("/services/foo8/deactivate.xml")

      assert.same( g:get_paths(), {
        "/services/foo6/activate.xml",
        "/services/foo6/deactivate.xml",
        "/services/foo7/activate.xml",
        "/services/foo7/deactivate.xml",
        "/services/foo8/activate.xml",
        "/services/foo8/deactivate.xml"
      })

      g = Derivator.new(0.2)
      -- fake the histogram so that the words that are not var are seen more often
      -- the threshold 0.2 means that only merge if word is 5 (=1/0.2) times less frequent
      -- than the most common word
      g.histogram = {
        services = 20, activate = 10, deactivate = 10,
        foo6 = 1, foo7 = 1, foo8 = 1
      }

      g:learn("/services/foo6/activate.xml")
      g:learn("/services/foo6/deactivate.xml")
      g:learn("/services/foo7/activate.xml")
      g:learn("/services/foo7/deactivate.xml")
      g:learn("/services/foo8/activate.xml")
      g:learn("/services/foo8/deactivate.xml")

      assert.same( g:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })
    end)

  end)

  it('understands unmergeable tokens', function()
    -- without unmergeable tokens
    local g = Derivator.new()

    g:add("/services/foo6/activate.xml")
    g:add("/services/foo6/deactivate.xml")

    assert.same( g:get_paths(), { "/services/foo6/*.xml" })

    g:add("/services/foo7/activate.xml")
    g:add("/services/foo7/deactivate.xml")

    g:add("/services/foo8/activate.xml")
    g:add("/services/foo8/deactivate.xml")

    assert.same( g:get_paths(), {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml"
    })

    -- with unmergeable tokens
    g = Derivator.new(1.0, {"activate", "deactivate"})

    g:add("/services/foo6/activate.xml")
    g:add("/services/foo6/deactivate.xml")

    assert.same( g:get_paths(), {
      "/services/foo6/activate.xml",
      "/services/foo6/deactivate.xml"
    })

    g:add("/services/foo7/activate.xml")
    g:add("/services/foo7/deactivate.xml")

    g:add("/services/foo8/activate.xml")
    g:add("/services/foo8/deactivate.xml")

    assert.same( g:get_paths(), {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml"
    })

  end)

end)
