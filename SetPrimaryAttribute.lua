--[[Since WC3:Reforged is a technological masterpiece without bugs or half-assed releases,
    this native DOES NOT WORK for Agility. Neither when switch to AGI, or away from it.
    e.g. Paladin or Archmage can't be made AGI primary, Blademaster can't be made STR or INT.]]
---@param u unit
---@param which string
---@return boolean
function SetPrimary(u, which)
    -- early return if the unit is not a Hero
    if not IsUnitType(u, UNIT_TYPE_HERO) then
        return false
    end

    which = string.lower(which)
    if which=="str" then
        BlzSetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE, 0) -- bj_HEROSTAT_STR = 0
        return true
    elseif which=="int" then
        BlzSetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE, 2) -- bj_HEROSTAT_INT = 2
        return true
    elseif which=="agi" then
        BlzSetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE, 1) -- bj_HEROSTAT_AGI = 1
        BlzSetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE, 3) --?
        return false
    else
        print("Unrecognized input to SetPrimary, expected \"str\", \"int\", or \"agi\", but got "..tostring(which))
        return false
    end
end