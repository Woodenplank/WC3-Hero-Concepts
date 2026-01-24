do
    RAT_id_makeway = FourCC('A015')

    local function RatGrenadeThrow()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= RAT_id_makeway then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, RAT_id_makeway) - 1
        local knockback = GetAbilityField(RAT_id_makeway, "normaldur", alv)
        local dmg = GetAbilityField(RAT_id_makeway, "herodur", alv)
        local aoe = GetAbilityField(RAT_id_makeway, "aoe", alv)
        local targ_x, targ_y = GetSpellTargetX(), GetSpellTargetY()
        local init_x, init_y = GetUnitX(u), GetUnitY(u)

        -- Missile
        local missile = Missiles:create(init_x, init_y, 40, targ_x, targ_y, 0)
        missile:model("Abilities\\Weapons\\Mortar\\MortarMissile.mdl")
        missile:speed(700)
        missile.source = u
        missile.owner = GetOwningPlayer(u)
        missile:arc(30)
        missile:scale(1.5)
        missile:vision(350)
        missile.damage=dmg

        missile.onFinish = function()
            local ug = CreateGroup()
            GroupEnumUnitsInRange(ug, missile.x, missile.y, aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if IsUnitEnemy(missile.source, GetOwningPlayer(pu)) then
                    UnitDamageTarget(missile.source, pu, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    
                    -- knockback
                    local t = CreateTimer()
                    local tinterval = 1/20
                    TimerStart(t, tinterval, true, function()
                        local x,y = GetUnitX(pu), GetUnitY(pu)
                        local dist = Distance(x,targ_x, y,targ_y)
                        local ang = AngleBetweenCoords(targ_x,x, targ_y,y)
                        local x2,y2 = PolarStep(x,y,20,ang)
                        SetUnitPathing( pu, false )
                        SetUnitPosition(pu, x2, y2)
                        DestroyEffect(AddSpecialEffect("flakdust.mdx", x2, y2))
                        -- attempt to end
                        if (dist >= aoe+100) or (dist>=knockback) then
                            PauseTimer(t)
                            DestroyTimer(t)
                            SetUnitPathing( pu, true )
                        end
                    end)
                end
            end)
            DestroyGroup(ug)
            DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\Mortar\\MortarMissile.mdl", missile.x, missile.y))

            return true
        end
        missile:launch()
        -- END --
    end

    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, RatGrenadeThrow)
    end

    OnInit.trig(CreateCastTrigger)
end