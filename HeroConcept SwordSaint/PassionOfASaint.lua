do
    --[[
    Engulfs the Sword Saint in Flames of Passion gaining a burst of speed and beginning to heal herself for 1% of max health per second. 
    Consumes 1 CP per second to maintain the flame, dealing constant damage to nearby foes, granting bonus healing Sword Saint if an enemy is hit. 
    
    |cffffcc00Level 1|r - <A007:ANcl,HeroDur1> damage and bonus healing per second. 
    |cffffcc00Level 2|r - <A007:ANcl,HeroDur2> damage and bonus healing per second. 
    |cffffcc00Level 3|r - <A007:ANcl,HeroDur3> damage and bonus healing per second.
    ]]
    local function PoasActivate()
        -- Early exit if wrong spell
        local abilId = GetSpellAbilityId()
		if abilId ~= HSS_id_passionON then
			return
		end

        -- Early exit if no mana buffer
        local u = GetTriggerUnit()
        local mana_current = GetUnitState(u, UNIT_STATE_MANA)
        if (mana_current <= 5.0) then
            return
        end

        -- Getters (beyond Triggering Unit above)
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local alv = GetUnitAbilityLevel(u, HSS_id_passionON) - 1
        --local id = GetHandleId(u)

        -- Fetch ability stats
        local tinterval = 0.5
        local dmg = (GetAbilityField(HSS_id_passionON, "herodur", alv) + addSP(u, 0.3)) * tinterval
        local aoe = GetAbilityField(HSS_id_passionON, "aoe", alv)

        -- Dummy buff
        FastAbilityAdd(u, 'S001', alv+1, true)

        -- Speed boost
        local dummy = CreateUnit(GetOwningPlayer(u), FourCC('e000'), x, y, 270)
        FastAbilityAdd(dummy, 'A006', 1, false)
        IssueTargetOrder(dummy, "bloodlust", u)
        UnitApplyTimedLifeBJ( 1.5, FourCC('BTLF'), dummy)

        -- //////Visual
        -- Added through dummy buff ability any way
        -- local sfx = AddSpecialEffectTarget(u, "HolyAura.mdx", "origin")

        -- Swap ability option
        BlzUnitHideAbility(u, HSS_id_passionON, true)
        BlzUnitHideAbility(u, HSS_id_passionOFF, false)

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Looping
        TimerStart(t, tinterval, true, function()
            x = GetUnitX(u)
            y = GetUnitY(u)
            local count=0
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
            QuickHealUnit( u, (GetUnitState(u, UNIT_STATE_MAX_LIFE)/200) )  -- 0.5% heal
            if (count > 0) then 
                -- If an enemy is hit; bonus heal equal to damage
                QuickHealUnit(u, dmg) 
            end

            -- deactivation check
            mana_current = GetUnitState(u, UNIT_STATE_MANA ) - 0.5
            SetUnitState(u, UNIT_STATE_MANA, mana_current)
            if ( (mana_current <= 0.5) or (GetUnitAbilityLevel(u, HSS_id_passionbuff) < 1) ) then
                UnitRemoveAbility(u, HSS_id_passionbuff)
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
            end
        end)
        -- END --
    end

    ----------------------------------------------------------------------------------------------------

    local function PoasDeactivate()
        -- Exit early if it's the wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= HSS_id_passionOFF then
			return
		end

        -- Get rid of the (dummy) buff ability
        local u = GetTriggerUnit()
        UnitRemoveAbility(u, HSS_id_passionbuff)

        -- Swap ability option
        BlzUnitHideAbility(u, HSS_id_passionON, true)
        BlzUnitHideAbility(u, HSS_id_passionOFF, false)
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