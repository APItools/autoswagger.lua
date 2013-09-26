local straux = require 'autoswagger.lib.straux'
local EOL = straux.EOL

describe('straux', function()

  describe('tokenize', function()
    it('parses a regular path', function()
      local t = straux.tokenize

      assert.same({'users', '1', 'app', '1', '.xml', EOL},
         t('/users/1/app/1.xml'))
    end)
  end)

  describe('begins_with', function()
    it('returns whether a string begins with a prefix or not', function()
      assert.is_true(straux.begins_with('banana', 'ban'))
      assert.is_false(straux.begins_with('banana', 'lol'))
    end)
  end)


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
    it('gets an id from a word, singularizing it first', function()
      local make_id = straux.make_id
      assert.same(make_id('friend'), 'friend_id')
      assert.same(make_id('friends'), 'friend_id')
    end)
  end)

  describe('singularize', function()
    it('makes something singular (english only)', function()
      local s = straux.singularize

      assert.same(s('items'), 'item')
      assert.same(s('item'), 'item')
      assert.same(s('news'), 'news')
      assert.same(s('hexes'), 'hex')
      assert.same(s('viri'), 'virus')
      assert.same(s('men'), 'man')
      assert.same(s('women'), 'woman')
      assert.same(s('children'), 'child')
      assert.same(s('kine'), 'cow')
      assert.same(s('people'), 'person')

    end)
  end)
end)
