do
    --[[ Tooltip
    "Siphon energy from enemies near you, or a currently active Celestial, dealing medium damage and gaining shields equal to 30% of the damage dealt."

    Note that the notion of 'shields' presupposes a Damage-Detection system.
    ]]

    local function NetherWeaverCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= AST_id_nether then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local alv = GetUnitAbilityLevel(u, AST_id_nether) - 1
        local id = GetHandleId(u)

        -- Stats
        local dmg = GetAbilityField(AST_id_nether, "herodur", alv) + addSP(u, 1.8)
        local aoe = GetAbilityField(AST_id_nether, "area", alv)
        local dur = GetAbilityField(AST_id_nether, "normaldur", alv)
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
        NetherWeaveShieldSFX[id] = AddSpecialEffectTarget("PinkMagicShield_.mdx", u, 'origin')
        UnitAddAbility(u, AST_id_netherbuff)
        SetUnitAbilityLevel(u, AST_id_netherbuff, alv+1)
        BlzUnitHideAbility(u, AST_id_netherbuff, true)

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
            UnitRemoveAbility(u, AST_id_netherbuff)
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

    local function NeverWeaveShielding()

        local instance = CreateFromEvent()

        -- Early return if the unit doesn't have the shield buff (dummy ability)
        local alv = GetUnitAbilityLevel(instance.target.unit, AST_id_netherbuff)
        if (alv <= 0) then
            return
        end

        local shield_remain = (NetherWeaveShield[instance.target.id] or 0)
        if shield_remain > instance.damageamount then
            shield_remain = shield_remain - instance.damageamount
            BlzSetEventDamage(0)
        elseif shield_remain < instance.damageamount then
            BlzSetEventDamage(instance.damageamount - shield_remain)
            shield_remain = 0
        end
        
        -- Update shield table
        if shield_remain == 0 then
            NetherWeaveShield[id] = nil
            DestroyEffect(NetherWeaveShieldSFX[id])
            NetherWeaveShieldSFX[id] = nil
        else
            NetherWeaveShield[instance.target.id] = shield_remain
        end
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
        TriggerAddAction(tr, NetherWeaveShielding)
    end

    OnInit.trig(CreateNetherWeaverTrig)
    OnInit.trig(CreateNetherWeaverShieldTrig)
end