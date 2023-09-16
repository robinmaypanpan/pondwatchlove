-- Processes a number of field instances to produce fields
function getFields(data)
    local fields = {}

    if data and data.fieldInstances then
        for _, field in pairs(data.fieldInstances) do
            fields[field.__identifier] = field.__value
        end
    end
    return fields
end

return getFields
