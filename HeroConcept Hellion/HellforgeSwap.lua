-- requires HellionGlobal.lua
do
    local function Hellforge_ability()
        local Hf = GetTriggerUnit()
        -- Exit early if not Hellforge
        if GetUnitTypeId(Hf) ~= Hellforge_utype then
            return
        end

        -- fetch the ability id and transform to text key
        local abilkey = GetSpellAbilityId()
        if (abilkey == HellforgedResearches["ArmsOfAstaroth"]) then 
            abilkey = "ArmsOfAstaroth"
        elseif (abilkey == HellforgedResearches["BelialsInsights"]) then
            abilkey = "BelialsInsights"
        elseif (abilkey == HellforgedResearches["SevenTonguesOfPytho"]) then
            abilkey = "SevenTonguesOfPytho"
        elseif (abilkey == HellforgedResearches["CrownOfTheNineKingdoms"]) then
            abilkey = nil -- TODO: this has no effect/spell yet!
        else
            abilkey = nil
        end
        -- note that the researches, spells, and blocker-unit-type tables all use the same keys!

        -- HEL_forgelinks is a table-of-tables, structured as
        -- {"herohandle" = hero, "forgehandle" = forge_id, "grouphandle" = HFresearchBlockers}
        local forge_id = GetHandleId(Hf)
        local which_group = nil
        local which_hellion = nil
        for _,tab in pairs(HEL_forgelinks) do
            print(tab["forgehandle"])
            if tab["forgehandle"] == forge_id then
                which_group = tab["grouphandle"]
                which_hellion = tab["herohandle"]
                print("Found matching hellion + group")
                break
            end
        end

        -- Clear all current research units for this Hellion
        -- then reenable the other Hellforge options again
        local owner = GetOwningPlayer(Hf)
        ForGroup(which_group, function()
            RemoveUnit(GetEnumUnit())
        end)     
        for key,unit_type in pairs(Hellforge_blockerstacks) do
            if key~=abilkey then
                print("Created: "..tostring(unit_type))
                local temp = CreateUnit(owner, unit_type, 0, 0, 270)
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
        TriggerAddAction(tr, Hellforge_ability)
    end
    OnInit.final(CreateHellforgeTrig)
end