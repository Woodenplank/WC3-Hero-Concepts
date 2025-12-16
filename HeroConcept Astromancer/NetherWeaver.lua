do
    --[[ Tooltip
    "Siphon energy from enemies near you, or a currently active Celestial, dealing medium damage and gaining shields equal to 30% of the damage dealt."

    Note that the notion of 'shields' presupposes a Damage-Detection system.
    ]]

    local function NetherWeaverCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A002") then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local alv = GetUnitAbilityLevel(u, FourCC('A002')) - 1
        local id = GetHandleId(u)

        -- Stats
        local dmg = GetAbilityField(FourCC('A002'), "herodur", alv) + addSP(u, 1.8)
        local aoe = GetAbilityField(FourCC('A002'), "area", alv)
        local dur = GetAbilityField(FourCC('A002'), "normaldur", alv)
        local shieldfactor = 0.3
 
        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local cond = Condition(function() return
			(IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(u))
            or UnitTypeCheck(GetFilterUnit(), 'e003'))
			and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
			and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(GetFilterUnit())
		end)

        -- Dummy ability (buff)
        local NetherWeaveShieldSFX[id] = AddSpecialEffectTarget("PinkMagicShield_.mdx", u, 'origin')
        UnitAddAbility(u, FourCC('A00F'))
        SetUnitAbilityLevel(u, FourCC('A00F'), alv+1)
        BlzUnitHideAbility(u, FourCC('A00F'), true)

        -- Arcane Almanac crit stats fetch
        local critmod = GetAlmaCritmod(u)
        local critchance = GetAlmaCritchance(u)
        local moddeddmg = dmg

        -- Area damage + Shield-Gen
        GroupEnumUnitsInRange(ug, x, y, aoe, cond)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            if (critmod > 1.0) then
                -- roll for crit damage
                if (math.random() <= critchance) then
                    moddeddmg = dmg*critmod
                end
            end
            UnitDamageTarget(u, pu, moddeddmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            if NetherWeaveShield[id] ~= nil then
                NetherWeaveShield[id] = NetherWeaveShield[id] + (shieldfactor * moddeddmg)
            else
                NetherWeaveShield[id] = shieldfactor * moddeddmg
            end
        end)

        -- Duration
        TimerStart(t, dur, false, function()
            UnitRemoveAbility(u, FourCC('A00F'))
            DestroyEffect(NetherWeaveShieldSFX[id])
            NetherWeaveShield[id] = 0

            PauseTimer(t)
            DestroyTimer(t)            
        end)
        -- Clean memory
        DestroyGroup(ug)
        DestroyCondition(cond)
    -- END --
    end

    -- Damage Detection/Shielding
    local function NetherWeaveShieldAbsorb()
        local shielded = GetTriggerUnit()
        local id = GetHandleId(shielded)
        local atcker= GetEventDamageSource()
        -- Get DummyBuffAbility level
        local alv = GetUnitAbilityLevel(shielded, FourCC('A00F'))
        
        -- Early return if the unit doesn't have the shield buff (dummy ability)
        if (alv <= 0) then
            return
        end

        -- Reduce saved shield amount and then nullify damage
        local dmg_inc = GetEventDamage()
        local shield_remaining = (NetherWeaveShield[id] or 0)

        if shield_remaining > dmg_inc then
            shield_remaining = shield_remaining - dmg_inc
            dmg_inc = 0
        elseif shield_remaining < dmg_inc then
            dmg_inc = dmg_inc - shield_remaining
            shield_remaining = 0
        end
        BlzSetEventDamage(dmg_inc)
        
        -- Update shield table
        if shield_remaining == 0 then
            NetherWeaveShield[id] = nil
            DestroyEffect(NetherWeaveShieldSFX[id])
            NetherWeaveShieldSFX[id] = nil
        else
            NetherWeaveShield[id] = shield_remaining
        end

        --DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", shielded, 'chest'))
        -- END --
    end


    -- Build triggers --
    local function CreateNetherWeaverTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, NetherWeaverCast)
    end
    local function CreateNetherWeaverShieldTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, NetherWeaveShieldAbsorb)
    end

    OnInit.trig(CreateNetherWeaverTrig)
    OnInit.trig(CreateNetherWeaverShieldTrig)
end