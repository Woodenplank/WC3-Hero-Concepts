do
    --[[
        tooltip:
        The Hero raises her Guard, granting her a chance to parry and riposte melee attackers, reflecting 50% of damage taken.|nRanged attacks are not riposted, but instead Deflected for 90% damage reduction.

        |cffffcc00Level 1|r - <A001:ANcl,Area1,%>% chance to parry, lasts <A001:ANcl,HeroDur1> seconds.
        |cffffcc00Level 2|r - <A001:ANcl,Area2,%>% chance to parry, lasts <A001:ANcl,HeroDur2> seconds.
        |cffffcc00Level 3|r - <A001:ANcl,Area3,%>% chance to parry, lasts <A001:ANcl,HeroDur3> seconds.
    ]]
        
    local function GuardCast()
        --This particular trigger just handles the cast and expiration effects.
        local abilId = GetSpellAbilityId()
		if abilId ~= FourCC("A001") then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, FourCC('A001')) - 1
        local id = GetHandleId(u)

        -- Fetch ability stats
        local deflectchance = GetAbilityField(FourCC('A001'), "aoe", alv)
        local dur=GetAbilityField(FourCC('A001'), "herodur", alv)

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

    local function GuardVisual(instance)
        local x_source = GetUnitX(instance.source.unit)
        local y_source = GetUnitY(instance.source.unit)
        local x_target = GetUnitX(instance.target.unit)
        local y_target = GetUnitY(instance.target.unit)
        local ang = AngleBetweenCoords(x_target,x_source, y_target,y_source)
        local sfx_x, sfx_y = PolarStep(x_target, y_target, 65, ang)
        local sfx = AddSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", sfx_x, sfx_y)
        BlzSetSpecialEffectZ(sfx, 100+GetUnitFlyHeight(instance.target.unit))
        BlzSetSpecialEffectColor(sfx, 255, 255, 255)
        BlzSetSpecialEffectScale(sfx, 0.9)
        BlzSetSpecialEffectAlpha(sfx, 85)
        BlzSetSpecialEffectTimeScale(sfx, 7.5)
        BlzSetSpecialEffectOrientation(sfx, (1.57 + ang), 1.57, 1.57) -- yaw, pitch roll
        DestroyEffect(sfx)
    end

    local function GuardDeflection()
        local instance = CreateFromEvent()
        -- Early return if spell damage
        if (instance.isSpell) then
            return
        end
        -- Early return if the unit doesn't have the shield buff (dummy ability)
        local alv = GetUnitAbilityLevel(instance.target.unit, FourCC('S002'))
        if (alv <= 0) then
            return
        end
        
        local deflectchance = GetAbilityField(FourCC('A001'), "aoe", alv-1)
        if (math.random() <= deflectchance) then
            if (instance.source.isMelee) then
                local reflect = instance.damageamount * 0.5
                UnitDamageTarget(instance.target.unit, instance.source.unit, reflect, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                BlzSetEventDamage(reflect)  -- other half of damage "goes through"
                GuardVisual(instance)
            elseif (instance.source.isRanged) then
                BlzSetEventDamage(instance.damageamount*0.1)
                GuardVisual(instance)
            end
        end
        -- END --
    end

    -- Build trigger --
    local function CreateGuardDeflectTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, GuardDeflection)
    end
    OnInit.trig(CreateGuardDeflectTrig)
end