local PATH = (...):match("(.+)%.[^%.]+$") or ""

local base   = require(PATH .. '.base')
local array  = require(PATH .. '.array')
local Host   = require(PATH .. '.Host')

local Parser = {}

Parser.new = function(threshold, unmergeable_tokens)
  return setmetatable({
    threshold          = threshold          or 1.0,
    unmergeable_tokens = unmergeable_tokens or {},
    hosts = {}
  }, {
    __index = Parser
  })
end

function Parser:newHost(hostname)
  self.hosts[hostname] = self.hosts[hostname] or
    Host.new(hostname, self.threshold, self.unmergeable_tokens)
  return self.hosts[hostname]
end

function Parser:get_paths(hostname)
  local host = self.hosts[hostname]
  return host and host:get_paths() or {}
end

function Parser:learn(hostname, path)
  self:newHost(hostname):learn(path)
end

return Parser