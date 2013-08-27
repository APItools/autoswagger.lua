local API       = require 'autoswagger.api'
local Operation = require 'autoswagger.operation'

describe('Operation', function()
  it('can be created', function()
    local api = {}
    local o = Operation.new(api, 'GET')
    assert.equals(o.method, 'GET')
    assert.equals(o.api, api)
  end)

  describe(':parse_path_parameters', function()
    it('reads the parameters of a given path, using its api', function()
      local api = API.new({}, '/applications/*/users/*')
      local o = Operation.new(api, 'GET')

      local params = o:parse_path_parameters('/applications/1/users/2')
      assert.same({applications_id = '1', users_id = '2'}, params)
    end)
  end)
end)
