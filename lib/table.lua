-- returns the key of the provided target in a table
-- If a function is provided as the target, it is called on each element instead
function table.findKey(tbl, target)
    for key, value in pairs(tbl) do
        if value == target then
            return key
        end
    end

    return nil
end

-- Finds the indicated item in this table and removes it
function table.removeItem(tbl, item)
    local key = table.findKey(tbl, item)
    print('Found key ' .. key)
    table.remove(tbl, key)
end

-- return a reversed version of a table
function table.reverse(tbl)
    local reversedTable = {}
    for i = #tbl, 1, -1 do
        table.insert(reversedTable, tbl[i])
    end

    return reversedTable
end
