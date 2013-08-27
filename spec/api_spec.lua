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

  describe('add_operation_info', function()
    it('adds parameter info to the api', function()
      local a = API.new('/api/accounts/*.xml')
      a:add_operation_info("PUT",
                           "/api/accounts/42",
                           "user_id=1&cat_id=4")
      assert.truthy(a.operations.PUT)
      assert.truthy(a.operations.PUT.parameters.accounts_id)
    end)
  end)
end)

