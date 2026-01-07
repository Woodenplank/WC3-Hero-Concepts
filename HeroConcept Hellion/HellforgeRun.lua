do
    -- This relies on HellionGlobal and HellforgeSetup.
    -- Technically, this could point to a nil unit group if called within 0.01 seconds of elapsed game time
    -- TOO BAD!

    local function Hellforge_CastAbility()
        -- Fetch Hellforge properties
        local Hf = GetTriggerUnit()
        local owner = GetOwningPlayer(Hf)

        -- Exit early if not Hellforge
        if UnitTypeCheck(Hf, Hellforge_utype) then
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
        for k,v in ipairs(HellforgedSpells) do
            UnitRemoveAbility(Hellion, v)
        end

        --[[ Adds appropiate new ability to the Hellion and reestablish other research units
        -- it is critical that the researches, spells, and blocker-unit-type tables all use the same keys!
        -- See ObjectConstants.lua
        ]]
        local abilId = GetSpellAbilityId()
        for key,val in HellforgedResearches do
            if abilId == val then
                UnitAddAbility(Hellion, HellforgedSpells[key])
                for idx,utype in ipairs(Hellforge_blockerstacks) do
                    if utype ~= Hellforge_blockerstacks[key] then
                        local temp = CreateUnit(owner, utype, 0, 0, 270)
                        GroupAddUnit(HellforgeResearchBlockers, temp)
                    end
                end
            end
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