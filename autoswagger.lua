local PATH = (...):match("(.+%.)[^%.]+$") or ""

local base   = require(PATH .. 'autoswagger.base')
local Parser = require(PATH .. 'autoswagger.parser')
local Host   = require(PATH .. 'autoswagger.host')
local API    = require(PATH .. 'autoswagger.api')

return {
  EOL    = base.EOL,
  Parser = Parser,
  Host   = Host,
  API    = API
}


