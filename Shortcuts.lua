-------------------------------------- unit attributes --------------------------------------

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


------------------------------------- effects -----------------------------------

-- see: https://www.hiveworkshop.com/attachments/lightninglist-png.116282/
lightning_names = {
    ["Chain Lightning Primary"]  = "CLPB"
    ["Chain Lightning Secondary"]  = "CLSB",
    ["Drain"]  = "DRAB",
    ["Drain Life"]  = "DRAL",
    ["Drain Mana"]  = "DRAM",
    ["Finger of Death"]  = "AFOD",
    ["Forked Lighting"]  = "FORK",
    ["Healing Wave Primary"]  = "HWPB",
    ["Healing Wave Secondary"]  = "HWSB",
    ["Lightning Attack"]  = "CHIM",
    ["Magic Leash"]  = "LEAS", --[[GUI: Aerial Shackles]]
    ["Mana Burn"]  = "MBUR",
    ["Mana Flare"]  = "MFPB",
    ["Spirit Link"]  = "SPLK"
}
---@param explicit_name string
---@param checkVisibility boolean
function AddLightningEffect(explicit_name, checkVisibility, x1, y1, z1, x2, y2, z2)
     --[[ If checkVisibility is true, the lightning won't be created and the function will return null 
        unless the local player currently has visibility of at
        least one of the endpoints of the to be created lightning.) ]]
    return AddLightningEx(lightning_names[explicit_name], checkVisibility, x1, y1, z1, x2, y2, z2)
end



-------------------------------------- map --------------------------------------

---@param x number
---@param y number
---@return boolean
function IsTerrainWalkable(x, y)
    --[[ from common.1.33.v2.lua : 
        PATHING_TYPE_ANY = ConvertPathingType(0)	        ---@type pathingtype
        PATHING_TYPE_WALKABILITY = ConvertPathingType(1)	---@type pathingtype
        PATHING_TYPE_FLYABILITY = ConvertPathingType(2)	    ---@type pathingtype
        PATHING_TYPE_BUILDABILITY = ConvertPathingType(3)	---@type pathingtype
        PATHING_TYPE_PEONHARVESTPATHING = ConvertPathingType(4)	---@type pathingtype
        PATHING_TYPE_BLIGHTPATHING = ConvertPathingType(5)	---@type pathingtype
        PATHING_TYPE_FLOATABILITY = ConvertPathingType(6)	---@type pathingtype
        PATHING_TYPE_AMPHIBIOUSPATHING = ConvertPathingType(7)	---@type pathingtype
    ]]

    -- IsTerrainPathable()
    -- Returns TRUE if the pathingtype is _not_ set, FALSE if it _is_ set.
    return (not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) )
end


-------------------------------------- strings and text output --------------------------------------

---@param num number
---@return string
function N2S(num)
    if type(num) == "integer" then
        return string.format("%d", num)
    else
        return string.format("%.2f", num)
    end
end
