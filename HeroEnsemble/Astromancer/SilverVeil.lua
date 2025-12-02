do
    --[[
        "Shroud yourself in starlight, gaining bonus armor and movement speed and restoring a small amount of hit points.
        Lasts <A00H:ANcl,Dur1> seconds."
    ]]
    function SilverVeilCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A00H") then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, abilId) - 1

        -- Stats
        local heal = GetAbilityField(FourCC('A00H'), "herodur", alv)
        local dur = GetAbilityField(FourCC('A00H'), "normaldur", alv)
 
        -- Objects
        local t = CreateTimer()

        -- Heal
        QuickHealUnit(u, heal)

        -- Add buff abilities
        local sfx = AddSpecialEffectTarget("Radiance Silver.mdx", u, 'chest')
        UnitAddAbility(u, FourCC('A00G'))
        SetUnitAbilityLevel(u, FourCC('A00G'), alv+1)
        BlzUnitHideAbility(u, FourCC('A00G'), true)
        UnitAddAbility(u, FourCC('A00Z'))
        SetUnitAbilityLevel(u, FourCC('A00Z'), alv+1)
        BlzUnitHideAbility(u, FourCC('A00Z'), true)

        -- Duration
        TimerStart(t, dur, false, function()
            DestroyEffect(sfx)
            UnitRemoveAbility(u, FourCC('A00G'))
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