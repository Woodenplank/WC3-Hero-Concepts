do
    --[[
        The buff ability added by usage of Sinhammer.
        it is used in his other abilities when determining whether that buff is active.
        If the Hellion has the buff ability, then they receive appropiate "Spell Damage/Spell Vamp"
            Declared globally here, for the many abilities that refer to it.
    ]]
    SHbuff_abilID = FourCC('A00L')
    

    ---@param which_level integer
    ---@return boolean float float
    function GetSinhammerMod(which_level)
        if type(which_level) ~= "number" or which_level ~= math.floor(which_level) then
            return false, nil, nil
        end
        if which_level<=0 then
            return false, nil, nil
        end
        -- "area" encodes Damage bonus
        -- "herodur" encodes Healing bonus
        return true, GetAbilityField(FourCC('A00K'), "aoe", alv), GetAbilityField(FourCC('A00K'), "herodur", alv)
    end

    --[[
            Hellforge setting
    ]]
    

end