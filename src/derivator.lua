local derivator = {}

derivator.occurrences_threshold = 1.0
derivator.unmergeable_words = {}
derivator.EOL = "EOL"
derivator.WILDCARD = "*"
derivator.histogram = {}

local EOL = derivator.EOL
local histogram = derivator.histogram
local WILDCARD = derivator.WILDCARD

local function keep_if(t, fun)
  local res = {}
  for _,v in ipairs(t) do
    if fun(v) then res[#res + 1] = v end
  end
  return res
end

local function map(t, fun)
  local res = {}
  for _,v in ipairs(t) do
    table.insert(res, fun(v))
  end
  return res
end

local function split(str, delimiter)
  local result = {}
  for chunk in str:gmatch("[^".. delimiter .. "]+") do
    result[#result + 1] = chunk
  end
  return result
end

local function includes(self, item)
  for i=1, #self do
    if self[i] == item then return true end
  end
  return false
end

----------------------

derivator.is_mergeable = function(word1, word2)

  -- unmergeables
  if includes(derivator.unmergeable_words, word1) or
     includes(derivator.unmergeable_words, word2) then
    return false
  end

  -- formats
  if word1:sub(1,1) == '.' or
    word2:sub(1,1) == '.' then
    return false
  end

  local score1 = derivator.hist[word1] or 0
  local score2 = derivator.hist[word2] or 0

  local max = 0
  for _,v in(derivator.hist) do
    if v>max then
      max = v
    end
  end

  if max > 0 then
    score1 = score1 / max
    score2 = score2 / max
  else
    score1 = 0
    score2 = 0
  end

  if score1 <= derivator.occurrences_threshold and
    score_2 <= derivator.occurrences_threshold then
    return true
  else
    return false
  end
end

derivator.paths = function(tree, prefix)
  prefix = prefix or ""
  return derivator.paths_recur(tree, prefix)
end

derivator.paths_recur = function(tree, prefix)
  res = {}
  for k, v in pairs(tree) do
    if k == EOL then
      res[#res] = v
    elseif k:sub(1,1) == '.' then
      res[#res] = derivator.paths_recur(v, "#{str}#{node}")
    else
      res[#res] = derivator.paths_recur(v, "#{str}/#{node}")
    end
  end
  return res
end

derivator.vectorize = function(path)
  local s = split(path, "/")
  if #s == 0 then return nil end
  local vectorized = s[#s]:match('(.*)(%.[^%.]*)$')
  table.insert(vectorized, EOL)
  return vectorized
end

-- derivator.does_exist_in_spec(path, spec) = function(path, spec)
--    local vectorized = derivator.path(path)

--                                            end

derivator.clashes = function(tree_spec)
  local res = {}
  local all_paths = derivator.paths(tree_spec, prefix)
  for _,v1 in ipairs(all_paths) do
    for _, v2 in ipairs(all_paths) do
      if v1 ~= v2 and is_path_equivalent(v1, v2) then -- not equal but equivalent
        res[v1] = table.insert((res[v1] or {}), v2)
      end
    end
  end
end

derivator.is_path_equivalent = function(path1, path2)
  local path1 = vectorize(path1)
  local path2 = vectorize(path2)

  if #path2 ~= #path1 then return false end

  for i, _ in ipairs(path1) do
    if path1[i] == path2[i] or path1[i] == WILDCARD or path2[i] == WILDCARD  then
      -- ok, pass to the next one
    else
      return false
    end
  end
  return true
end

derivator.find = function(paths, path)
  return keep_if(paths, function(x) is_path_equivalent(path, x) end)
end

derivator.add = function(tree_spec, path)
  local vpath = vectorize(path)
  for i, item in ipairs(vpath) do
    if i < #size then
      histogram[item] = (histogram[item] or 0) +1
    end

    if not tree_spec[item] then
      if #tree_spec == 0 then
        tree_spec[item] = {}
      else

      end
    end


  end
end

derivator.remove = function(path, tree)
  local vpath = vectorize(path)
  local res = {}
  for i, v in ipairs(vpath) do
    tree = tree[v] or tree[WILDCARD]
  end

  for _, v  in ipairs(res) do
  end

  return derivator
