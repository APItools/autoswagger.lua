local PATH = (...):match("(.+%.)[^%.]+$") or ""

local base   = require(PATH .. 'base')

local EOL      = base.EOL
local WILDCARD = base.WILDCARD

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

local straux = {
  split = split,
  begins_with = begins_with,
  tokenize = tokenize,
  is_path_equivalent = is_path_equivalent
}

return straux
