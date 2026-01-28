do
    ____id_frozenorb = FourCC('____')
    local Orb = Orb or require("Orb.lua")

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
        local orb = Orb:create(
            origin = {init_x, init_y, 100},
            destination = {end_x, end_y, 100},
            coords = {init_x, init_y, 100},
            damage = dmg,
            area = aoe,
            model = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl",
            lightning = "CHIM",
            speed = 10
        )
        BlzSetSpecialEffectScale(orb.handle, 2.0)

        local t = CreateTimer()
        local t_interval=0.05
        count = 0
        TimerStart(t, t_interval, true, function()
            -- Roll the ball
            nx,ny = PolarStep(orb.coords.x, orb.coords.y, orb.speed, ang)
            orb.update({nx,ny,orb.z})

            -- we count every 0.05 seconds; only do damage every 0.7/0.05 = 14th interval
            count = count + 1
            if math.fmod(count,14) then
                orb:zap_area(caster)
            end
            --attempt to end and clean up
            dist = dist - orb.speed
            if (dist<=0) then
                PauseTimer(t)
                DestroyTimer(t)
                orb:destroy()
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