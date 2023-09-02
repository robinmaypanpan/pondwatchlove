-- returns the key of the provided target in a table
-- If a function is provided as the target, it is called on each element instead
function table.findKey(tbl, target)
    local test = target
    if type(target) ~= "function" then
        test = function(value) return value == test end
    end

    for key, value in pairs(tbl) do
        if test(value) then
            return key
        end
    end

    return nil
end
