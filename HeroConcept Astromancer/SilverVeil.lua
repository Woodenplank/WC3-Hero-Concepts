do
    --[[
        "Shroud yourself in starlight, gaining bonus armor and movement speed and restoring a small amount of hit points.
        Lasts <A00H:ANcl,Dur1> seconds."
    ]]
    local function SilverVeilCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= AST_id_silver then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, abilId) - 1

        -- Stats
        local heal = GetAbilityField(AST_id_silver, "herodur", alv)
        local dur = GetAbilityField(AST_id_silver, "normaldur", alv)
 
        -- Objects
        local t = CreateTimer()

        -- Heal
        QuickHealUnit(u, heal)

        -- Add buff abilities
        local sfx = AddSpecialEffectTarget("Radiance Silver.mdx", u, 'chest')
        UnitAddAbility(u, AST_id_silverbuff)
        SetUnitAbilityLevel(u, AST_id_silverbuff, alv+1)
        BlzUnitHideAbility(u, AST_id_silverbuff, true)
        UnitAddAbility(u, FourCC('A00Z'))
        SetUnitAbilityLevel(u, FourCC('A00Z'), alv+1)
        BlzUnitHideAbility(u, FourCC('A00Z'), true)

        -- Duration
        TimerStart(t, dur, false, function()
            DestroyEffect(sfx)
            UnitRemoveAbility(u, AST_id_silverbuff)
            UnitRemoveAbility(u, FourCC('A00Z'))
            PauseTimer(t)
            DestroyTimer(t)  
        end)
        -- END --
    end


    -- Build Trigger --
    local function CreateSilverVeilTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, SilverVeilCast)
    end

    OnInit.trig(CreateSilverVeilTrig)
end