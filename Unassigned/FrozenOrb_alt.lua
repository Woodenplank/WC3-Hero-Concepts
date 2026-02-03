-- This spell is called Frozen Orb in some references due to being inspired by the eponymous Mage's spell from World of Warcraft; Mists of Pandaria
-- In spite of this, it very much uses lightning effects and shit.

do
    ____id_orblightning = FourCC('A01B')

    local function OrbLightningCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= ____id_orblightning then
			return
		end

        -- Getters
        local caster= GetTriggerUnit()
        local alv = GetUnitAbilityLevel(caster, ____id_orblightning) - 1
        local dmg = GetAbilityField(____id_orblightning, "herodur", alv) + addSP(caster, 1.2)
        local aoe = GetAbilityField(____id_orblightning, "aoe", alv)
        local dist= GetAbilityField(____id_orblightning, "range", alv) + 300

        -- Destination = __MAX__ distance __TOWARDS__ target point
        local init_x, init_y = GetUnitX(caster), GetUnitY(caster)
        local end_x, end_y = PolarStep(init_x, init_y, dist, AngleBetweenCoords(init_x, GetSpellTargetX(), init_y, GetSpellTargetY()) )

        -- Orb object
        local orb = Orb:create({
            origin = {x = init_x, y = init_y, z=100},
            destination = {x = end_x, y = end_y, z=100},
            area = aoe,
            damage = dmg,
            model = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl",
            scale = 2.0,
            speed = 10
        })

        -- Add aoe-lightning-attack functionality
        function orb:zap_area(source)
            -- Setup target filter
            local source_p = GetOwningPlayer(source)
            local ug = CreateGroup()
            local cond = Condition(function()
                local fu = GetFilterUnit()
                return IsUnitEnemy(fu, source_p) and not IsUnitType(fu, UNIT_TYPE_DEAD) and not IsUnitType(fu, UNIT_TYPE_STRUCTURE) and not BlzIsUnitInvulnerable(fu)
            end)
            -- loop through unit group
            GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.area, cond)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                UnitDamageTarget(source, pu, self.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)

                local pu_x, pu_y = GetUnitX(pu), GetUnitY(pu)
                local chain = AddLightningEx("CHIM", false, self.coords.x, self.coords.y, self.coords.z, pu_x, pu_y, 50)
                DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", pu_x, pu_y))
                local t_lightning = CreateTimer()
                TimerStart(t_lightning, 0.33, false, function()
                    DestroyLightning(chain)
                    PauseTimer(t_lightning)
                    DestroyTimer(t_lightning)
                end)
            end)
            ---- cleanup ----
            DestroyGroup(ug)
            DestroyCondition(cond)
        end

        -- Run the orb
        local t = CreateTimer()
        local t_interval=0.05
        local count = 0
        TimerStart(t, t_interval, true, function()
            orb:step()
            -- we count every 0.05 seconds; only do damage every 0.7/0.05 = 14th interval
            count = count + 1
            if count==14 then
                orb:zap_area(caster)
                count = 0
            end
            --attempt to end and clean up
            dist = dist - orb.speed
            if (dist<=0) then
                PauseTimer(t)
                DestroyTimer(t)
                orb:destroy()
            end
        end)
        -- END --
    end


    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, OrbLightningCast)
    end

    OnInit.trig(CreateCastTrigger)
end