do
    --[[
        The buff ability added by usage of Sinhammer.
        it is used in his other abilities when determining whether that buff is active.
        If the Hellion has the buff ability, then they receive appropiate "Spell Damage/Spell Vamp"
            Declared globally here, for the many abilities that refer to it.
    ]]
    SHbuff_abilId = FourCC('A00L')
    

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
        return true, (1+GetAbilityField(FourCC('A00K'), "aoe", which_level)), GetAbilityField(FourCC('A00K'), "herodur", which_level)
    end

    --[[
            Hellforge settings
    ]]
    
    -- Redundancy in table entries; in case someone forgets whether to use upg name or ability name
    HellforgedSpells = {
        ["ArmsOfAstaroth"] = FourCC('A00O'),
        ["Charge"] = FourCC('A00O'),
        ["BelialsInsights"] = FourCC('A00Q'),
        ["Hellgate"] = FourCC('A00Q'),
        ["SevenTongues"] = FourCC('A00P'),
        ["SevenTonguesOfPytho"] = FourCC('A00P'),
        ["SevenTonguesOfFlame"] = FourCC('A00P'),
        ["CrownOfTheNineKingdoms"] = nil
    }
    HellforgedResearches = {
        ["ArmsOfAstaroth"] = FourCC('A00R'),
        ["BelialsInsights"] = FourCC('A00S'),
        ["SevenTonguesOfPytho"] = FourCC('A00T'),
        ["CrownOfTheNineKingdoms"] = FourCC('A00U')
    }


    HellforgeEnabler_Qtype=FourCC('h008')
    HellforgeEnabler_Wtype=FourCC('h007')
    HellforgeEnabler_Etype=FourCC('h006')
    HellforgeEnabler_Rtype=FourCC('h009')



end