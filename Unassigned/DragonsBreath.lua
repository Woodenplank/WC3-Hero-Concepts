do
--  this uses SpellTemplate.lua
--  all this pin/head bollocks could probably be made more 
--  cleanly with metatable setup, and fewer indentations.
--  TOO BAD!
    local DragonsBreathSpellObj = Spell:Create("fourcc", "point")

    function dbcast()
        if GetSpellAbilityId() ~= DragonsBreathSpellObj.id then
            return
        end

        local this = DragonsBreathSpellObj:NewInstance()
        local dmg = this.herodur
        local dps = dmg/20
        local max_dist = this.range
        local headcount = 7
        local facing = AngleBetweenCoords(this.cast_x, this.targ_x, this.cast_y, this.targ_y)

        local dragonheads = {}
        for i=1,headcount do
            dragonheads[i] = {
                dist_end = max_dist + math.random(-20,20),
                dist = 15,
                ang = facing + math.random(-math.pi/8, math.pi/8),
                x = this.cast_x + dist * math.cos(ang),
                y = this.cast_y + dist * math.sin(ang),
                handle = AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", x, y),
                BlzSetSpecialEffectZ(handle,50)
                --alpha = 1.0
                pinspawn_counter=0
                pins = {},
            }
        end

        -- Objects
        local already_damaged = CreateGroup()
        local ug = CreateGroup()
        local cond = Condition(function() return
            local fu = GetFilterUnit()
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(fu)
		end)
        local cond2 = Condition(function() return
            local fu = GetFilterUnit()
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
            and not IsUnitInGroup(fu, already_damaged)
			and not BlzIsUnitInvulnerable(fu)
		end)
        local t = CreateTimer()

        -- constants for periodic movement        
        local t_interval=0.05
        local reduction=(this.normaldur/t_interval)
        local dps_counter_max = 1/t_interval
        local pinspawn_counter_max = 1/t_interval
        local stepsize = 15

        -- begin
        for idx,head in pairs(dragonheads) do
            if head[dist_end] >= head[dist] then
                DestroyEffect(head[handle])
                dragonsheads.remove(idx)
            else
                head[dist] = head[dist] + stepsize
                --[[ actually the distance travelled is variable, depending on angle, and should be
                        > nx = ...
                        > ny = ...
                        > head[dist] = head[dist] + Distance(nx, head[x], ny, head[y])
                but this seems computationally expensive, for a pretty small difference.
                the net result is that the abillity will have somewhat shorter range. ]]
            end

            -- collision damage (and avoid multiple strikes)
            GroupEnumUnitsInRange(ug, pin[x], pin[y], this.aoe, cond2)
            ForGroup(ug, function()
                pu = GetEnumUnit()
                UnitDamageTarget(this.caster, pu, this.dps, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                GroupAddUnit(already_damaged, ug)
            end)

            -- create new pin; append to (end of) table
            head[pinspawn_counter] = head[pinspawn_counter]+1
            if head[pinspawn_counter] >= pinspawn_counter_max then
                local px, py = head[x], head[y]
                local phandle = AddSpecialEffect("Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl", px, py)
                local alpha = 1.0
                local lifetime = this.normaldur
                head[pins].insert({x = px, y = py, ph = phandle, a=alpha, c = dps_counter, tm = lifetime})
                head[pinspawn_counter] = 0
            end
            
            -- update old pins
            for pinnumber,pin in head[pins] do
                -- pin alpha fade
                pin[a] = pin[a]-reduction
                BlzSetSpecialEffectAlpha(pin[ph], pin[a])
                -- pin area burn
                pin[c] = pin[c]+1
                if pin[c] >= dps_counter_max then
                    GroupEnumUnitsInRange(ug, pin[x], pin[y], this.aoe, cond)
                    ForGroup(ug, function()
                        pu = GetEnumUnit()
                        UnitDamageTarget(this.caster, pu, this.dps, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                        --Abilities\Spells\Human\FlameStrike\FlameStrikeDamageTarget.mdl
                    end)
                    pin[c] = 0
                end
                -- pin expiration
                pin[tm] = pin[tm] - t_interval
                if pin[tm] <= 0 then
                    DestroyEffect(pin[handle])
                    head.remove(pinnumber)
                end
            end
            -- move "dragon breath"/head
            head[ang] = head[ang] + math.random(-5,5)
            nx, ny = PolarStep(head[x], head[y], stepsize, head[ang])
            BlzSetSpecialEffectX(head[handle], nx, ny)
            head[x] = nx
            head[y] = ny
        end
        -- final cleanup? The table of dragonheads should be EMPTY
        --DestroyGroup(ug)
        --DestroyGroup(already_damaged)
        --DestroyCondition(cond)
        --DestroyCondition(cond2)
        --PauseTimer(t)
        --DestroyTimer(t)
        -- END --
    end
    DragonsBreathSpellObj:MakeTrigger(dbcast)
end