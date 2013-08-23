local array = {

  choose = function(arr, f)
    local result, length = {}, 0
    for i=1, #arr do
      if f(arr[i]) then
        length = length + 1
        result[length] = arr[i]
      end
    end
    return result
  end,

  includes = function(arr, item)
    for i=1, #arr do
      if arr[i] == item then return true end
    end
    return false
  end,

  append = function(arr, other)
    local i = #arr
    for j=1, #other do
      i = i + 1
      arr[i] = other[j]
    end
    return arr
  end,

  sort = function(arr)
    table.sort(arr)
    return arr
  end
}

return array
