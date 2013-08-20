local derivator = {}

derivator.occurrences_threshold = 1.0
derivator.unmergeable_words = {}
derivator.EOL = "EOL"
derivator.WILDCARD = "*"
derivator.histogram = {}

local EOL = derivator.EOL
local histogram = derivator.histogram
local WILDCARD = derivator.WILDCARD

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

local function get_max(t, default)
  local max = default or -math.huge
  for _,v in pairs(t) do
    if v > max then max = v end
  end
  return max
end

local function split(str, delimiter)
  local result = {}
  for chunk in str:gmatch("[^".. delimiter .. "]+") do
    result[#result + 1] = chunk
  end
  return result
end

local function begins_with(str, prefix)
  return str:sub(1,1) == prefix
end

----------------------

derivator.is_mergeable = function(word1, word2)

  -- unmergeables
  if includes(derivator.unmergeable_words, word1) or
     includes(derivator.unmergeable_words, word2) or
  -- formats
     begins_with(word1, '.') or
     begins_with(world2, '.') then
    return false
  end

  local score1 = derivator.histogram[word1] or 0
  local score2 = derivator.histogram[word2] or 0

  local max = get_max(values, 0)

  if max > 0 then
    score1 = score1 / max
    score2 = score2 / max
  else
    score1 = 0
    score2 = 0
  end

  return score1 <= derivator.occurrences_threshold and
         score2 <= derivator.occurrences_threshold
end

derivator.paths = function(tree, prefix)
  return derivator.paths_recur(tree, prefix or "")
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
  return choose(paths, function(x) is_path_equivalent(path, x) end)
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
