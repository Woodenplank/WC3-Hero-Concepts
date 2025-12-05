do

    local function PoasActivate()
        -- Early exit if wrong spell
        local abilId = GetSpellAbilityId()
		if abilId ~= FourCC("A00O") then
			return
		end

        -- Early exit if no mana buffer
        local u = GetTriggerUnit()
        local mana_current = GetUnitState(u, UNIT_STATE_MANA )
        if (mana_current <= 5.0) then
            return
        end

        -- Getters (beyond Triggering Unit above)
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local alv = GetUnitAbilityLevel(u, FourCC('A00O'))
        local id = GetHandleId(u)

        -- Fetch ability stats
        local tinterval = 0.5
        local dmg = (GetAbilityField('A00O', "herodur", alv) + addSP(0.3)) * tinterval
        local aoe = GetAbilityField('A00O', "aoe", alv)

        -- Dummy buff
        FastAbilityAdd(u, 'something', alv, hide=true)

        -- Speed boost
        local dummy = CreateUnit(GetOwningPlayer(u), FourCC('e000'), x, y)
        FastAbilityAdd(dummy, 'bloodlust', 1, false)
        IssueTargetOrdet(dummy, '``??????', u)
        UnitApplyTimedLifeBJ( 1.5, FourCC('BTLF'), dummy)

        -- //////Visual
        -- Added through dummy buff ability any way
        -- local sfx = AddSpecialEffectTarget(u, "HolyAura.mdx", "origin")

        -- Swap ability option
        BlzUnitHideAbility(u, FourCC('A00O'), true)
        BlzUnitHideAbility(u, FourCC('DonkeyKong'), false)

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Looping
        TimerStart(t, tinterval, true, function()
            x = GetUnitX(u)
            y = GetUnitY(u)
            local count
            -- Area damage
            GroupEnumUnitsInRange(ug, x, y, aoe, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if (IsUnitEnemy(u, GetOwningPlayer(enemy))) then
                    UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    count = count + 1
                end
            end)

            -- Caster healing
            QuickHeal( u, (GetUnitState(u, UNIT_STATE_MAX_LIFE)/200) )  -- 0.5% heal
            if (count > 0) then 
                -- If an enemy is hit; bonus heal equal to damage
                QuickHeal(u, dmg) 
            end

            -- deactivation check
            mana_current = GetUnitState(u, UNIT_STATE_MANA ) - 0.5
            SetUnitState(u, UNIT_STATE_MANA, mana_current)
            if ( (mana_current <= 0.5) or (GetUnitAbilityLevel(u, 'something') < 1) ) then
                UnitRemoveAbility(u, 'something')
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
            end
        end)
        -- END --
    end

    local function PoasDeactivate()
        -- Exit early if it's the wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= FourCC('DonkeyKong') then
			return
		end

        -- Get rid of the (dummy) buff ability
        local u = GetTriggerUnit()
        UnitRemoveAbility(u, FourCC('something'))

        -- Swap ability option
        BlzUnitHideAbility(u, FourCC('A00O'), true)
        BlzUnitHideAbility(u, FourCC('DonkeyKong'), false)
        -- END --
    end

    -- Build triggers --
    local function CreatePoasATrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, PoasActivate)
    end
    local function CreatePoasDTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, PoasDeactivate)
    end
    OnInit.trig(CreatePoasATrig)
    OnInit.trig(CreatePoasDTrig)
end
