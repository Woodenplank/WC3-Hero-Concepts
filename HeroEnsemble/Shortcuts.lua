
---@param which_unit unit
---@param which_ability integer
---@param which_level integer
---@param hide boolean
---@return nil
function FastAbilityAdd(which_unit, which_ability, which_level, hide)
    UnitAddAbility(which_unit, FourCC(which_ability))
    SetUnitAbilityLevel(which_unit, FourCC(which_ability), which_level)
    BlzUnitHideAbility(which_unit, FourCC(which_ability), hide)
end