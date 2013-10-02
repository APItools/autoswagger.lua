local Host = require 'autoswagger.host'
local API = require 'autoswagger.api'

describe('API', function()

  it('can be created', function()
    local h = Host:new('foo')
    local api = API:new(h, '/foo/bar')
    assert.equal(api.host, h)
    assert.equal(api.path, '/foo/bar')
  end)

  describe('add_operation_info', function()
    it('adds parameter info to the api', function()
      local a = API:new(Host:new('foo'), '/api/accounts/*.xml')
      a:add_operation_info("PUT",
                           "/api/accounts/42",
                           "user_id=1&cat_id=4")
      assert.truthy(a.operations.PUT)
      assert.truthy(a.operations.PUT.parameters.account_id)
    end)
  end)

  describe('get_swagger_path', function()
    it('replaces wildcards with awesome names', function()
      local a = API:new(Host:new('foo'), '/apis/*/accounts/*.xml')
      assert.equal(a:get_swagger_path(), '/apis/{api_id}/accounts/{account_id}.xml')
    end)
  end)

  describe('new_from_swagger', function()
    it('creates a new api', function()
      local swagger = {
        path       = "/foo/bar/{user_id}.xml",
        operations = {
          { method = 'GET',
            parameters = {
              { paramType = 'path',
                name = 'app_id',
                description = "Possible values are: '8', '9', '10'",
                possible_values = {'8', '9', '10'},
                ['type'] = 'string',
                required = true
              }
            }
          },
          { method = 'POST',
            parameters = {
              { paramType = 'path',
                name = 'app_id',
                description = "Possible values are: '8', '9', '10'",
                possible_values = {'8', '9', '10'},
                ['type'] = 'string',
                required = true
              }
            }
          }
        }
      }

      local api = API:new_from_swagger(Host:new('google.com'), swagger)

      assert.equal(api.path, '/foo/bar/*.xml')
      assert.same(api:get_methods(), {'GET', 'POST'})
    end)
  end)
end)

