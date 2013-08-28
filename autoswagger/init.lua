local PATH = (...):match("(.+%.)[^%.]+$") or ""

local Brain     = require(PATH .. 'brain')

return {
  Brain   = Brain,
}
