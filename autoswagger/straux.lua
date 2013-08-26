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

local function decode_char(c)
  return string.char(tonumber(c, 16))
end

local function decode(str)
  return str:gsub('+', ' '):gsub("%%(%x%x)", decode_char)
end

-- inspired by https://github.com/golgote/neturl/blob/master/lib/net/url.lua
local function parse_query(str)
  str = str or {}
  local result = {}
  local keys

  for key,val in str:gmatch('([^&=]+)(=*[^&=]*)') do

    val = val:gsub('^=+', "")

    keys = {}
    key = decode(key):gsub('%[([^%]]*)%]', function(v)
      v = v:find("^-?%d+$") and tonumber(v) or decode(v)
      keys[#keys + 1] = v
      return "="
    end):gsub('=+.*$', ""):gsub('%s', "_")

    if #keys > 0 then
      result[key] = type(result[key]) == 'table' and result[key] or {}
      local t = result[key]
      for i,k in ipairs(keys) do
        t = type(t) == 'table' and t or {}

        if k == ""    then k = #t+1 end
        if not t[k]   then t[k] = {} end
        if i == #keys then t[k] = decode(val) end

        t = t[k]
      end
    else
      result[key] = decode(val)
    end

  end

  return result
end

local straux = {
  split               = split,
  begins_with         = begins_with,
  tokenize            = tokenize,
  is_path_equivalent  = is_path_equivalent,
  parse_query         = parse_query
}

return straux
