---@param x number
---@param y number
---@return number
function AngleBetweenCoords(x1, x2, y1, y2)
    -- value is returned in radians
    return Atan2(y2 - y1, x2 - x1)
end