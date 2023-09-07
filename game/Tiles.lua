local Empty = 0
local Ground = 1
local Beach = 2
local Water = 3
local Vine = 4

-- Returns true if the tile is a wall
function isImpassable(tile)
    return tile.value == Ground or tile.value == Beach
end

function isClimbable(tile)
    return tile.value == Vine
end

function isEmpty(tile)
    return tile.value == Empty or tile.value == Water or tile.value == -1
end

return {
    Ground = Ground,
    Beach = Beach,
    Water = Water,
    Vine = Vine,
    isImpassable = isImpassable,
    isClimbable = isClimbable,
    isEmpty = isEmpty
}
