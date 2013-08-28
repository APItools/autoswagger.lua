local as = require('autoswagger')
local Host = as.Host
local EOL  = as.EOL

local function create_host()
  local h = Host:new('google.com')

  h:learn("GET","/users/foo/activate.xml")
  h:learn("GET","/applications/foo/activate.xml")

  h:learn("GET","/applications/foo2/activate.xml")
  h:learn("GET","/applications/foo3/activate.xml")

  h:learn("GET","/users/foo4/activate.xml")
  h:learn("GET","/users/foo5/activate.xml")

  h:learn("GET","/applications/foo4/activate.xml")
  h:learn("GET","/applications/foo5/activate.xml")

  h:learn("GET","/services/foo5/activate.xml")
  h:learn("GET","/fulanitos/foo5/activate.xml")

  h:learn("GET","/fulanitos/foo6/activate.xml")
  h:learn("GET","/fulanitos/foo7/activate.xml")
  h:learn("GET","/fulanitos/foo8/activate.xml")

  h:learn("GET","/services/foo6/activate.xml")
  h:learn("GET","/services/foo7/activate.xml")
  h:learn("GET","/services/foo8/activate.xml")

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
      local h = Host:new()

      h:learn("GET","/users/foo/activate.xml")
      assert.same( {"/users/foo/activate.xml"}, h:get_paths())

      h:learn("GET","/applications/foo/activate.xml")
      assert.same( {"/*/foo/activate.xml"}, h:get_paths())

      h:learn("GET","/applications/foo2/activate.xml")
      h:learn("GET","/applications/foo3/activate.xml")
      h:learn("GET","/users/foo4/activate.xml")
      h:learn("GET","/users/foo5/activate.xml")
      h:learn("GET","/users/foo6/activate.xml")
      h:learn("GET","/users/foo7/activate.xml")

      assert.same(h:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      h:learn("GET","/users/foo/activate.xml")

      assert.same( h:get_paths(), {
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      h:learn("GET","/applications/foo4/activate.xml")
      h:learn("GET","/applications/foo5/activate.xml")

      h:learn("GET","/services/bar5/activate.xml")

      h:learn("GET","/fulanitos/bar5/activate.xml")
      h:learn("GET","/fulanitos/bar6/activate.xml")
      h:learn("GET","/fulanitos/bar7/activate.xml")
      h:learn("GET","/fulanitos/bar8/activate.xml")

      h:learn("GET","/services/foo6/activate.xml")
      h:learn("GET","/services/foo7/activate.xml")
      h:learn("GET","/services/foo8/activate.xml")

      h:learn("GET","/applications/foo4/activate.xml")
      h:learn("GET","/applications/foo5/activate.xml")

      h:learn("GET","/services/bar5/activate.xml")
      h:learn("GET","/fulanitos/bar5/activate.xml")

      h:learn("GET","/fulanitos/bar6/activate.xml")
      h:learn("GET","/fulanitos/bar7/activate.xml")
      h:learn("GET","/fulanitos/bar8/activate.xml")

      h:learn("GET","/services/bar6/activate.xml")
      h:learn("GET","/services/bar7/activate.xml")
      h:learn("GET","/services/bar8/activate.xml")


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
      local h = Host:new()

      h:learn("GET","/services/foo6/activate.xml")
      h:learn("GET","/services/foo7/activate.xml")
      h:learn("GET","/services/foo8/activate.xml")

      assert.same( {"/services/*/activate.xml"}, h:get_paths())

      h:learn("GET","/services/foo6/deactivate.xml")
      h:learn("GET","/services/foo7/deactivate.xml")
      h:learn("GET","/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })

      h:learn("GET","/services/foo/60.xml")
      h:learn("GET","/services/foo/61.xml")
      h:learn("GET","/services/foo/62.xml")

      assert.same( h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/foo/*.xml"
      })

    end)

    it('understands threshold', function()

      local h = Host:new('google.com') -- default: threshold = 1

      h:learn("GET","/services/foo6/activate.xml")
      h:learn("GET","/services/foo6/deactivate.xml")
      h:learn("GET","/services/foo7/activate.xml")
      h:learn("GET","/services/foo7/deactivate.xml")
      h:learn("GET","/services/foo8/activate.xml")
      h:learn("GET","/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml"
      })

      -- never merge
      h = Host:new('google.com', 0.0)

      h:learn("GET","/services/foo6/activate.xml")
      h:learn("GET","/services/foo6/deactivate.xml")
      h:learn("GET","/services/foo7/activate.xml")
      h:learn("GET","/services/foo7/deactivate.xml")
      h:learn("GET","/services/foo8/activate.xml")
      h:learn("GET","/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/foo6/activate.xml",
        "/services/foo6/deactivate.xml",
        "/services/foo7/activate.xml",
        "/services/foo7/deactivate.xml",
        "/services/foo8/activate.xml",
        "/services/foo8/deactivate.xml"
      })

      h = Host:new('google.com', 0.2)
      -- fake the score so that the words that are not var are seen more often
      -- the threshold 0.2 means that only merge if word is 5 (=1/0.2) times less frequent
      -- than the most common word
      h.score = {
        services = 20, activate = 10, deactivate = 10,
        foo6 = 1, foo7 = 1, foo8 = 1
      }

      h:learn("GET","/services/foo6/activate.xml")
      h:learn("GET","/services/foo6/deactivate.xml")
      h:learn("GET","/services/foo7/activate.xml")
      h:learn("GET","/services/foo7/deactivate.xml")
      h:learn("GET","/services/foo8/activate.xml")
      h:learn("GET","/services/foo8/deactivate.xml")

      assert.same( h:get_paths(), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })
    end)
  end)

  it('understands unmergeable tokens', function()
    -- without unmergeable tokens
    local h = Host:new('google.com')

    h:learn("GET","/services/foo6/activate.xml")
    h:learn("GET","/services/foo6/deactivate.xml")

    assert.same( h:get_paths(), { "/services/foo6/*.xml" })

    h:learn("GET","/services/foo7/activate.xml")
    h:learn("GET","/services/foo7/deactivate.xml")

    h:learn("GET","/services/foo8/activate.xml")
    h:learn("GET","/services/foo8/deactivate.xml")

    assert.same( h:get_paths(), {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml"
    })

    -- with unmergeable tokens
    h = Host:new('google.com', 1.0, {"activate", "deactivate"})

    h:learn("GET","/services/foo6/activate.xml")
    h:learn("GET","/services/foo6/deactivate.xml")

    assert.same( h:get_paths(), {
      "/services/foo6/activate.xml",
      "/services/foo6/deactivate.xml"
    })

    h:learn("GET","/services/foo7/activate.xml")
    h:learn("GET","/services/foo7/deactivate.xml")

    h:learn("GET","/services/foo8/activate.xml")
    h:learn("GET","/services/foo8/deactivate.xml")

    assert.same( h:get_paths(), {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml"
    })

  end)

  it('unifies paths', function()
    local h = Host:new('google.com')

    h:learn("GET","/services/foo6/activate.xml")
    h:learn("GET","/services/foo6/deactivate.xml")

    assert.same( {"/services/foo6/*.xml"}, h:get_paths())

    h:learn("GET","/services/foo6/activate.xml")
    h:learn("GET","/services/foo6/deactivate.xml")

    h:learn("GET","/services/foo7/activate.xml")
    h:learn("GET","/services/foo7/deactivate.xml")

    h:learn("GET","/services/foo8/activate.xml")
    h:learn("GET","/services/foo8/deactivate.xml")

    h:learn("GET","/services/foo9/activate.xml")
    h:learn("GET","/services/foo9/deactivate.xml")

    assert.same( {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, h:get_paths())

    h:learn("GET","/services/foo1/activate.xml")
    h:learn("GET","/services/foo2/activate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, h:get_paths())

    for i=1,5 do
      h:learn("GET","/services/" .. tostring(i) .. "/deactivate.xml")
      h:learn("GET","/services/" .. tostring(i) .. "/activate.xml")
    end


    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, h:get_paths())

    h:learn("GET","/services/foo6/activate.xml")
    h:learn("GET","/services/foo7/activate.xml")
    h:learn("GET","/services/foo8/deactivate.xml")
    h:learn("GET","/services/foo9/deactivate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
    }, h:get_paths())

  end)

  it('compresses paths (again)', function()
    local h = Host:new('google.com')

    h:learn("GET","/admin/api/features.xml")
    h:learn("GET","/admin/api/applications.xml")
    h:learn("GET","/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, h:get_paths())

    h:learn("GET","/admin/xxx/features.xml")
    h:learn("GET","/admin/xxx/applications.xml")
    h:learn("GET","/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, h:get_paths())
  end)

  it('compresses in even more cases', function()

    local h = Host:new('google.com')

    h:learn("GET","/admin/api/features.xml")
    h:learn("GET","/admin/api/applications.xml")
    h:learn("GET","/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, h:get_paths())

    h:learn("GET","/admin/xxx/features.xml")
    h:learn("GET","/admin/xxx/applications.xml")
    h:learn("GET","/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, h:get_paths())

    h = Host:new('google.com')

    h:learn("GET","/admin/api/features.xml")
    h:learn("GET","/admin/xxx/features.xml")

    assert.same( { "/admin/*/features.xml" }, h:get_paths())

    h:learn("GET","/admin/api/applications.xml")
    h:learn("GET","/admin/xxx/applications.xml")

    h:learn("GET","/admin/api/users.xml")
    h:learn("GET","/admin/xxx/users.xml")

    assert.same( {
      "/admin/*/applications.xml",
      "/admin/*/features.xml",
      "/admin/*/users.xml"
    }, h:get_paths())

  end)

  describe(':forget', function()
    it('forgets the given path rules', function()

      local h = create_host()

      assert.truthy(h:forget("/*/foo5/activate.xml"))

      assert.same(h:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/services/*/activate.xml",
        "/users/*/activate.xml"
      })

      assert.truthy(h:forget("/services/*/activate.xml"))

      assert.same(h:get_paths(), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/fulanitos/*/activate.xml",
        "/users/*/activate.xml"
      })

      -- forget only works for exact paths, not for matches
      assert.equals(false, h:forget("/*/*/activate.xml"))
    end)

    it('handles a regression test that happened in the past', function()
      local h = Host:new('google.com')

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

      h:forget("/services/*/activate.xml")

      assert.same(h:get_paths(), {
        "/services/*/deactivate.xml",
        "/services/*/suspend.xml",
        "/services/foo6/*.xml",
        "/services/foo7/*.xml",
        "/services/foo8/*.xml",
        "/services/foo9/*.xml"
      })

    end)


    describe('to_swagger', function()
      it('returns a table with the swagger spec corresponding to the host', function()
        local h = Host:new('google.com')

        for i=1,10 do
          h:learn('GET', '/users/' .. tostring(i) .. '/app/' .. tostring(i) .. '.xml')
        end


        local s = h:to_swagger()

        local expected_operation = {
          method = 'GET',
          nickname = 'unavailable',
          summary  = 'Get app of users',
          notes    = 'Automatically generated Operation spec',
          parameters = {
            { paramType = 'path',
              name = 'app_id',
              description = "Possible values are: '8', '9', '10'",
              ['type'] = 'string',
              required = true
            },
            { paramType = 'path',
              name = 'user_id',
              description = "Possible values are: '8', '9', '10'",
              ['type'] = 'string',
              required = true
            }
          }
        }

        assert.same(s.apis[1].operations[1], expected_operation)

        assert.same(h:to_swagger(), {
          apiVersion     = "1.0",
          swaggerVersion = "1.2",
          models         = {},
          apis = {
            { path        = "/users/{user_id}/app/{app_id}.xml",
              description = "Automatically generated API spec",
              operations = { expected_operation }
            }
          }
        })
      end)
    end)

  end)


end)
