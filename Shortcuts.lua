---@param which_unit unit
---@param which_ability integer | FourCC string
---@param which_level integer
---@param hide boolean
---@return nil
function FastAbilityAdd(which_unit, which_ability, which_level, hide)
    if not type(which_ability) == "number" then
        which_ability = FourCC(which_ability)
    end
    UnitAddAbility(which_unit, which_ability)
    SetUnitAbilityLevel(which_unit, which_ability, which_level)
    BlzUnitHideAbility(which_unit, which_ability, hide)
end

---@param which_unit unit
---@param which_type string
---@return boolean
function UnitTypeCheck(which_unit, which_type)
    if type(which_type) == "number" then
        return GetUnitTypeId(which_unit) == which_type
    else
        return GetUnitTypeId(which_unit) == FourCC(which_type)
    end
    -- safe return
    return false
end

---@param which_unit unit
---@return integer
function GetUnitAvgAttackDamage(which_unit)
    -- does not account for item bonuses (yet...)
    return math.tointeger(BlzGetUnitBaseDamage(which_unit) + (BlzGetUnitDiceNumber(which_unit)*BlzGetUnitDiceSides(which_unit))/2)
end


---@param num number
---@return string
function N2S(num)
    if type(num) == "integer" then
        return string.format("%d", num)
    else
        return string.format("%.2f", num)
    end
end
