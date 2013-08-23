local base   = {
  EOL = setmetatable({}, {__tostring = function() return 'EOL' end}),
  WILDCARD = "*"
}

return base
