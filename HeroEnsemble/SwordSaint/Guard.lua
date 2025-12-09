do
    --[[
        tooltip:

        The 'Deflect' portion of this ability relies on a Damage Detection system, do catch Normal Attacks against the Hero.
        It'll work in conjunction with a simple "Unit has Buff" check.
        This particular trigger just handles the cast and expiration effects.
    ]]
    local function GuardCast()
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
    --[[
        ...
        Some implementation of damage detection
        ...
        ...
            local dmg_inc = GetEventDamage()
            TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
    ]]
    local function GuardDeflect()
        local guard = GetTriggerUnit()
        local atcker= GetEventDamageSource()
        -- Get DummyBuffAbility level
        local alv = GetUnitAbilityLevel(guard, FourCC('S002'))
        if (alv <= 0) then
            return
        end
        local dmg_inc = GetEventDamage()
        local deflectchance = GetAbilityField(FourCC('A001'), "aoe", alv)
        if (math.random() <= deflectchance) then
            if (true) then
                local dmg = dmg_inc * 0.5
                UnitDamageTarget(guard, atcker, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                BlzSetEventDamage(dmg)
            -- TODO Implement option for melee/ranged damage check
            -- elseif (IsDamageRanged) then
            --     local dmg = dmg_inc * 0.1
            --     BlzSetEventDamage(dmg)
            end
            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", guard, 'chest'))
        end
        -- END --
    end
    -- Build trigger --
    local function CreateGuardDeflectTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, GuardDeflect)
    end
    OnInit.trig(CreateGuardDeflectTrig)
end