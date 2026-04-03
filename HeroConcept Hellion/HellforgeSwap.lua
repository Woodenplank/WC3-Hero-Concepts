-- requires HellionGlobal.lua
do
    local function Hellforge_ability()
        local Hf = GetTriggerUnit()
        -- Exit early if not Hellforge
        if GetUnitTypeId(Hf) ~= Hellforge_utype then
            return
        end

        -- fetch the ability key
        local abilkey = GetSpellAbilityId()
        if (abilkey == HellforgedSpells["Arms of Astaroth"]) then 
            abilkey = "Arms of Astaroth"
        elseif (abilkey == HellforgedSpells["Belial's Insights"]) then
            abilkey = "Belial's Insights"
        elseif (abilkey == HellforgedSpells["SevenTonguesOfPytho"]) then
            abilkey = "Belial's Insights"
        elseif (abilkey == HellforgedSpells["CrownOfTheNineKingdoms"]) then
            abilkey = nil -- TODO: this has no effect/spell yet!
        else
            abilkey = nil
        end
        -- note that the researches, spells, and blocker-unit-type tables all use the same keys!


        -- HEL_forgelinks is a table-of-tables, structured as
        -- {"herohandle" = hero, "forgeid" = id_forge, "grouphandle" = HFresearchBlockers}
        local forge_id = GetUnitHandle(Hf)
        local which_group = nil
        local which_hellion = nil
        for _,tab in pairs(HEL_forgelinks) do
            if tab["forgehandle"] == forge_id then
                which_group = tab["grouphandle"]
                which_hellion = tab["herohandle"]
                break
            end
        end

        -- Clear all current research units for this Hellion
        -- then reenable the other Hellforge options again
        ForGroup(which_group, function()
            RemoveUnit(GetEnumUnit())
        end)
        local Hf_player = GetOwningPlayer(Hf)       
        for key,unit_type in pairs(Hellforge_blockerstacks) do
            if key~=abilkey then 
                local temp = CreateUnit(owner, utype, 0, 0, 270)
                GroupAddUnit(which_group, temp)
            end
        end
        
        -- Remove all current Hellforged abilities
        -- then add the selected option back to the Hellion
        for k,v in pairs(HellforgedSpells) do
            UnitRemoveAbility(which_hellion, v)
        end        
        UnitAddAbility(which_hellion, HellforgedSpells[abilkey])
    end

    -- Build trigger --
    local function CreateHellforgeTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, Hellforge_CastAbility)
    end
    OnInit.final(CreateHellforgeTrig)
end