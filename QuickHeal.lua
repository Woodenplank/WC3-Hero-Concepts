--[[
    Quick function for healing a unit.
    Faster than GUI, because this only calls GetUnitState once
]]

---@param target unit
---@param heal float
function QuickHealUnit(target, heal)
    local hp = GetUnitState(target, UNIT_STATE_LIFE)
    SetUnitState(target, UNIT_STATE_LIFE, hp+heal)
end

---@param target unit
---@param restore float
function QuickManaRestore(target, restore)
    local fp = GetUnitState(target, UNIT_STATE_MANA)
    SetUnitState(target, UNIT_STATE_MANA, fp+restore)
end

--[[
    Alternate function

        Returns FALSE if no healing was done (unit already at max)
        Returns TRUE otherwise.
    
    Use this alternative if you have to know whether healing actually took place.
]]

---@param target unit
---@param heal real
---@return boolean
function HealUnit(target, heal)
    local hp = GetUnitState(target, UNIT_STATE_LIFE)
    local maxhp = GetUnitState(target, UNIT_STATE_MAX_LIFE )
    if (hp >= maxhp)
    then
        return false
    else
        SetUnitState(target, UNIT_STATE_LIFE, hp+heal)
    end
    return true
end