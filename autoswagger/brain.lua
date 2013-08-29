local PATH = (...):match("(.+)%.[^%.]+$") or ""

local base   = require(PATH .. '.base')
local array  = require(PATH .. '.array')
local Host   = require(PATH .. '.Host')

local Brain = {}
local Brainmt = {__index = Brain}

local function get_or_create_host(self, hostname)
  self.hosts[hostname] = self.hosts[hostname] or
    Host:new(hostname, self.threshold, self.unmergeable_tokens)
  return self.hosts[hostname]
end

function Brain:new(threshold, unmergeable_tokens)
  return setmetatable({
    threshold          = threshold          or 1.0,
    unmergeable_tokens = unmergeable_tokens or {},
    hosts              = {}
  }, Brainmt)
end

function Brain:get_hostnames()
  local names = {}
  for name,_ in pairs(self.hosts) do names[#names + 1] = name end
  return array.sort(names)
end

function Brain:learn(method, hostname, path, query, body, headers)
  get_or_create_host(self, hostname):learn(method, path, query, body, headers)
end

function Brain:get_swagger(hostname)
  return get_or_create_host(self, hostname):to_swagger()
end

return Brain
