do
    --[[
        When falling below 5% hit points, the Hellion's demonic master will intercede on his behalf and save him from certain death, restoring health,
         blasting nearby foes with dark fire, and granting his champion a burst of daemonic strength.
        This effect has a <A00X:ANcl,Cool1> seconds cooldown.

        |cffffcc00Level 1|r - <A00X:ANcl,Dur1,%>% health restored, <A00X:ANcl,HeroDur1> area damage. Gain +30 Strength.
        |cffffcc00Level 2|r - <A00X:ANcl,Dur2,%>% health restored, <A00X:ANcl,HeroDur2> area damage. Gain +50 Strength.
        |cffffcc00Level 3|r - <A00X:ANcl,Dur3,%>% health restored, <A00X:ANcl,HeroDur3> area damage. Gain +70 Strength.
    ]]

	local DP_abilId=FourCC('A00X')	-- ability id of the passive (/learn)
	local DP_cdId=FourCC('A011')	-- ability id of the cooldown tracker
    local DP_strId=FourCC('A010')   -- ability id of the attribute bonus

    local function DemonicPactLethal()

        local instance = CreateFromEvent()
        -- Early return if wrong unit
        if not (UnitTypeCheck(instance.target.unit, 'O001')) then
            return
        end
        -- Early return if above health threshold
        local hp_threshold = GetUnitState(instance.target.unit, UNIT_STATE_MAX_LIFE)*0.05
        if (GetUnitState(instance.target.unit, UNIT_STATE_LIFE) > hp_threshold) then
            return
        end
        
        local cd = BlzGetUnitAbilityCooldown(instance.target.unit, DP_cdId, 1)  -- cooldown for level 1. Adjust this if ever updated to multi-level cooldowns
        if cd <= 0.5 then
            -- nullify the damage
            BlzSetEventDamage(0)
            
            -- Ability stats
            local alv = GetUnitAbilityLevel(instance.target.unit, DP_abilId)
            if alv<1 then
                return
            end
            local healp = GetAbilityField(DP_abilId, "normaldur", alv-1)
            local dmg = GetAbilityField(DP_abilId, "herodur", alv-1)

            -- Objects
            local ug = CreateGroup()
            local t = CreateTimer()

             -- Sinhammer mod
            local SH_alv = GetUnitAbilityLevel(instance.target.unit, SHbuff_abilId)
            local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
            if (SHbool) then
                dmg = dmg*SHdmgfactor
                dmg_instant = dmg_instant*SHdmgfactor
            end

            -- heal hellion and damage area
            local x = GetUnitX(instance.target.unit)
            local y = GetUnitY(instance.target.unit)
            QuickHealUnit(instance.target.unit, GetUnitState(instance.target.unit, UNIT_STATE_MAX_LIFE) * healp)           
            GroupEnumUnitsInRange(ug, x, y, 350, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if (IsUnitEnemy(instance.target.unit, GetOwningPlayer(enemy))) then
                    UnitDamageTarget(instance.target.unit, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    --Sinhammer healing
                   if (SHbool) then QuickHealUnit(instance.target.unit, SHhealfactor*dmg) end
                end
            end)
            DestroyEffect(AddSpecialEffect("Flamestrike Dark Blood II.mdx", x, y))

            -- Bonus attribute
            UnitAddAbility(instance.target.unit, DP_strId)
            SetUnitAbilityLevel(instance.target.unit, DP_strId, alv)
            TimerStart(t, 7, true, function()
                UnitRemoveAbility(instance.target.unit, DP_strId)
                PauseTimer(t)
                DestroyTimer(t)
            end)
            -- reset
            DestroyGroup(ug)
            BlzStartUnitAbilityCooldown(instance.target.unit, DP_cdId, GetAbilityField(DP_abilId, 'cooldown', alv-1) )
        end
        -- END --
    end

    local function CreateDemonicPactTrigger()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, DemonicPactLethal)
    end
    OnInit.trig(CreateDemonicPactTrigger)
end