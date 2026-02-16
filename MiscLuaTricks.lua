Array = {
    length = 0,
    array = {}
}
mt = {
    __index = function(tab, index)
        return tab.array[index]
    end
}
setmetatable(t, mt)
-- with this, Array[3] will effectively call Array.array[3]


--[[
    Returns true if every value in a table is true
    otherwise false
]]
---@param tab table
---@return bool
function every(tab)
    for _,b in pairs(tab) do
        if b==false then return false end
    end
    return true
end