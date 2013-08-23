local PATH = (...):match("(.+%.)[^%.]+$") or ""

local base   = require(PATH .. 'autoswagger.base')
local Parser = require(PATH .. 'autoswagger.parser')

return {
  EOL    = base.EOL,
  Parser = Parser
}


