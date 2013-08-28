local PATH = (...):match("(.+%.)[^%.]+$") or ""

local base      = require(PATH .. 'autoswagger.base')
local Brain     = require(PATH .. 'autoswagger.brain')
local Host      = require(PATH .. 'autoswagger.host')
local API       = require(PATH .. 'autoswagger.api')
local Parameter = require(PATH .. 'autoswagger.parameter')

return {
  EOL     = base.EOL,
  Brain  = Brain,
  Host    = Host,
  API     = API,
  Param   = Parameter
}


