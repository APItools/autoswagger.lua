local Derivator = {}

Derivator.EOL      = "__EOL"
Derivator.WILDCARD = "*"

local WILDCARD = Derivator.WILDCARD
local EOL      = Derivator.EOL

local function choose(array, f)
  local result, length = {}, 0
  for i=1, #array do
    if f(array[i]) then
      length = length + 1
      result[length] = array[i]
    end
  end
  return result
end

local function map(array, f)
  local result, length = {}, 0
  for i=1, #array do
    length = length + 1
    result[length] = f(array[i])
  end
  return result
end

local function includes(array, item)
  for i=1, #array do
    if array[i] == item then return true end
  end
  return false
end

local function append(array, other)
  local i = #array
  for j=1, #other do
    i = i + 1
    array[i] = other[j]
  end
  return array
end

----------------------

local function get_max(t, default)
  local max = default or -math.huge
  for _,v in pairs(t) do
    if v > max then max = v end
  end
  return max
end

local function is_empty(t)
  return next(t) == nil
end

local function merge(t, other)
  for k,v in pairs(other) do
    t[k] = t[k] or v
  end
  return t
end

local function sort(array)
  table.sort(array)
  return array
end

----------------------

local function split(str, delimiter)
  local result = {}
  for chunk in str:gmatch("[^".. delimiter .. "]+") do
    result[#result + 1] = chunk
  end
  return result
end

local function begins_with(str, prefix)
  return str:sub(1, #prefix) == prefix
end

----------------------

local function get_paths_recursive(self, tree, prefix)
  local result = {}
  for node, children in pairs(tree) do
    if node == EOL then
      result[#result + 1] = prefix
    else
      local separator = begins_with(node, '.') and "" or "/"
      append(result, get_paths_recursive(self, children, prefix .. separator .. node))
    end
  end
  return result
end

-- given 'foo/bar/baz.jpg', return {'foo','bar','baz','.jpg', EOL}
local function vectorize(path)
  local words = split(path, "/")

  local last_word, extension_with_dot = words[#words]:match('(.*)(%.[^%.]*)$')
  if last_word then
    words[#words] = last_word
    words[#words + 1] = extension_with_dot
  end

  words[#words + 1] = EOL
  return words
end

local function is_path_equivalent(path1, path2)
  path1 = vectorize(path1)
  path2 = vectorize(path2)

  if #path2 ~= #path1 then return false end

  for i=1, #path1 do
    if path2[i] ~= path2[i] and
       path1[i] ~= WILDCARD and path2[i] ~= WILDCARD then
      return false
    end
  end
  return true
end

----------------------

Derivator.new = function(threshold, unmergeable_words)
  return setmetatable({
    threshold          = threshold         or 1.0,
    unmergeable_words  = unmergeable_words or {},
    histogram          = {},
    spec               = {}
  }, {
    __index = Derivator
  })
end

function Derivator:is_mergeable(word1, word2)
  -- unmergeables
  if includes(self.unmergeable_words, word1) or
     includes(self.unmergeable_words, word2) or
  -- formats
     begins_with(word1, '.') or
     begins_with(word2, '.') then
    return false
  end

  local score1 = self.histogram[word1] or 0
  local score2 = self.histogram[word2] or 0

  local max = get_max(self.histogram, 0)

  if max > 0 then
    score1 = score1 / max
    score2 = score2 / max
  else
    score1 = 0
    score2 = 0
  end

  return score1 <= self.threshold and
         score2 <= self.threshold
end

function Derivator:find_mergeable_sibling(node, current_word, next_word)
  if not next_word then return nil end
  for sibling, nephews in pairs(node) do
    for word,_ in pairs(nephews) do
      if word == next_word and self:is_mergeable(sibling, current_word) then
        return sibling
      end
    end
  end
end

function Derivator:get_paths()
  return sort(get_paths_recursive(self, self.spec, ""))
end

function Derivator:find(path)
  return choose(self:get_paths(), function(x) is_path_equivalent(path, x) end)
end

function Derivator:add(path)
  local vpath     = vectorize(path)
  local node      = self.spec
  local histogram = self.histogram

  for i=1, #vpath do
    local word = vpath[i]
    if word ~= EOL then
      histogram[word] = (histogram[word] or 0) + 1
    end

    if not node[word] then
      local sibling = self:find_mergeable_sibling(node, word, vpath[i+1])

      if sibling then
        if sibling ~= WILDCARD then
          node[WILDCARD] = node[WILDCARD] or {}
          merge(node[WILDCARD], node[sibling])
          node[sibling] = nil
        end
        word = WILDCARD
      else
        node[word] = {}
      end
    end

    node = node[word]
  end
end

return Derivator
