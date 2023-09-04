-- converts a bool to a string
function string.fromBool(value)
    if value then
        return 'true'
    else
        return 'false'
    end
end

-- prints a table to string
function string.fromTable(tbl)
    local string = '{\n'

    for key, value in pairs(tbl) do
        local valueString
        if value == nil then
            valueString = 'nil'
        elseif type(value) == 'boolean' then
            valueString = string.fromBool(value)
        elseif type(value) == 'table' then
            valueString = string.fromTable(value)
        elseif type(value) == 'number' or type(value) == 'string' then
            valueString = value
        else
            valueString = '%%' .. type(value)
        end
        string = '\t' .. string .. key .. ': ' .. valueString .. '\n'
    end

    string = string .. '}'
    return string
end
