-- converts a bool to a string
function string.fromBool(value)
    if value then
        return 'true'
    else
        return 'false'
    end
end
