local PATH = (...):match("(.+%.)[^%.]+$") or ""

local base      = require(PATH .. 'autoswagger.base')
local Parser    = require(PATH .. 'autoswagger.parser')
local Host      = require(PATH .. 'autoswagger.host')
local API       = require(PATH .. 'autoswagger.api')
local Parameter = require(PATH .. 'autoswagger.parameter')

return {
  EOL     = base.EOL,
  Parser  = Parser,
  Host    = Host,
  API     = API,
  Param   = Parameter
}


