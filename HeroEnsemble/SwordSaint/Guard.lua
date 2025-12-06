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
        local dur=GetAbilityField(FourCC('A001'), "normaldur", alv)

        -- Dummy (buff) ability
        FastAbilityAdd(u, 'which_ability', alv, hide=true)

        -- Objects
        local t = CreateTimer()

        -- Prep caster
        local sfx = AddSpecialEffectTarget("PaladinAura.mdx", u, 'origin')
        AddUnitAnimationProperties(u, 'Lumber', false) -- remove animation tag
        AddUnitAnimationProperties(u, 'Defend', true) -- add animation tag

        TimerStart(t, dur, false, function()
            AddUnitAnimationProperties(u, 'Lumber', true)
            AddUnitAnimationProperties(u, 'Defend', false)
            DestroyEffect(t)
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
end