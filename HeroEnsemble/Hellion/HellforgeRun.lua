do
    -- This relies on HellionGlobal and HellforgeSetup.
    -- Technically, this could point to a nil unit group if called within 0.01 seconds of elapsed game time
    -- TOO BAD!

    --[[ Note on IsUnitIdType
        It fucking sucks
    ]]

    local function Hellforge_CastAbility()
        -- Fetch Hellforge properties
        local Hf = GetTriggerUnit()
        local owner = GetOwningPlayer(Hf)

        -- Exit early if not Hellforge
        if ( GetUnitTypeId(Hf) ~= FourCC('h005') ) then
            return
        end

        -- Fetch the Hellion unit
        -- This assumes ONLY ONE Hellion per player
        local cond = Condition(function() return
            GetUnitTypeId(GetFilterUnit()) == FourCC('O001')
		end)
        local ug = CreateGroup()
        GroupEnumUnitsOfPlayer(ug, owner, cond)
        local Hellion = FirstOfGroup(ug)
        
        -- Clear all current research units
        ForGroup(HellforgeResearchBlockers, function()
            local pu = GetEnumUnit()
            RemoveUnit(pu)
        end)

        -- Remove all current Hellforged abilities
        UnitRemoveAbility(Hellion, HellforgedSpells["ArmsOfAstaroth"])
        UnitRemoveAbility(Hellion, HellforgedSpells["BelialsInsights"])
        UnitRemoveAbility(Hellion, HellforgedSpells["SevenTonguesOfPytho"])
        --UnitRemoveAbility(Hellion, HellforgedSpells["CrownOfTheNineKingdoms"])

        -- Setup for newly activated researched
        -- TODO This should probably be looping through a table... Somehow.
        local abilId = GetSpellAbilityId()
        if abilId == HellforgedResearches["ArmsOfAstaroth"] then
            UnitAddAbility(Hellion, HellforgedSpells["ArmsOfAstaroth"])
            -- Reestablish other research units
            local temp = CreateUnit(owner, HellforgeEnabler_Wtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Etype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Rtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
        elseif abilId == HellforgedResearches["BelialsInsights"] then
            UnitAddAbility(Hellion, HellforgedSpells["BelialsInsights"])
            -- Reestablish other research units
            local temp = CreateUnit(owner, HellforgeEnabler_Qtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Etype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Rtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
        elseif abilId == HellforgedResearches["SevenTonguesOfPytho"] then
            UnitAddAbility(Hellion, HellforgedSpells["SevenTonguesOfPytho"])
            -- Reestablish other research units
            local temp = CreateUnit(owner, HellforgeEnabler_Qtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Wtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Rtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
        elseif abilId == HellforgedResearches["CrownOfTheNineKingdoms"] then
            UnitAddAbility(Hellion, HellforgedSpells["CrownOfTheNineKingdoms"])
            -- Reestablish other research units
            local temp = CreateUnit(owner, HellforgeEnabler_Qtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Wtype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
            temp = CreateUnit(owner, HellforgeEnabler_Etype, 0, 0, 270)
            GroupAddUnit(HellforgeResearchBlockers, temp)
        end

        -- Clean memory
        DestroyGroup(ug)
        DestroyCondition(cond)

        -- END --
    end
    
    -- Build Trigger --
    local function CreateHellforgeTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, Hellforge_CastAbility)
    end
    OnInit.final(CreateHellforgeTrig)
end