function UnitTypeCheck(which_unit, which_type)
    return GetUnitTypeId(which_unit) == FourCC(which_type)
end