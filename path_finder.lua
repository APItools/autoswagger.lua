local PathFinder = {}

PathFinder.EOL      = setmetatable({}, {__tostring = function() return 'EOL' end})
PathFinder.WILDCARD = "*"

local WILDCARD = PathFinder.WILDCARD
local EOL      = PathFinder.EOL

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

local function get_paths_recursive(self, node, prefix)
  local result = {}
  for token, children in pairs(node) do
    if token == EOL then
      result[#result + 1] = prefix
    else
      local separator = begins_with(token, '.') and "" or "/"
      append(result, get_paths_recursive(self, children, prefix .. separator .. token))
    end
  end
  return result
end

-- given 'foo/bar/baz.jpg', return {'foo','bar','baz','.jpg', EOL}
local function tokenize(path)
  local tokens = split(path, "/")

  if #tokens > 0 then
    local last_token, extension_with_dot = tokens[#tokens]:match('(.*)(%.[^%.]*)$')
    if last_token then
      tokens[#tokens] = last_token
      tokens[#tokens + 1] = extension_with_dot
    end
  end

  tokens[#tokens + 1] = EOL
  return tokens
end

local function is_path_equivalent(path1, path2)
  path1 = tokenize(path1)
  path2 = tokenize(path2)

  if #path2 ~= #path1 then return false end

  for i=1, #path1 do
    if path1[i] ~= path2[i] and path1[i] ~= WILDCARD and path2[i] ~= WILDCARD then
      return false
    end
  end
  return true
end

----------------------

local function is_mergeable(self, token1, token2)
  -- unmergeables
  if includes(self.unmergeable_tokens, token1) or
     includes(self.unmergeable_tokens, token2) or
  -- formats
     begins_with(token1, '.') or
     begins_with(token2, '.') then
    return false
  end

  local score1 = self.histogram[token1] or 0
  local score2 = self.histogram[token2] or 0

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

local function find_mergeable_sibling(self, node, current_token, next_token)
  if not next_token then return nil end
  for sibling, nephews in pairs(node) do
    for token,_ in pairs(nephews) do
      if token == next_token and is_mergeable(self, sibling, current_token) then
        return sibling
      end
    end
  end
end

local function get_score(self, path)
  local tokens = tokenize(path)
  local score = 0
  for i=0, #tokens do
    score = score + (self.histogram[tokens[i]] or 0)
  end
  return score
end

local function add_path(self, path)
  local tokens    = tokenize(path)
  local node      = self.root
  local histogram = self.histogram

  for i=1, #tokens do
    local token = tokens[i]
    if token ~= EOL then
      histogram[token] = (histogram[token] or 0) + 1
    end

    if not node[token] then
      local sibling = find_mergeable_sibling(self, node, token, tokens[i+1])

      if sibling then
        if sibling ~= WILDCARD then
          node[WILDCARD] = node[WILDCARD] or {}
          merge(node[WILDCARD], node[sibling])
          node[sibling] = nil
        end
        token = WILDCARD
      else
        node[token] = {}
      end
    end

    node = node[token]
  end
end


----------------------

PathFinder.new = function(threshold, unmergeable_tokens)
  return setmetatable({
    threshold          = threshold          or 1.0,
    unmergeable_tokens = unmergeable_tokens or {},
    histogram          = {},
    root               = {}
  }, {
    __index = PathFinder
  })
end

function PathFinder:get_paths()
  return sort(get_paths_recursive(self, self.root, ""))
end

function PathFinder:match(path)
  return choose(self:get_paths(), function(x) return is_path_equivalent(path, x) end)
end

function PathFinder:learn(path)
  local matches = self:match(path)
  local length = #matches

  if length == 0 then
    add_path(self, path)
    return true
  elseif length == 1 then
    return false
  else -- length > 1 => problem
    local min = math.huge
    local min_path
    for i=1,length do
      local score = get_score(self, matches[i])
      if score < min then
        min = score
        min_path = matches[i]
      end
    end

    self:unlearn(min_path)
    return true
  end
end

function PathFinder:unlearn(path)
  local tokens = tokenize(path)
  local node   = self.root
  local nodes, length  = {}, 0

  for i=1,#tokens do
    length = length + 1
    nodes[length] = node
    node = node[tokens[i]] or node[WILDCARD]
    if not node then return false end
  end

  for i=length, 1, -1 do
    for word,children in pairs(nodes[i]) do
      if is_empty(children) then
        nodes[i][word] = nil
      end
    end
  end

  return true
end

return PathFinder
