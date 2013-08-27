local array = require 'autoswagger.array'

describe('array', function()
  describe('.untokenize', function()
    it('joins an array of tokens into a path', function()
      local EOL = {}
      local tokens = {'foo', 'bar', '.jpg', EOL}
      local str = array.untokenize(tokens)

      assert.equals(str, '/foo/bar.jpg')
    end)
  end)
end)
