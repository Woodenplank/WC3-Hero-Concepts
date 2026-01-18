do
    --[[
        tooltip:
        The Hero raises her Guard, granting her a chance to parry and riposte melee attackers, reflecting 50% of damage taken.|nRanged attacks are not riposted, but instead Deflected for 90% damage reduction.

        |cffffcc00Level 1|r - <A001:ANcl,Area1,%>% chance to parry, lasts <A001:ANcl,HeroDur1> seconds.
        |cffffcc00Level 2|r - <A001:ANcl,Area2,%>% chance to parry, lasts <A001:ANcl,HeroDur2> seconds.
        |cffffcc00Level 3|r - <A001:ANcl,Area3,%>% chance to parry, lasts <A001:ANcl,HeroDur3> seconds.


        The 'Deflect' portion of this ability relies on a Damage Detection system, do catch Normal Attacks against the Hero.
        It'll work in conjunction with a simple "Unit has Buff" check.  
    ]]
    local function GuardCast()
        --This particular trigger just handles the cast and expiration effects.
        local abilId = GetSpellAbilityId()
		if abilId ~= HSS_id_guard then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, HSS_id_guard) - 1
        local id = GetHandleId(u)

        -- Fetch ability stats
        local deflectchance = GetAbilityField(HSS_id_guard, "aoe", alv)
        local dur=GetAbilityField(HSS_id_guard, "herodur", alv)

        -- Dummy (buff) ability
        FastAbilityAdd(u, 'S002', alv+1, true)

        -- Objects
        local t = CreateTimer()

        -- Prep caster
        local sfx = AddSpecialEffectTarget("PaladinAura.mdx", u, 'origin')
        AddUnitAnimationProperties(u, 'Lumber', false) -- remove animation tag
        AddUnitAnimationProperties(u, 'Defend', true) -- add animation tag

        TimerStart(t, dur, false, function()
            AddUnitAnimationProperties(u, 'Lumber', true)
            AddUnitAnimationProperties(u, 'Defend', false)
            DestroyEffect(sfx)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end
    
    -- Build trigger --
    local function CreateGuardTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, GuardCast)
    end
    OnInit.trig(CreateGuardTrig)

-----------------------------------------------------------------------------------------------------------------------------
    ---@param sor unit
    ---@param targ unit
    ---@return 
    local function GuardSFX(sor, targ)
        -- Damage "block" effect
        local x_source = GetUnitX(sor)
        local y_source = GetUnitY(sor)
        local x_target = GetUnitX(targ)
        local y_target = GetUnitY(targ)
        local ang = AngleBetweenCoords(x_source,x_target, y_source, y_target)
        local sfx_x, sfx_y = PolarStep(x_targ, y_targ, 85, ang)
        local sfx = AddSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", sfx_x, sfx_y)
        --set udg_BAmr_Spef_Current_Height[udg_BAmr_Loop] = GetLocationZ(udg_BAmr_Point[1])
        BlzSetSpecialEffectZ(sfx, 65+GetUnitFlyHeight(targ))
        BlzSetSpecialEffectColor(sfx, 255, 255, 255)
        BlzSetSpecialEffectScale(sfx, 0.9)
        BlzSetSpecialEffectAlpha(sfx, 0.85)
        BlzSetSpecialEffectTimeScale(sfx, 7.5)
        BlzSetSpecialEffectOrientation(sfx, (1.57 + ang), 1.57, 1.57) -- yaw, pitch roll
        DestroyEffect(sfx)
    end
    local function GuardDeflect()
        local guard = udg_DamageEventTarget
        local atcker= udg_DamageEventSource
        -- Get DummyBuffAbility level
        local alv = GetUnitAbilityLevel(u, FourCC('which_ability'))
        if (alv <= 0) then
            return
        end
        local deflectchance = GetAbilityField(HSS_id_guard, "aoe", alv-1)
        if (math.random() <= deflectchance) then
            if (udg_IsDamageMelee) then
                local dmg = udg_DamageEventPrevAmount * 0.5
                --NextDamageType = udg_DamageEventAttackT
                UnitDamageTarget(guard, atcker, dmg, true, false, udg_DamageEventAttackT, DAMAGE_TYPE_NORMAL, nil)
                udg_DamageEventAmount = dmg
            elseif (udg_IsDamageRanged) then
                udg_DamageEventAmount = udg_DamageEventAmount * 0.1
            end
            --DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", guard, 'chest'))
            GuardSFX(udg_DamageEventSource, udg_DamageEventTarget)
        end
        -- END --
    end
    -- Build trigger --
    local function CreateGuardDeflectTrig()
        local tr = CreateTrigger()
        TriggerRegisterVariableEvent(tr, udg_PreDamageEvent, EQUAL, 1.0)
        TriggerAddAction(tr, GuardDeflect)
    end
    OnInit.trig(CreateGuardDeflectTrig)
end