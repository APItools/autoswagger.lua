local API = require 'autoswagger.api'

describe('API', function()

  it('can be created', function()
    local h = {}
    local api = API.new(h, '/foo/bar')
    assert.equal(api.host, h)
    assert.equal(api.path, '/foo/bar')
  end)

  describe('add_operation_info', function()
    it('adds parameter info to the api', function()
      local a = API.new({}, '/api/accounts/*.xml')
      a:add_operation_info("PUT",
                           "/api/accounts/42",
                           "user_id=1&cat_id=4")
      assert.truthy(a.operations.PUT)
      assert.truthy(a.operations.PUT.parameters.accounts_id)
    end)
  end)
end)

