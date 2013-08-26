local straux = require 'autoswagger.straux'

describe('straux', function()
  describe('parse_query', function()
    it('transforms a query parameter into a lua table', function()
      local parse_query = straux.parse_query
      assert.same(parse_query('foo=x&bar=y&'), {foo='x', bar='y'})
      assert.same(parse_query('foo[]=x&foo[]=y&'), {foo={'x','y'}})
      assert.same(parse_query('foo[bar]=x&foo[zoo]=y'), {foo={bar='x',zoo='y'}})
      assert.same(parse_query('foo=42&&&'), {foo = '42'})
    end)
  end)

  describe('make_id', function()
    it('gets an id from a word', function()
      local make_id = straux.make_id
      assert.same(make_id('friend'), 'friend_id')
      assert.same(make_id('friends'), 'friends_id')
    end)
  end)
end)
