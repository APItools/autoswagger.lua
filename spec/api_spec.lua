local as = require 'autoswagger'

local API = require 'autoswagger.API'

describe('API', function()
  it('can be created', function()
    local api = API.new('/foo/bar')
    assert.equal(api.endpoint, '/foo/bar')
  end)

  describe('parse_path_params', function()
    it('returns swagger parameter specs for a given path', function()
      local a = API.new('/api/accounts/*/applications/*.xml')
      local params = a:parse_path_params("/api/accounts/42/applications/13.xml")
      assert.same(params, {accounts_id='42', applications_id='13'})
    end)
  end)
end)
