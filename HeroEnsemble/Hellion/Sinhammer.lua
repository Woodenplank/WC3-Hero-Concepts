do
--[[
Game tooltip:
    "Infuse yourself with devillish power for <A00K:ANcl,Dur1> seconds, gaining additional ability damage and life regeneration rate. 
    While active, dealing ability damage heals the Hellion for a percentage of damage dealt. 
    Any enemy slain by the Hellion while this effect is active increases his maximum hit points by 1, up to a maximum of +1000.""

        + Belial's Insights			Passive: 	Sinhammer also grants a temporary Strength and Intelligence bonus based on the number of enemies nearby. 

    There are two ways of handling the Ability-Damage life steal
        • All ability damage is triggered, and therefore we could check - at the instant of dealing damage - whether Sinhammer was active.
        • Using a Damage-Detection system (like Bribe's), and checking whether an instance of damage comes from a Sinhammer Hellion.    
    --> Since we also want to buff ability damage when Sinhammer is active, we're going with the first option

    In any case the 'Sinhammer on/off' must be tracked. 
    Since we're using a standard "buff-ability" for the life regeneration, we may as well use that for tracking activity.
]]

    function SinhammerCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A00K") then
            return
        end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, abilId) - 1
        --TODO: Check for Hellforge bonus

        -- Fetch ability stats
        --local dmgfactor = GetAbilityField(FourCC('A00K'), "herodur", alv)
        --local healfactor = GetAbilityField(FourCC('A00K'), "aoe", alv)
        local dur = GetAbilityField(FourCC('A00K'), "normaldur", alv)

        -- Add buff ability
        UnitAddAbility(u, SHbuff_abilID)
        SetUnitAbilityLevel(u, SHbuff_abilID, alv+1)

        -- Objects
        local t = CreateTimer()

        -- Countdown to remove
        TimerStart(t, dur, false, function()
            UnitRemoveAbility(u, SHbuff_abilID)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end

    local function CreateSinhammerTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, SinhammerCast)
    end

    OnInit.trig(CreateSinhammerTrig)
end