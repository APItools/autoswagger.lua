local API       = require 'autoswagger.api'
local Operation = require 'autoswagger.operation'

describe('Operation', function()
  it('can be created', function()
    local api = {}
    local o = Operation:new(api, 'GET')
    assert.equals(o.method, 'GET')
    assert.equals(o.api, api)
  end)

  describe(':parse_path_parameters', function()
    it('reads the parameters of a given path, using its api', function()
      local api = API:new({}, '/applications/*/users/*')
      local o = Operation:new(api, 'GET')

      local params = o:parse_path_parameters('/applications/1/users/2')
      assert.same({application_id = '1', user_id = '2'}, params)
    end)
  end)

  describe(':add_parameter_info', function()
    it('reads params from the path', function()
      local api = API:new({}, '/users/*/app/*.xml')
      local o = Operation:new(api, 'GET')

      for i=1,5 do
        o:add_parameter_info('/users/' .. tostring(i) .. '/app/' .. tostring(id) .. '.xml')
      end

      assert.same(o:get_parameter_names(), {'app_id', 'user_id'})

    end)
  end)
end)
