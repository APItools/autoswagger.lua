local Endpoint = require 'autoswagger.endpoint'

describe('Endpoint', function()
  it('can be created', function()
    local endpoint = Endpoint.new('/foo/bar')
    assert.equal(endpoint.endpoint, '/foo/bar')
  end)

  describe('parse_path_params', function()
    it('returns swagger parameter specs for a given path', function()
      local a = Endpoint.new('/endpoint/accounts/*/applications/*.xml')
      local params = a:parse_path_params("/endpoint/accounts/42/applications/13.xml")
      assert.same(params, {accounts_id='42', applications_id='13'})
    end)
  end)

  describe('add_parameter_info', function()
    it('adds parameter info to the endpoint', function()
      -- empty
    end)
  end)
end)

