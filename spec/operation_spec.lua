local Host      = require 'autoswagger.host'
local API       = require 'autoswagger.api'
local Operation = require 'autoswagger.operation'

describe('Operation', function()
  it('can be created', function()
    local api = {host=Host:new('google.com'), path = '/foo'}
    local o = Operation:new(api, 'GET')
    assert.equals(o.method, 'GET')
    assert.equals(o.api, api)
  end)

  describe(':parse_path_parameters', function()
    it('reads the parameters of a given path, using its api', function()
      local api = API:new(Host:new('google.com'), '/applications/*/users/*')
      local o = Operation:new(api, 'GET')

      local params = o:parse_path_parameters('/applications/1/users/2')
      assert.same({application_id = '1', user_id = '2'}, params)
    end)
  end)

  describe(':add_parameter_info', function()
    it('reads params from the path', function()
      local api = API:new(Host:new('google.com'), '/users/*/app/*.xml')
      local o = Operation:new(api, 'GET')

      for i=1,5 do
        o:add_parameter_info('/users/' .. tostring(i) .. '/app/' .. tostring(id) .. '.xml')
      end

      assert.same(o:get_parameter_names(), {'app_id', 'user_id'})

    end)
  end)

  describe(':get_summary', function()
    local function test_summary(method, path, result)
      local api = API:new(Host:new('google.com'), path)
      assert.equal(Operation:new(api, method):get_summary(), result)
    end

    it('works in the usual simple cases', function()
      test_summary("GET", "/v1/api/word/*", "Get word by id")
      test_summary("GET", "/v1/api/word/*.json", "Get word by id")
      test_summary("POST", "/v1/api/word.xml", "Create word")
      test_summary("PUT", "/v1/api/word/*", "Modify word by id")
      test_summary("DELETE", "/v1/api/word/*", "Delete word by id")
      test_summary("DELETE", "/*.xml", "Delete by id")
    end)

    it('uses the last element when there are no wildcards', function()
      test_summary("GET","/api/accounts.xml", "List accounts")
      test_summary("GET","/api/accounts", "List accounts")
      test_summary("POST","/api/accounts.xml", "Create accounts")
      test_summary("PUT","/api/accounts.xml", "Modify accounts")
      test_summary("DELETE","/api/accounts.xml", "Delete accounts")
    end)

    it('assumes that the action is a verb for PUT methods when it finds combinations of type word/*/action', function()
      test_summary("PUT", "/v1/api/word/*/suspend", "Suspend word by id")
      test_summary("PUT", "/v1/api/word/*/suspend.xml", "Suspend word by id")
      test_summary("POST", "/v1/api/word/*/activate.xml", "Create activate of word")
    end)

    it('works ok with more than one *', function()
      test_summary("GET", "/v1/api/account/*/application/*.xml", "Get application of account")
      test_summary("DELETE", "/v1/api/account/*/application/*.xml", "Delete application of account")
      test_summary("PUT", "/v1/api/account/*/application/*.xml", "Modify application of account")
      test_summary("PUT", "/*/application/*.xml", "Modify application")
      test_summary("POST", "/v1/api/account/*/application.xml", "Create application of account")
    end)

    it('works on edge cases', function()
      test_summary("POST", "/v1", "Create v1")
      test_summary("POST", "/", "Create")
      test_summary("GET", "/v1", "List v1")
      test_summary("GET", "/", "List")
      test_summary("DELETE", "/", "Delete")
    end)
  end)

  describe(':new_from_swagger', function()
    it('creates a new operation', function()
      local swagger = {
        method     = 'GET',
        parameters = {
          { paramType = 'path',
            name = 'app_id',
            description = "Possible values are: '8', '9', '10'",
            possible_values = {'8', '9', '10'},
            ['type'] = 'string',
            required = true
          },
          { paramType = 'path',
            name = 'user_id',
            description = "Possible values are: '8', '9', '10'",
            possible_values = {'8', '9', '10'},
            ['type'] = 'string',
            ['type'] = 'string',
            required = true
          }
        }
      }

      local api =  API:new(Host:new('google.com'), '/foo')
      local operation = Operation:new_from_swagger(api, swagger)

      assert.equal(operation.method, 'GET')
      assert.same(operation:get_parameter_names(), {'app_id', 'user_id'})
    end)
  end)
end)
