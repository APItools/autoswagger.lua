local as = require('autoswagger')
local Brain = as.Brain
local EOL   = as.EOL

local function create_path_finder_1()
  local g = Brain:new()

  g:learn("GET","google.com","/users/foo/activate.xml")
  g:learn("GET","google.com","/applications/foo/activate.xml")

  g:learn("GET","google.com","/applications/foo2/activate.xml")
  g:learn("GET","google.com","/applications/foo3/activate.xml")

  g:learn("GET","google.com","/users/foo4/activate.xml")
  g:learn("GET","google.com","/users/foo5/activate.xml")

  g:learn("GET","google.com","/applications/foo4/activate.xml")
  g:learn("GET","google.com","/applications/foo5/activate.xml")

  g:learn("GET","google.com","/services/foo5/activate.xml")
  g:learn("GET","google.com","/fulanitos/foo5/activate.xml")

  g:learn("GET","google.com","/fulanitos/foo6/activate.xml")
  g:learn("GET","google.com","/fulanitos/foo7/activate.xml")
  g:learn("GET","google.com","/fulanitos/foo8/activate.xml")

  g:learn("GET","google.com","/services/foo6/activate.xml")
  g:learn("GET","google.com","/services/foo7/activate.xml")
  g:learn("GET","google.com","/services/foo8/activate.xml")

  return g
end

describe('Brain', function()

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
      local g = Brain:new()

      g:learn("GET","google.com","/users/foo/activate.xml")
      assert.same( {"/users/foo/activate.xml"}, g:get_paths('google.com'))

      g:learn("GET","google.com","/applications/foo/activate.xml")
      assert.same( {"/*/foo/activate.xml"}, g:get_paths('google.com'))

      g:learn("GET","google.com","/applications/foo2/activate.xml")
      g:learn("GET","google.com","/applications/foo3/activate.xml")
      g:learn("GET","google.com","/users/foo4/activate.xml")
      g:learn("GET","google.com","/users/foo5/activate.xml")
      g:learn("GET","google.com","/users/foo6/activate.xml")
      g:learn("GET","google.com","/users/foo7/activate.xml")

      assert.same(g:get_paths('google.com'), {
        "/*/foo/activate.xml",
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      g:learn("GET","google.com","/users/foo/activate.xml")

      assert.same( g:get_paths('google.com'), {
        "/applications/*/activate.xml",
        "/users/*/activate.xml"
      })

      g:learn("GET","google.com","/applications/foo4/activate.xml")
      g:learn("GET","google.com","/applications/foo5/activate.xml")

      g:learn("GET","google.com","/services/bar5/activate.xml")

      g:learn("GET","google.com","/fulanitos/bar5/activate.xml")
      g:learn("GET","google.com","/fulanitos/bar6/activate.xml")
      g:learn("GET","google.com","/fulanitos/bar7/activate.xml")
      g:learn("GET","google.com","/fulanitos/bar8/activate.xml")

      g:learn("GET","google.com","/services/foo6/activate.xml")
      g:learn("GET","google.com","/services/foo7/activate.xml")
      g:learn("GET","google.com","/services/foo8/activate.xml")

      g:learn("GET","google.com","/applications/foo4/activate.xml")
      g:learn("GET","google.com","/applications/foo5/activate.xml")

      g:learn("GET","google.com","/services/bar5/activate.xml")
      g:learn("GET","google.com","/fulanitos/bar5/activate.xml")

      g:learn("GET","google.com","/fulanitos/bar6/activate.xml")
      g:learn("GET","google.com","/fulanitos/bar7/activate.xml")
      g:learn("GET","google.com","/fulanitos/bar8/activate.xml")

      g:learn("GET","google.com","/services/bar6/activate.xml")
      g:learn("GET","google.com","/services/bar7/activate.xml")
      g:learn("GET","google.com","/services/bar8/activate.xml")
    end)

    it('can handle edge cases', function()
      local g = Brain:new()

      g:learn("GET","google.com","/services/foo6/activate.xml")
      g:learn("GET","google.com","/services/foo7/activate.xml")
      g:learn("GET","google.com","/services/foo8/activate.xml")

      assert.same( {"/services/*/activate.xml"}, g:get_paths('google.com'))

      g:learn("GET","google.com","/services/foo6/deactivate.xml")
      g:learn("GET","google.com","/services/foo7/deactivate.xml")
      g:learn("GET","google.com","/services/foo8/deactivate.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml"
      })

      g:learn("GET","google.com","/services/foo/60.xml")
      g:learn("GET","google.com","/services/foo/61.xml")
      g:learn("GET","google.com","/services/foo/62.xml")

      assert.same( g:get_paths('google.com'), {
        "/services/*/activate.xml",
        "/services/*/deactivate.xml",
        "/services/foo/*.xml"
      })

    end)
  end)

  it('unifies paths', function()
    local g = Brain:new()

    g:learn("GET","google.com","/services/foo6/activate.xml")
    g:learn("GET","google.com","/services/foo6/deactivate.xml")

    assert.same( {"/services/foo6/*.xml"}, g:get_paths('google.com'))

    g:learn("GET","google.com","/services/foo6/activate.xml")
    g:learn("GET","google.com","/services/foo6/deactivate.xml")

    g:learn("GET","google.com","/services/foo7/activate.xml")
    g:learn("GET","google.com","/services/foo7/deactivate.xml")

    g:learn("GET","google.com","/services/foo8/activate.xml")
    g:learn("GET","google.com","/services/foo8/deactivate.xml")

    g:learn("GET","google.com","/services/foo9/activate.xml")
    g:learn("GET","google.com","/services/foo9/deactivate.xml")

    assert.same( {
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, g:get_paths('google.com'))

    g:learn("GET","google.com","/services/foo1/activate.xml")
    g:learn("GET","google.com","/services/foo2/activate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, g:get_paths('google.com'))

    for i=1,5 do
      g:learn("GET","google.com","/services/" .. tostring(i) .. "/deactivate.xml")
      g:learn("GET","google.com","/services/" .. tostring(i) .. "/activate.xml")
    end


    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
      "/services/foo6/*.xml",
      "/services/foo7/*.xml",
      "/services/foo8/*.xml",
      "/services/foo9/*.xml"
    }, g:get_paths('google.com'))

    g:learn("GET","google.com","/services/foo6/activate.xml")
    g:learn("GET","google.com","/services/foo7/activate.xml")
    g:learn("GET","google.com","/services/foo8/deactivate.xml")
    g:learn("GET","google.com","/services/foo9/deactivate.xml")

    assert.same( {
      "/services/*/activate.xml",
      "/services/*/deactivate.xml",
    }, g:get_paths('google.com'))

  end)

  it('compresses paths (again)', function()
    local g = Brain:new()

    g:learn("GET","google.com","/admin/api/features.xml")
    g:learn("GET","google.com","/admin/api/applications.xml")
    g:learn("GET","google.com","/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, g:get_paths('google.com'))

    g:learn("GET","google.com","/admin/xxx/features.xml")
    g:learn("GET","google.com","/admin/xxx/applications.xml")
    g:learn("GET","google.com","/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, g:get_paths('google.com'))
  end)

  it('compresses in even more cases', function()

    local g = Brain:new()

    g:learn("GET","google.com","/admin/api/features.xml")
    g:learn("GET","google.com","/admin/api/applications.xml")
    g:learn("GET","google.com","/admin/api/users.xml")

    assert.same( { "/admin/api/*.xml" }, g:get_paths('google.com'))

    g:learn("GET","google.com","/admin/xxx/features.xml")
    g:learn("GET","google.com","/admin/xxx/applications.xml")
    g:learn("GET","google.com","/admin/xxx/users.xml")

    assert.same( {
      "/admin/api/*.xml",
      "/admin/xxx/*.xml"
    }, g:get_paths('google.com'))

    g = Brain:new()

    g:learn("GET","google.com","/admin/api/features.xml")
    g:learn("GET","google.com","/admin/xxx/features.xml")

    assert.same( { "/admin/*/features.xml" }, g:get_paths('google.com'))

    g:learn("GET","google.com","/admin/api/applications.xml")
    g:learn("GET","google.com","/admin/xxx/applications.xml")

    g:learn("GET","google.com","/admin/api/users.xml")
    g:learn("GET","google.com","/admin/xxx/users.xml")

    assert.same( {
      "/admin/*/applications.xml",
      "/admin/*/features.xml",
      "/admin/*/users.xml"
    }, g:get_paths('google.com'))

  end)

end)
