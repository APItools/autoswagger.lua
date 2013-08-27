local API = require 'autoswagger.api'

describe('API', function()
  it('can be created', function()
    local api = API.new('/foo/bar')
    assert.equal(api.path, '/foo/bar')
  end)

  describe('parse_path_params', function()
    it('returns swagger parameter specs for a given path', function()
      local a = API.new('/api/accounts/*/applications/*.xml')
      local params = a:parse_path_params("/api/accounts/42/applications/13.xml")
      assert.same(params, {accounts_id='42', applications_id='13'})
    end)
  end)

  describe('add_method', function()
    it('works on the base case', function()
      local a = API.new('/foo')
      a:add_method('GET')
      assert.same(a.methods, {'GET'})
    end)

    it('does not repeat', function()
      local a = API.new('/foo')
      a:add_method('GET')
      a:add_method('GET')
      assert.same(a.methods, {'GET'})
    end)

    it('uppercases', function()
      local a = API.new('/foo')
      a:add_method('get')
      assert.same(a.methods, {'GET'})
    end)

    it('sorts', function()
      local a = API.new('/foo')
      a:add_method('put')
      a:add_method('get')
      assert.same(a.methods, {'GET', 'PUT'})
    end)
  end)

  describe('add_parameter_info', function()
    it('adds parameter info to the api', function()
      local a = API.new('/api/accounts/*.xml')
      a:add_parameter_info("/api/accounts/42",
                           "user_id=1&cat_id=4")
      assert.same(a.parameters, {
        accounts_id={
          name = "account_id",
          last_values = { 42 },
        },
        user_id={},
        cat_id={}
      })
      -- empty
    end)
  end)
end)

