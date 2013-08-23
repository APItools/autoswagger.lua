local Parser = require 'parser'
local EOL = Parser.EOL

local function create_path_finder_1()
  local g = Parser.new()

  g:learn("google.com","/users/foo/activate.xml")
  g:learn("google.com","/applications/foo/activate.xml")

  g:learn("google.com","/applications/foo2/activate.xml")
  g:learn("google.com","/applications/foo3/activate.xml")

  g:learn("google.com","/users/foo4/activate.xml")
  g:learn("google.com","/users/foo5/activate.xml")

  g:learn("google.com","/applications/foo4/activate.xml")
  g:learn("google.com","/applications/foo5/activate.xml")

  g:learn("google.com","/services/foo5/activate.xml")
  g:learn("google.com","/fulanitos/foo5/activate.xml")

  g:learn("google.com","/fulanitos/foo6/activate.xml")
  g:learn("google.com","/fulanitos/foo7/activate.xml")
  g:learn("google.com","/fulanitos/foo8/activate.xml")

  g:learn("google.com","/services/foo6/activate.xml")
  g:learn("google.com","/services/foo7/activate.xml")
  g:learn("google.com","/services/foo8/activate.xml")

  return g
end

describe('Parser', function()



  describe(':match', function()
    it('returns a list of the paths that match a given path. The list can be empty', function()
      local g = create_path_finder_1()
      local all_paths = g:get_paths('google.com')

      assert.same(all_paths, g:match("google.com","/*/*/activate.xml"))
      assert.same(all_paths, g:match("google.com","/*/*/*.xml"))

      assert.same({"/fulanitos/*/activate.xml"}, g:match("google.com","/fulanitos/whatever/activate.xml"))
      assert.same({"/*/foo/activate.xml"}, g:match("google.com","/whatever/foo/activate.xml"))
      assert.same({"/*/foo5/activate.xml"}, g:match("google.com","/whatever/foo5/activate.xml"))

      assert.same({}, g:match("google.com","/"))
      assert.same({}, g:match("google.com","/*/*/activate.xml.whatever"))
      assert.same({}, g:match("google.com","/whatever/foo_not_there/activate.xml"))
    end)
  end)

  describe(':learn', function()

    it('builds the expected paths', function()

      local g = create_path_finder_1()
      local v = g:get_paths('google.com')

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
      local g = Parser.new()

      g:learn("google.com","/users/foo/activate.xml")
      assert.same( {"/users/foo/activate.xml"}, g:get_paths('google.com'))

      g:learn("google.com","/applications/foo/activate.xml")
      assert.same( {"/*/foo/activate.xml"}, g:get_paths('google.com'))

      g:learn("google.com","/applications/foo2/activate.xml")
      g:learn("google.com","/applications/foo3/activate.xml")
      g:learn("google.com","/users/foo4/activate.xml")
      g:learn("google.com","/users/foo5/activate.xml")
      g:learn("google.com","/users/foo6/activate.xml")
      g:learn("google.com","/users/foo7/activate.xml")

      assert.same(g:get_paths('google.com'), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      g:learn("google.com","/users/foo/activate.xml")

      assert.same( g:get_paths('google.com'), {
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      g:learn("google.com","/applications/foo4/activate.xml")
      g:learn("google.com","/applications/foo5/activate.xml")

      g:learn("google.com","/services/bar5/activate.xml")

      g:learn("google.com","/fulanitos/bar5/activate.xml")
      g:learn("google.com","/fulanitos/bar6/activate.xml")
      g:learn("google.com","/fulanitos/bar7/activate.xml")
      g:learn("google.com","/fulanitos/bar8/activate.xml")

      g:learn("google.com","/services/foo6/activate.xml")
      g:learn("google.com","/services/foo7/activate.xml")
      g:learn("google.com","/services/foo8/activate.xml")

      g:learn("google.com","/applications/foo4/activate.xml")
      g:learn("google.com","/applications/foo5/activate.xml")

      g:learn("google.com","/services/bar5/activate.xml")
      g:learn("google.com","/fulanitos/bar5/activate.xml")

      g:learn("google.com","/fulanitos/bar6/activate.xml")
      g:learn("google.com","/fulanitos/bar7/activate.xml")
      g:learn("google.com","/fulanitos/bar8/activate.xml")

      g:learn("google.com","/services/bar6/activate.xml")
      g:learn("google.com","/services/bar7/activate.xml")
      g:learn("google.com","/services/bar8/activate.xml")


      assert.same( g:get_paths('google.com'), {
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.same( {"/services/*/activate.xml"}, g:match("google.com","/services/foo8/activate.xml"))
      assert.same( {"/services/*/activate.xml"}, g:match("google.com","/services/foo18/activate.xml"))
      assert.same( {}, g:match("google.com","/services/foo8/activate.json"))
      assert.same( {}, g:match("google.com","/ser/foo8/activate.xml"))
    end)

    it('can handle edge cases', function()
      local g = Parser.new()

      g:learn("google.com","/services/foo6/activate.xml")
      g:learn("google.com","/services/foo7/activate.xml")
      g:learn("google.com","/services/foo8/activate.xml")

      assert.same( {"/services/*/activate.xml"}, g:get_paths('google.com'))

      g:learn("google.com","/services/foo6/deactivate.xml")
      g:learn("google.com","/services/foo7/deactivate.xml")
      g:learn("google.com","/services/foo8/deactivate.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })

      g:learn("google.com","/services/foo/60.xml")
      g:learn("google.com","/services/foo/61.xml")
      g:learn("google.com","/services/foo/62.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/foo/*.xml"
      })

    end)

    it('understands threshold', function()

      local g = Parser.new() -- default: threshold = 1

      g:learn("google.com","/services/foo6/activate.xml")
      g:learn("google.com","/services/foo6/deactivate.xml")
      g:learn("google.com","/services/foo7/activate.xml")
      g:learn("google.com","/services/foo7/deactivate.xml")
      g:learn("google.com","/services/foo8/activate.xml")
      g:learn("google.com","/services/foo8/deactivate.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml"
      })

      -- never merge
      g = Parser.new(0.0)

      g:learn("google.com","/services/foo6/activate.xml")
      g:learn("google.com","/services/foo6/deactivate.xml")
      g:learn("google.com","/services/foo7/activate.xml")
      g:learn("google.com","/services/foo7/deactivate.xml")
      g:learn("google.com","/services/foo8/activate.xml")
      g:learn("google.com","/services/foo8/deactivate.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/foo6/activate.xml",
        "/services/foo6/deactivate.xml",
        "/services/foo7/activate.xml",
        "/services/foo7/deactivate.xml",
        "/services/foo8/activate.xml",
        "/services/foo8/deactivate.xml"
      })

      g = Parser.new(0.2)
      -- fake the score so that the words that are not var are seen more often
      -- the threshold 0.2 means that only merge if word is 5 (=1/0.2) times less frequent
      -- than the most common word
      g.hosts = {
        ['google.com'] = {
          apis = {},
          root = {},
          score = {
            services = 20, activate = 10, deactivate = 10,
            foo6 = 1, foo7 = 1, foo8 = 1
          }
        }
      }

      g:learn("google.com","/services/foo6/activate.xml")
      g:learn("google.com","/services/foo6/deactivate.xml")
      g:learn("google.com","/services/foo7/activate.xml")
      g:learn("google.com","/services/foo7/deactivate.xml")
      g:learn("google.com","/services/foo8/activate.xml")
      g:learn("google.com","/services/foo8/deactivate.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })
    end)

  end)

  it('understands unmergeable tokens', function()
    -- without unmergeable tokens
    local g = Parser.new()

    g:learn("google.com","/services/foo6/activate.xml")
    g:learn("google.com","/services/foo6/deactivate.xml")

    assert.same( g:get_paths('google.com'), { "/services/foo6/*.xml" })

    g:learn("google.com","/services/foo7/activate.xml")
    g:learn("google.com","/services/foo7/deactivate.xml")

    g:learn("google.com","/services/foo8/activate.xml")
    g:learn("google.com","/services/foo8/deactivate.xml")

    assert.same( g:get_paths('google.com'), {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml"
    })

    -- with unmergeable tokens
    g = Parser.new(1.0, {"activate", "deactivate"})

    g:learn("google.com","/services/foo6/activate.xml")
    g:learn("google.com","/services/foo6/deactivate.xml")

    assert.same( g:get_paths('google.com'), {
      "/services/foo6/activate.xml",
      "/services/foo6/deactivate.xml"
    })

    g:learn("google.com","/services/foo7/activate.xml")
    g:learn("google.com","/services/foo7/deactivate.xml")

    g:learn("google.com","/services/foo8/activate.xml")
    g:learn("google.com","/services/foo8/deactivate.xml")

    assert.same( g:get_paths('google.com'), {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml"
    })

  end)

  it('unifies paths', function()
    local g = Parser.new()

    g:learn("google.com","/services/foo6/activate.xml")
    g:learn("google.com","/services/foo6/deactivate.xml")

    assert.same( {"/services/foo6/*.xml"}, g:get_paths('google.com'))

    g:learn("google.com","/services/foo6/activate.xml")
    g:learn("google.com","/services/foo6/deactivate.xml")

    g:learn("google.com","/services/foo7/activate.xml")
    g:learn("google.com","/services/foo7/deactivate.xml")

    g:learn("google.com","/services/foo8/activate.xml")
    g:learn("google.com","/services/foo8/deactivate.xml")

    g:learn("google.com","/services/foo9/activate.xml")
    g:learn("google.com","/services/foo9/deactivate.xml")

    assert.same( {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, g:get_paths('google.com'))

    g:learn("google.com","/services/foo1/activate.xml")
    g:learn("google.com","/services/foo2/activate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, g:get_paths('google.com'))

    for i=1,5 do
      g:learn("google.com","/services/" .. tostring(i) .. "/deactivate.xml")
      g:learn("google.com","/services/" .. tostring(i) .. "/activate.xml")
    end


    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, g:get_paths('google.com'))

    g:learn("google.com","/services/foo6/activate.xml")
    g:learn("google.com","/services/foo7/activate.xml")
    g:learn("google.com","/services/foo8/deactivate.xml")
    g:learn("google.com","/services/foo9/deactivate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
    }, g:get_paths('google.com'))

  end)

  it('compresses paths (again)', function()
    local g = Parser.new()

    g:learn("google.com","/admin/api/features.xml")
    g:learn("google.com","/admin/api/applications.xml")
    g:learn("google.com","/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, g:get_paths('google.com'))

    g:learn("google.com","/admin/xxx/features.xml")
    g:learn("google.com","/admin/xxx/applications.xml")
    g:learn("google.com","/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, g:get_paths('google.com'))
  end)

  it('compresses in even more cases', function()

    local g = Parser.new()

    g:learn("google.com","/admin/api/features.xml")
    g:learn("google.com","/admin/api/applications.xml")
    g:learn("google.com","/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, g:get_paths('google.com'))

    g:learn("google.com","/admin/xxx/features.xml")
    g:learn("google.com","/admin/xxx/applications.xml")
    g:learn("google.com","/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, g:get_paths('google.com'))

    g = Parser.new()

    g:learn("google.com","/admin/api/features.xml")
    g:learn("google.com","/admin/xxx/features.xml")

    assert.same( { "/admin/*/features.xml" }, g:get_paths('google.com'))

    g:learn("google.com","/admin/api/applications.xml")
    g:learn("google.com","/admin/xxx/applications.xml")

    g:learn("google.com","/admin/api/users.xml")
    g:learn("google.com","/admin/xxx/users.xml")

    assert.same( {
      "/admin/*/applications.xml",
      "/admin/*/features.xml",
      "/admin/*/users.xml"
    }, g:get_paths('google.com'))

  end)

  describe(':unlearn', function()
    it('unlearns the given path rules', function()

      local g = create_path_finder_1()

      assert.truthy(g:unlearn('google.com', "/*/foo5/activate.xml"))

      assert.same(g:get_paths('google.com'), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.truthy(g:unlearn('google.com', "/services/*/activate.xml"))

      assert.same(g:get_paths('google.com'), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/users/*/activate.xml"
      })

      -- unlearn only works for exact paths, not for matches
      assert.equals(false, g:unlearn('google.com', "/*/*/activate.xml"))
    end)

    it('handles a regression test that happened in the past', function()
      local g = Parser.new()

      g.hosts = {
        ['google.com'] = {
          root = {
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
          },
          score = {},
          apis = {}
        }
      }

      assert.same(g:get_paths('google.com'), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/*/suspend.xml",
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml",
        "/services/foo9/*.xml"
      })

      g:unlearn('google.com', "/services/*/activate.xml")

      assert.same(g:get_paths('google.com'), {
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
