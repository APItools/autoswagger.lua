local straux = require 'autoswagger.straux'
local parse_query = straux.parse_query

describe('straux', function()
  describe('parse_query', function()
    it('transforms a query parameter into a lua table', function()
      assert.same(parse_query('foo=x&bar=y&'), {foo='x', bar='y'})
      assert.same(parse_query('foo[]=x&foo[]=y&'), {foo={'x','y'}})
      assert.same(parse_query('foo[bar]=x&foo[zoo]=y'), {foo={bar='x',zoo='y'}})
      assert.same(parse_query('foo=42&&&'), {foo = '42'})
    end)
  end)
end)
