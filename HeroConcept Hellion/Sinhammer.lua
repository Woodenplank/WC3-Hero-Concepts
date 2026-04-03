-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
-- requires QuickHeal.lua
-- requires SafeHideAbility.lua
do
--[[
Game tooltip:
    "Infuse yourself with devillish power for <A00K:ANcl,Dur1> seconds, gaining additional ability damage and life regeneration rate. 
    While active, dealing ability damage heals the Hellion for a percentage of damage dealt. 
    Any enemy slain by the Hellion while this effect is active increases his maximum hit points by 1, up to a maximum of +1000.""

        + Belial's Insights			Passive: 	Sinhammer also grants a temporary Strength and Intelligence bonus based on the number of enemies nearby. 
]]
    local function SinhammerCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= HEL_sinhammerSpell.id then
            return
        end

        -- Ability stats
        local this = HEL_sinhammerSpell:NewInstance()

        -- Hellforge mod
        local BelialsInsights = (GetUnitAbilityLevel(this.caster, HellforgedSpells["BelialsInsights"]) > 0)
        if BelialsInsights then
            -- objects
            local ug = CreateGroup()
            local cond = Condition(function() 
                local fu=GetFilterUnit()
                return IsUnitEnemy(fu, this.castplayer)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
            end)

            -- count nearby foes and apply proper bufflevel
            GroupEnumUnitsInRange(ug, GetUnitX(this.caster), GetUnitY(this.caster), 500, cond)
            UnitAddAbility(this.caster, HEL_sinhammerattrib)
            SetUnitAbilityLevel(this.caster, HEL_sinhammerattrib, CountUnitsInGroup(ug))

            -- clean objects
            DestroyGroup(ug)
            DestroyCondition(cond)
        end

        -- Add buff ability
        UnitAddAbility(this.caster, HEL_sinhammerbuff)
        SetUnitAbilityLevel(this.caster, HEL_sinhammerbuff, this.alv+1)
        HideAbility(this.caster, HEL_sinhammerbuff)

        -- Countdown to remove
        local t = CreateTimer()
        TimerStart(t, this.normaldur, false, function()
            RemoveAbility(this.caster, HEL_sinhammerbuff) -- see SafeHideAbility.lua
            UnitRemoveAbility(this.caster, HEL_sinhammerattrib)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end
    HEL_sinhammerSpell:MakeTrigger(SinhammerCast)
end