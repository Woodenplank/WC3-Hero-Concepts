-- requires SpellTemplate.lua
do
    -- =========================================== Hellion Object Editor Constants ===========================================
    HEL_id_hfstrike     =   FourCC("A00I")
    HEL_id_charge       =   FourCC('A00O')
    HEL_id_domsin       =   FourCC('A00N')
    HEL_id_domsinbuff   =   FourCC('S000')
    HEL_id_emberstorm   =   FourCC("A00M")
    HEL_id_hellgate     =   FourCC("A00Q")
    HEL_id_flametongues =   FourCC('A00P')
    HEL_id_sinham       =   FourCC("A00K")
    HEL_id_sinhambuff   =   FourCC('A00L')
    HEL_id_sinhamattributes=FourCC('A00V')

    HEL_hfstrikeSpell   =Spell:Create("A00I","unit")
    HEL_chargeSpell     =Spell:Create("A00O","point")
    HEL_domainSpell     =Spell:Create("A00N","instant")
    HEL_domainbuff      =FourCC("S000")
    HEL_emberID         =FourCC("A00M") -- not based on Channel, but Bladestorm
    HEL_emberSpell      =Spell:Create("A00M","instant")
    HEL_hellgateSpell   =Spell:Create("A00Q","point")
    HEL_ftonguesSpell   =Spell:Create("A00P","instant")
    HEL_sinhammerSpell  =Spell:Create("A00K","instant")
    HEL_sinhammerbuff   =FourCC("A00L")
    HEL_sinhammerattrib =FourCC("A00V")


    -- Unit Type
    utype_Hellion       = FourCC('O001') -- the actual hero unit
    utype_FlameTornado  = FourCC('e001')
    utype_PentagramDummy= FourCC('e002')
    Hellforge_utype     = FourCC('h005')


    -- Hellion Hellforge settings
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

    Hellforge_utype     =   FourCC('h005')
    Hellforge_QEnabler  =   FourCC('h008')
    Hellforge_WEnabler  =   FourCC('h007')
    Hellforge_EEnabler  =   FourCC('h006')
    Hellforge_REnabler  =   FourCC('h009')

    Hellforge_blockerstacks = {
        ["ArmsOfAstaroth"] = Hellforge_QEnabler,
        ["BelialsInsights"] = Hellforge_WEnabler,
        ["SevenTonguesOfPytho"] = Hellforge_EEnabler,
        ["CrownOfTheNineKingdoms"] = Hellforge_REnabler
    }


    -- =========================================== Hellforge Setup & Settings ===========================================
    
    -- Link each Hellforge unit with a Hellion hero.
    HEL_forgelinks = {}
    local function SetupResearchUnits()
        HFresearchBlockers = CreateGroup()
        for _,utype in pairs(Hellforge_blockerstacks) do            
            local temp = CreateUnit(Player(0), utype, 0, 0, 270) -- note that this should be done for every Player() with a Hellion
            GroupAddUnit(HFresearchBlockers, temp)
        end

        -- TODO: initialization of the HeroHandle and ForgeHandle. These should be UnitIDs generated as soon as possible.
        -- The actual implementation will vary by map. It should be when the Hellion hero is "picked" by a Player.

        -- ---------------------------- Testing solution --------------------------------
        local hero=nil
        local id_forge=nil

        local ug = CreateGroup()
        GroupEnumUnitsOfPlayer(ug, Player(0), nil)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            if (GetUnitTypeId(pu) == utype_Hellion) then
                hero = pu
            elseif GetUnitTypeId(pu) == Hellforge_utype then
                id_forge = GetHandleId(pu)
            end
        end)
        DestroyGroup(ug)
        -----------------------------------------------------------------------------------
        table.insert(HEL_forgelinks, {["herohandle"] = hero, ["forgehandle"] = id_forge, ["grouphandle"] = HFresearchBlockers})
        print("Setup successful")
    end

    -- Build Trigger --
    local function CreateSetupTrig()
        local tr = CreateTrigger()
        TriggerRegisterPlayerEventEndCinematic(tr, Player(0)) -- player 1 (Red) presses "ESC"
        TriggerAddAction(tr, SetupResearchUnits)
    end
    OnInit.final(CreateSetupTrig)


    -- =========================================== Hellion Global Function(s) ===========================================
    --[[
        The buff ability is added by usage of Sinhammer.
        it is used in his other abilities when determining whether that buff is active.
        If the Hellion has the buff ability, then they receive appropiate "Spell Damage/Spell Vamp"
            Declared globally here, for the many abilities that refer to it.
    ]]

    ---@param caster unit
    ---@return boolean, float, float
    function GetSinhammerMod(caster)
        local which_level = GetUnitAbilityLevel(caster, HEL_sinhammerbuff)
        if (which_level==nil) or (which_level<=0) then
            return false, nil, nil
        end
        
        local dmgbonus = (1+GetAbilityField(HEL_id_sinham, "aoe", which_level)) -- "area" encodes Damage bonus
        local healbonus= GetAbilityField(HEL_id_sinham, "herodur", which_level) -- "herodur" encodes Healing bonus
        return true, dmgbonus, healbonus
    end

end