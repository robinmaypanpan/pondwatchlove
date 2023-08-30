local exports = {}

-- Returns a value clamped to the low and high values, inclusive
function exports:mid(low, val, high)
    local temp = math.max(low, val)
    temp = math.min(temp, high)
    return temp
end

return exports