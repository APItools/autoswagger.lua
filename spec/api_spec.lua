local API = require 'autoswagger.api'

describe('API', function()

  it('can be created', function()
    local h = {}
    local api = API:new(h, '/foo/bar')
    assert.equal(api.host, h)
    assert.equal(api.path, '/foo/bar')
  end)

  describe('add_operation_info', function()
    it('adds parameter info to the api', function()
      local a = API:new({}, '/api/accounts/*.xml')
      a:add_operation_info("PUT",
                           "/api/accounts/42",
                           "user_id=1&cat_id=4")
      assert.truthy(a.operations.PUT)
      assert.truthy(a.operations.PUT.parameters.account_id)
    end)
  end)

  describe('get_swagger_path', function()
    it('replaces wildcards with awesome names', function()
      local a = API:new({}, '/apis/*/accounts/*.xml')
      assert.equal(a:get_swagger_path(), '/apis/{api_id}/accounts/{account_id}.xml')
    end)
  end)
end)

