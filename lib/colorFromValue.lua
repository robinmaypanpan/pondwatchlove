function colorFromValue(str)
    local str = str:gsub('#', '') -- get rid of hex prefix if it exists
    local val = tonumber(str, 16) -- base 16 number conversion
    -- from here, same as above
    local bit = require('bit')
    local r = bit.rshift(bit.band(val, 0xff0000), 16) / 255
    local g = bit.rshift(bit.band(val, 0xff00), 8) / 255
    local b = bit.band(val, 0xff) / 255
    return r, g, b
end

return colorFromValue
