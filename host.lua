local Host = {}

function Host.new(hostname, path_finder)
  return setmetatable({
    hostname    = hostname,
    path_finder = path_finder,
    apis = {}
  }, {
    __index = Host
  })
end

return Host
