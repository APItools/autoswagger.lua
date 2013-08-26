local as = require('autoswagger')
local Host = as.Host
local EOL  = as.EOL

local function create_host()
  local h = Host.new('google.com')

  h:learn("/users/foo/activate.xml")
  h:learn("/applications/foo/activate.xml")

  h:learn("/applications/foo2/activate.xml")
  h:learn("/applications/foo3/activate.xml")

  h:learn("/users/foo4/activate.xml")
  h:learn("/users/foo5/activate.xml")

  h:learn("/applications/foo4/activate.xml")
  h:learn("/applications/foo5/activate.xml")

  h:learn("/services/foo5/activate.xml")
  h:learn("/fulanitos/foo5/activate.xml")

  h:learn("/fulanitos/foo6/activate.xml")
  h:learn("/fulanitos/foo7/activate.xml")
  h:learn("/fulanitos/foo8/activate.xml")

  h:learn("/services/foo6/activate.xml")
  h:learn("/services/foo7/activate.xml")
  h:learn("/services/foo8/activate.xml")

  return h
end

describe('Host', function()

  describe(':match', function()
    it('returns a list of the paths that match a given path. The list can be empty', function()
      local h = create_host()
      local all_paths = h:get_paths()

      assert.same(all_paths, h:match("/*/*/activate.xml"))
      assert.same(all_paths, h:match("/*/*/*.xml"))

      assert.same({"/fulanitos/*/activate.xml"}, h:match("/fulanitos/whatever/activate.xml"))
      assert.same({"/*/foo/activate.xml"}, h:match("/whatever/foo/activate.xml"))
      assert.same({"/*/foo5/activate.xml"}, h:match("/whatever/foo5/activate.xml"))

      assert.same({}, h:match("/"))
      assert.same({}, h:match("/*/*/activate.xml.whatever"))
      assert.same({}, h:match("/whatever/foo_not_there/activate.xml"))
    end)
  end)

  describe(':learn', function()

    it('builds the expected paths', function()

      local h = create_host()
      local v = h:get_paths()

      assert.same(v, {
        "/*/foo/activate.xml",
        "/*/foo5/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })
    end)

    it('adds new paths only when they are really new', function()
      local h = Host.new()

      h:learn("/users/foo/activate.xml")
      assert.same( {"/users/foo/activate.xml"}, h:get_paths())

      h:learn("/applications/foo/activate.xml")
      assert.same( {"/*/foo/activate.xml"}, h:get_paths())

      h:learn("/applications/foo2/activate.xml")
      h:learn("/applications/foo3/activate.xml")
      h:learn("/users/foo4/activate.xml")
      h:learn("/users/foo5/activate.xml")
      h:learn("/users/foo6/activate.xml")
      h:learn("/users/foo7/activate.xml")

      assert.same(h:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      h:learn("/users/foo/activate.xml")

      assert.same( h:get_paths(), {
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      h:learn("/applications/foo4/activate.xml")
      h:learn("/applications/foo5/activate.xml")

      h:learn("/services/bar5/activate.xml")

      h:learn("/fulanitos/bar5/activate.xml")
      h:learn("/fulanitos/bar6/activate.xml")
      h:learn("/fulanitos/bar7/activate.xml")
      h:learn("/fulanitos/bar8/activate.xml")

      h:learn("/services/foo6/activate.xml")
      h:learn("/services/foo7/activate.xml")
      h:learn("/services/foo8/activate.xml")

      h:learn("/applications/foo4/activate.xml")
      h:learn("/applications/foo5/activate.xml")

      h:learn("/services/bar5/activate.xml")
      h:learn("/fulanitos/bar5/activate.xml")

      h:learn("/fulanitos/bar6/activate.xml")
      h:learn("/fulanitos/bar7/activate.xml")
      h:learn("/fulanitos/bar8/activate.xml")

      h:learn("/services/bar6/activate.xml")
      h:learn("/services/bar7/activate.xml")
      h:learn("/services/bar8/activate.xml")


      assert.same( h:get_paths(), {
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.same( {"/services/*/activate.xml"}, h:match("/services/foo8/activate.xml"))
      assert.same( {"/services/*/activate.xml"}, h:match("/services/foo18/activate.xml"))
      assert.same( {}, h:match("/services/foo8/activate.json"))
      assert.same( {}, h:match("/ser/foo8/activate.xml"))
    end)

    it('can handle edge cases', function()
      local h = Host.new()

      h:learn("/services/foo6/activate.xml")
      h:learn("/services/foo7/activate.xml")
      h:learn("/services/foo8/activate.xml")

      assert.same( {"/services/*/activate.xml"}, h:get_paths())

      h:learn("/services/foo6/deactivate.xml")
      h:learn("/services/foo7/deactivate.xml")
      h:learn("/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })

      h:learn("/services/foo/60.xml")
      h:learn("/services/foo/61.xml")
      h:learn("/services/foo/62.xml")

      assert.same( h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/foo/*.xml"
      })

    end)

    it('understands threshold', function()

      local h = Host.new('google.com') -- default: threshold = 1

      h:learn("/services/foo6/activate.xml")
      h:learn("/services/foo6/deactivate.xml")
      h:learn("/services/foo7/activate.xml")
      h:learn("/services/foo7/deactivate.xml")
      h:learn("/services/foo8/activate.xml")
      h:learn("/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml"
      })

      -- never merge
      h = Host.new('google.com', 0.0)

      h:learn("/services/foo6/activate.xml")
      h:learn("/services/foo6/deactivate.xml")
      h:learn("/services/foo7/activate.xml")
      h:learn("/services/foo7/deactivate.xml")
      h:learn("/services/foo8/activate.xml")
      h:learn("/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/foo6/activate.xml",
        "/services/foo6/deactivate.xml",
        "/services/foo7/activate.xml",
        "/services/foo7/deactivate.xml",
        "/services/foo8/activate.xml",
        "/services/foo8/deactivate.xml"
      })

      h = Host.new('google.com', 0.2)
      -- fake the score so that the words that are not var are seen more often
      -- the threshold 0.2 means that only merge if word is 5 (=1/0.2) times less frequent
      -- than the most common word
      h.score = {
        services = 20, activate = 10, deactivate = 10,
        foo6 = 1, foo7 = 1, foo8 = 1
      }

      h:learn("/services/foo6/activate.xml")
      h:learn("/services/foo6/deactivate.xml")
      h:learn("/services/foo7/activate.xml")
      h:learn("/services/foo7/deactivate.xml")
      h:learn("/services/foo8/activate.xml")
      h:learn("/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })
    end)

  end)

  it('understands unmergeable tokens', function()
    -- without unmergeable tokens
    local h = Host.new('google.com')

    h:learn("/services/foo6/activate.xml")
    h:learn("/services/foo6/deactivate.xml")

    assert.same( h:get_paths(), { "/services/foo6/*.xml" })

    h:learn("/services/foo7/activate.xml")
    h:learn("/services/foo7/deactivate.xml")

    h:learn("/services/foo8/activate.xml")
    h:learn("/services/foo8/deactivate.xml")

    assert.same( h:get_paths(), {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml"
    })

    -- with unmergeable tokens
    h = Host.new('google.com', 1.0, {"activate", "deactivate"})

    h:learn("/services/foo6/activate.xml")
    h:learn("/services/foo6/deactivate.xml")

    assert.same( h:get_paths(), {
      "/services/foo6/activate.xml",
      "/services/foo6/deactivate.xml"
    })

    h:learn("/services/foo7/activate.xml")
    h:learn("/services/foo7/deactivate.xml")

    h:learn("/services/foo8/activate.xml")
    h:learn("/services/foo8/deactivate.xml")

    assert.same( h:get_paths(), {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml"
    })

  end)

  it('unifies paths', function()
    local h = Host.new('google.com')

    h:learn("/services/foo6/activate.xml")
    h:learn("/services/foo6/deactivate.xml")

    assert.same( {"/services/foo6/*.xml"}, h:get_paths())

    h:learn("/services/foo6/activate.xml")
    h:learn("/services/foo6/deactivate.xml")

    h:learn("/services/foo7/activate.xml")
    h:learn("/services/foo7/deactivate.xml")

    h:learn("/services/foo8/activate.xml")
    h:learn("/services/foo8/deactivate.xml")

    h:learn("/services/foo9/activate.xml")
    h:learn("/services/foo9/deactivate.xml")

    assert.same( {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, h:get_paths())

    h:learn("/services/foo1/activate.xml")
    h:learn("/services/foo2/activate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, h:get_paths())

    for i=1,5 do
      h:learn("/services/" .. tostring(i) .. "/deactivate.xml")
      h:learn("/services/" .. tostring(i) .. "/activate.xml")
    end


    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, h:get_paths())

    h:learn("/services/foo6/activate.xml")
    h:learn("/services/foo7/activate.xml")
    h:learn("/services/foo8/deactivate.xml")
    h:learn("/services/foo9/deactivate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
    }, h:get_paths())

  end)

  it('compresses paths (again)', function()
    local h = Host.new('google.com')

    h:learn("/admin/api/features.xml")
    h:learn("/admin/api/applications.xml")
    h:learn("/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, h:get_paths())

    h:learn("/admin/xxx/features.xml")
    h:learn("/admin/xxx/applications.xml")
    h:learn("/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, h:get_paths())
  end)

  it('compresses in even more cases', function()

    local h = Host.new('google.com')

    h:learn("/admin/api/features.xml")
    h:learn("/admin/api/applications.xml")
    h:learn("/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, h:get_paths())

    h:learn("/admin/xxx/features.xml")
    h:learn("/admin/xxx/applications.xml")
    h:learn("/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, h:get_paths())

    h = Host.new('google.com')

    h:learn("/admin/api/features.xml")
    h:learn("/admin/xxx/features.xml")

    assert.same( { "/admin/*/features.xml" }, h:get_paths())

    h:learn("/admin/api/applications.xml")
    h:learn("/admin/xxx/applications.xml")

    h:learn("/admin/api/users.xml")
    h:learn("/admin/xxx/users.xml")

    assert.same( {
      "/admin/*/applications.xml",
      "/admin/*/features.xml",
      "/admin/*/users.xml"
    }, h:get_paths())

  end)

  describe(':unlearn', function()
    it('unlearns the given path rules', function()

      local h = create_host()

      assert.truthy(h:unlearn("/*/foo5/activate.xml"))

      assert.same(h:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.truthy(h:unlearn("/services/*/activate.xml"))

      assert.same(h:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/users/*/activate.xml"
      })

      -- unlearn only works for exact paths, not for matches
      assert.equals(false, h:unlearn("/*/*/activate.xml"))
    end)

    it('handles a regression test that happened in the past', function()
      local h = Host.new('google.com')

      h.root = {
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

      assert.same(h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/*/suspend.xml",
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml",
        "/services/foo9/*.xml"
      })

      h:unlearn("/services/*/activate.xml")

      assert.same(h:get_paths(), {
        "/services/*/deactivate.xml",
        "/services/*/suspend.xml",
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml",
        "/services/foo9/*.xml"
      })

    end)

  end)

end)
