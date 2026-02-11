-- this uses SpellTemplate.lua
-- this uses Orb.lua
do
    -- For getting proper z values for Special Effects
    local location = Location(0., 0.)
    local rect = Rect(0., 0., 0., 0.)

    local function GetLocZ(x, y)
        MoveLocation(location, x, y)
        return GetLocationZ(location)
    end

    local function GetUnitZ(unit)
        return GetLocZ(GetUnitX(unit), GetUnitY(unit)) + GetUnitFlyHeight(unit)
    end

    -----------------------------------------------------

    local ShadowSpinSpellObj = Spell:Create("A005", "instant")
    local function sscast()
        if GetSpellAbilityId() ~= ShadowSpinSpellObj.id then
            return
        end

        -- getters
        local this = ShadowSpinSpellObj:NewInstance()
        local dmg = this.herodur/2
        local dmg_collsion = this.range
        local loops = 5
        local z_off=100--GetUnitZ(this.caster)+100

        -- blizzard objects
        local area_sfx = AddSpecialEffectTarget("WitheringPresence.mdx", this.caster, "origin")
        BlzSetSpecialEffectScale(area_sfx, 1.2)

        local ug_total = CreateGroup()
        local cond1 = Condition(function()
            local fu = GetFilterUnit()
            return
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(fu)
		end)

        local ug_alreadyDamaged = CreateGroup()
        local cond2 = Condition(function()
            local fu = GetFilterUnit()
            return
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
            and not IsUnitInGroup(fu, ug_alreadyDamaged)
			and not BlzIsUnitInvulnerable(fu)
		end)

        -- orbs
        local orbs={}
        for i=0,1 do
            local offset = (1-2*i)*80
            local o = Orb:create({
            origin = {x = this.cast_x + offset, y = this.cast_y, z=z_off},
            destination = {x = this.cast_x, y = this.cast_y, z=z_off},
            model = "ShadowOrbMissile v1.2.mdx",
            source = this.caster,
            scale = 1.0,
            area = 80,
            })
            function o:onHit()
                local ug_t = CreateGroup()
                GroupEnumUnitsInRange(ug_t, o.coords.x, o.coords.y, o.area, cond2)
                ForGroup(ug_t, function()
                    local pu = GetEnumUnit()
                    UnitDamageTarget(this.caster, pu, dmg_collsion, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    GroupAddUnit(ug_alreadyDamaged, pu)
                end)
                DestroyGroup(ug_t)
            end
            table.insert(orbs, o)
        end

        -- Periodic damage
        local t_total = CreateTimer()
        TimerStart(t_total, 0.5, true, function()
            GroupEnumUnitsInRange(ug_total, GetUnitX(this.caster), GetUnitY(this.caster), this.aoe, cond1)
            ForGroup(ug_total, function()
                local pu = GetEnumUnit()
                UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            end)
        end)

        -- Periodic movement
        local t_move = CreateTimer()
        local t_interval = 1/40
        local radialstep = (2*this.aoe/(this.normaldur)) * t_interval   -- covers aoe twice in the duration of the spell
        local angstep = ((2*math.pi * loops)/this.normaldur) * t_interval
        local dist = 0
        local ang = 0
        local returning = false
        TimerStart(t_move, t_interval, true, function()
            -- Move orbs in twirly-whirly motions
            if dist <= 90 and returning then
                for i, o in ipairs(orbs) do
                    o:destroy()
                end
                PauseTimer(t_move)
                DestroyTimer(t_move)
                -- additional cleanup
                PauseTimer(t_total)
                DestroyTimer(t_total)
                DestroyEffect(area_sfx)
                DestroyGroup(ug_total)
                DestroyGroup(ug_alreadyDamaged)
                DestroyCondition(cond1)
                DestroyCondition(cond2)
            end
            if dist >= this.aoe then
                returning = true
                GroupClear(ug_alreadyDamaged)
            end

            -- update distance (outwards or inwards)
            if not returning then
                dist = dist + radialstep
            else
                dist = dist - radialstep
            end

            -- move orbs accordingly
            ang = ang + angstep
            local cx, cy = GetUnitX(this.caster), GetUnitY(this.caster)
            for i,o in ipairs(orbs) do
                local nx, ny = PolarStep(cx,cy, dist, ang+i*math.pi) -- one orb lags by ½ period
                o.coords.x = nx
                o.coords.y = ny
                o:onHit()
                o:update()
            end
            -- end of orb movement --
        end)
        -- END --
    end
    ShadowSpinSpellObj:MakeTrigger(sscast)
end