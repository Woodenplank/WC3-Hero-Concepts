--[[
    Uses Hero Intelligence as an "ability power" stat.
    Used for adding additional damage to triggered damage.
]]

---@param hero unit
---@param scale number
---@return number
function addSP(hero, scale)
    return (GetHeroInt(hero, true) * scale)
end
