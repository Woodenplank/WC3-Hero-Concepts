do
    --------------------------------------- Requires SpellTemplate.lua -----------------------------------
    --------------------------------------- Requires DragonsBreath_head.lua -----------------------------------

    local DragonsBreathSpellObj = Spell:Create("A01F", "point")
    local function dbcast()
        if GetSpellAbilityId() ~= DragonsBreathSpellObj.id then
            return
        end

        local this = DragonsBreathSpellObj:NewInstance()
        local dmg = this.herodur
        local dps = dmg/20
        local max_dist = this.range + 200
        local headcount = 6
        local facing = AngleBetweenCoords(this.cast_x, this.targ_x, this.cast_y, this.targ_y)

        local dragonheads = {}
        local params = {
            source_u = this.caster,
            aoe = this.aoe,
            dist = 10,
            ang = facing,
            pinspawn_counter = -3
        }
        for i=1,headcount do
            local hd = dragonhead:create(params)
            hd.dist_end = max_dist + math.random(-20,20)
            hd.x = this.cast_x + hd.dist * math.cos(hd.ang)
            hd.y = this.cast_y + hd.dist * math.sin(hd.ang)
            hd.handle = AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", hd.x, hd.y)
            BlzSetSpecialEffectZ(hd.handle, 75)
            table.insert(dragonheads, hd)
        end

        -- Objects
        local already_damaged = CreateGroup()
        local ug = CreateGroup()
        local cond = Condition(function() 
            local fu = GetFilterUnit()
            return
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(fu)
		end)
        local cond2 = Condition(function() 
            local fu = GetFilterUnit()
            return
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
            and not IsUnitInGroup(fu, already_damaged)
			and not BlzIsUnitInvulnerable(fu)
		end)
        local t = CreateTimer()

        -- constants for periodic movement        
        local t_interval=1/40
        local reduction=math.floor(255/(this.normaldur/t_interval)) -- alpha ranges 0 (transparent) to 255 (full)
        local dps_counter_max = 1/t_interval
        local pinspawn_counter_max = (1/(4*t_interval))
        local stepsize = 10
        -- begin
        TimerStart(t, t_interval, true, function()
            local total_finished=0
            for idx,head in pairs(dragonheads) do
                if head.dist >= head.dist_end then
                    if head.handle then
                        DestroyEffect(head.handle)
                        head.handle = nil
                    end
                    if head.is_empty() then
                        total_finished = total_finished + 1
                    end
                else
                    -- move "dragon breath"/head
                    head:advance(stepsize)
                    -- collision damage (and avoid multiple strikes)
                    GroupEnumUnitsInRange(ug, head.x, head.y, this.aoe, cond2)
                    ForGroup(ug, function()
                        pu = GetEnumUnit()
                        UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                        GroupAddUnit(already_damaged, pu)
                    end)

                    -- create new pin; append to (end of) table
                    if head:update_counter(pinspawn_counter_max) then
                        head:add_pin(this.normaldur, dps)
                    end
                end
                -- update old pins
                head:update_pins(t_interval, reduction)
            end

            -- Ending + cleanup
            if (total_finished==headcount) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
                DestroyGroup(already_damaged)
                DestroyCondition(cond)
                DestroyCondition(cond2)
            end
        end)
        -- END --
    end
    DragonsBreathSpellObj:MakeTrigger(dbcast)
end
