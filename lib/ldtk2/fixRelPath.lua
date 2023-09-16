-- TODO: Instead of doing this, which hard codes a particular folder arrangement,
--       instead actually determine the right paths for things

-- Adjust the relative path so it points from the root
function fixRelPath(path)
    local result, _ = string.gsub(path, '%.%./', 'assets/')
    return result
end

return fixRelPath
