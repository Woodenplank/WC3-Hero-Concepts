do
    ____id_frozenorb = FourCC('____')

    local function FrozenOrbCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= ____id_frozenorb then
			return
		end

        -- Getters
        local caster= GetTriggerUnit()
        local alv = GetUnitAbilityLevel(caster, ____id_frozenorb) - 1
        --local dur = GetAbilityField(____id_frozenorb, "normaldur", alv)
        local dmg = GetAbilityField(____id_frozenorb, "herodur", alv) + addSP(caster, 1.2)
        local aoe = GetAbilityField(____id_frozenorb, "aoe", alv)
        local dist= GetAbilityField(____id_frozenorb, "range", alv)

        -- Main coordinates
        local init_x, init_y = GetUnitX(caster), GetUnitY(caster)
        local orb_x, orb_y = init_x, init_y
        local end_x, end_y = GetSpellTargetX(), GetSpellTargetY()
        local ang = AngleBetweenCoords(init_x, end_x, init_y, end_y)

        -- Orb
        local orb_sfx="Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl"
        local orb_lightning = "CHIM"
        local orb = AddSpecialEffect(orb_sfx, orb_x, orb_y)
        --BlzSetSpecialEffectAlpha(orb, real)
        BlzSetSpecialEffectScale(orb, 2.0)
        BlzSetSpecialEffectHeight(orb, 100)

        -- Objects
        local ug = CreateGroup()
        local cond = Condition(function() return 
			IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(caster)) 
            and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) 
            and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) 
            and not BlzIsUnitInvulnerable(GetFilterUnit())
		end)

        local t = CreateTimer()
        local t_interval=0.05
        local stepsize=10
        local count = 0
        TimerStart(t, t_interval, true, function()
            -- Roll the ball
            orb_x, orb_y = PolarStep(orb_x, orb_y, stepsize, ang)
            BlzSetSpecialEffectX(orb, orb_x)
            BlzSetSpecialEffectY(orb, orb_y)

            -- we count every 0.05 seconds; only do damage every 0.7/0.05 = 14th interval
            count = count + 1
            if (count==14) then
                GroupEnumUnitsInRange(ug, orb_x, orb_y, aoe, cond)
                ForGroup(ug, function()
                    pu = GetEnumUnit()
                    UnitDamageTarget(caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    
                    local pu_x, pu_y = GetUnitX(pu), GetUnitY(pu)
                    local chain = AddLightningEx(orb_lightning, false, orb_x, orb_y, 100, pu_x, pu_y, 50)
                    local t_lightning = CreateTimer()
                    TimerStart(t_lightning, 0.5, false, function()
                        DestroyLightning(chain)
                        PauseTimer(t_lightning)
                        DestroyTimer(t_lightning)
                    end)
                end)
                count = 0
            end

            --attempt to end and clean up
            dist = dist - stepsize
            if (dist<=0) then
                PauseTimer(t)
                DestroyTimer(t)
                --
                PauseTimer(t_dmg)
                DestroyTimer(t_dmg)
                DestroyGroup(ug)
                DestroyCondition(cond)
                --
                DestroyEffect(orb)
                -- explosive ending???
                --DestroyEffect(AddSpecialEffect(..., x, y))
            end
        end)
        -- END --
    end

    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, FrozenOrbCast)
    end

    OnInit.trig(CreateCastTrigger)
end