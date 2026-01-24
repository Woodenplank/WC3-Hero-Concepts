do
    RAT_id_sewageaura = FourCC('A017')
    RAT_id_sewage = FourCC('A018')

    local function RandomAreaPoint(center_x, center_y, aoe)
        -- for spreading impacts across a target area
        local randang = math.random() * 2*math.pi
        local randdist = math.random() * aoe
        local x,y = PolarStep(center_x, center_y, randdist, randang)
        return x,y
    end

    local function AfterSlime(x,y,u,lifetime,alv)
        -- dummy for slow aura and a pretty special effect
        -- both share the same timed life
        local slimedummy = CreateUnit(GetOwningPlayer(u), FourCC('e000'), x, y, 0)
        UnitAddAbility(slimedummy, RAT_id_sewageaura)
        SetUnitAbilityLevel(slimedummy, RAT_id_sewageaura, alv+1)
        local slimesfx = AddSpecialEffect("SpiderToxin.mdx", x, y)

        local t = CreateTimer()
        TimerStart(t, lifetime, false, function()
            RemoveUnit(slimedummy)
            DestroyEffect(slimesfx)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        return true
    end


    local function SewerShowerCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= RAT_id_sewage then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, RAT_id_sewage) - 1
        local dur = GetAbilityField(RAT_id_sewage, "normaldur", alv)
        local dmg = GetAbilityField(RAT_id_sewage, "herodur", alv)
        local aoe = GetAbilityField(RAT_id_sewage, "aoe", alv)
        local count=math.tointeger(GetAbilityField(RAT_id_sewage, "artdur", alv))
        local targ_x, targ_y = GetSpellTargetX(), GetSpellTargetY()
        local init_x, init_y = GetUnitX(u), GetUnitY(u)

        -- Missile constants
        local speed=550
        local sfx = "WidowPoison.mdx"
        local sfx_finish=nil
        local colisn = 125

        -- Staggered launch
        local launcht = CreateTimer()
        local launchspacing = 0.15
        local i = 1
        TimerStart(launcht, launchspacing, true, function()
            if (count>0) and (i<=count) then
                i = i+1
                local arc = math.random(25,35)
                local x2,y2 = RandomAreaPoint(targ_x,targ_y,aoe)
                local missile = PointTargetMissile(init_x, init_y, 50, x2, y2, 0, u, dmg, colisn, aoe, speed, sfx, sfx_finish, 0.8, arc)
                missile:vision(100)

                missile.onFinish = function()
                    local ug = CreateGroup()
                    GroupEnumUnitsInRange(ug, missile.x, missile.y, colisn, nil)
                    ForGroup(ug, function()
                        local pu = GetEnumUnit()
                        if IsUnitEnemy(missile.source, GetOwningPlayer(pu)) then
                            UnitDamageTarget(missile.source, pu, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        end
                    end)
                    
                    AfterSlime(missile.x, missle.y, u, dur, alv+1)
                    DestroyGroup(ug)

                    return true
                end
                missile:launch()
            else
                PauseTimer(launcht)
                DestroyTimer(launcht)
            end
        end)
        -- END --
    end

    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, SewerShowerCast)
    end

    OnInit.trig(CreateCastTrigger)
end