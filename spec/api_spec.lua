local Host = require 'autoswagger.host'
local API = require 'autoswagger.api'

describe('API', function()
  local host
  before_each(function()
    host = Host:new('foo', nil, nil, nil, 'host_guid')
  end)

  it('can be created', function()
    local api = API:new(host, '/foo/bar', 'api_guid')
    assert.equal(api.host, host)
    assert.equal(api.path, '/foo/bar')
  end)

  describe('add_operation_info', function()
    it('adds parameter info to the api', function()
      local a = API:new(host, '/api/accounts/*.xml', 'api_guid')
      a:add_operation_info("PUT",
                           "/api/accounts/42",
                           "user_id=1&cat_id=4")
      assert.truthy(a.operations.PUT)
      assert.truthy(a.operations.PUT.parameters.account_id)
    end)
  end)

  describe('get_swagger_path', function()
    it('replaces wildcards with awesome names', function()
      local a = API:new(host, '/apis/*/accounts/*.xml', 'api_guid')
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

      local api = API:new_from_swagger(host, swagger)

      assert.equal(api.path, '/foo/bar/*.xml')
      assert.same(api:get_methods(), {'GET', 'POST'})
    end)
  end)
end)

