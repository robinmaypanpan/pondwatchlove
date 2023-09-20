-- Returns a value clamped to the low and high values, inclusive
function math.mid(low, val, high)
    local temp = math.max(low, val)
    temp = math.min(temp, high)
    return temp
end

-- Returns -1 for negative numbers and 1 for positive numbers. 0 for 0
function math.sign(number)
    if number > 0 then
        return 1
    elseif number < 0 then
        return -1
    else
        return 0
    end
end

-- Returns the distance between two points
function math.distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end
