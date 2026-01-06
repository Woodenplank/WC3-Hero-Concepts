do
    --[[
    Virtually identical to the Sword-Saint's "Dash" ability, but with different object editor parameters.
    Though notably, this one is specialized to benefit from the Sinhammer ability.
    ]]

    local function ChargeCast()
        local abilId = HEL_id_charge
        local castId = GetSpellAbilityId()
		if castId ~= abilId then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, abilId) - 1
        
        -- Fetch ability stats
        local dmg = GetAbilityField(abilId, "herodur", alv)
        local aoe = GetAbilityField(abilId, "area", alv)
        local range=GetAbilityField(abilId, "range", alv)

        -- Sinhammer mod
        local SH_alv = GetUnitAbilityLevel(u, SHbuff_abilId)
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Objects
        local ug = CreateGroup()
        local protgroup = CreateGroup()
        local t = CreateTimer()

        -- Geometry
        local x_0 = GetUnitX(u)
        local y_0 = GetUnitY(u)
        local x_2 = GetSpellTargetX()
        local y_2 = GetSpellTargetY()
        local ang = AngleBetweenCoords(x_0, x_2, y_0, y_2)

        -- Prep caster
        local sfx = AddSpecialEffectTarget("Valiant Charge.mdx", u, 'origin')
        PauseUnit(u, true)
        SetUnitPathing( u, false ) -- collision Off

        -- Motion
        TimerStart(t, 0.03, true, function()
            -- move hero forwards
            local x_1, y_1 = PolarStep(GetUnitX(u), GetUnitY(u), 20, ang)
            SetUnitX(u, x_1)
            SetUnitY(u, y_1)

            -- Area damage
            GroupEnumUnitsInRange(ug, x_1, y_1, aoe, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if (IsUnitEnemy(u, GetOwningPlayer(enemy)) and not IsUnitInGroup(enemy, protgroup)) then
                    UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    GroupAddUnit(protgroup, enemy)
                    --Sinhammer healing
                   if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end
                end
            end)

            -- Check for destination
            if (Distance(x_1,x_2,y_1,y_2) <= 30) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyEffect(sfx)
                DestroyGroup(ug)
                DestroyGroup(protgroup)
                --Reset caster
                PauseUnit(u, false)
                SetUnitPathing(u, true)
            end
        end)
        -- END --
    end

    -- Build trigger --
    local function CreateChargeTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, ChargeCast)
    end
    OnInit.trig(CreateChargeTrig)
end