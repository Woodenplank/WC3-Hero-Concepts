do
--  this uses SpellTemplate.lua
--  The Burning Oil effect cannot be affected by BlzSetSpecialEffectAlpha apparently
--  all this pin/head bollocks could probably be made more 
--  cleanly with metatable setup, and fewer indentations.
--  TOO BAD!
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
        for i=1,headcount do
            dragonheads[i] = {
                dist_end = max_dist + math.random(-20,20),
                dist = 5,
                ang = facing --[[ + math.random(-1,1)*(math.pi/8)]],
                x=0,
                y=0,
                handle=nil,
                --alpha = 1.0
                pinspawn_counter=-3,    --(some initial delay to prevent ULTRA STACKING at the beginning of the spell)
                pins = {}
            }
            dragonheads[i].x = this.cast_x + dragonheads[i].dist * math.cos(dragonheads[i].ang)
            dragonheads[i].y = this.cast_y + dragonheads[i].dist * math.sin(dragonheads[i].ang)
            dragonheads[i].handle = AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", dragonheads[i].x, dragonheads[i].y)
            BlzSetSpecialEffectZ(dragonheads[i].handle, 75)
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
                    -- keep looping until pins table is empty
                    local next = next
                    if (next(head.pins)==nil) then
                        total_finished = total_finished + 1
                    end
                else
                    -- move "dragon breath"/head
                    head.ang = head.ang + math.random(-10,10)*math.pi/180
                    nx, ny = PolarStep(head.x, head.y, stepsize, head.ang)
                    BlzSetSpecialEffectX(head.handle, nx)
                    BlzSetSpecialEffectY(head.handle, ny)
                    BlzSetSpecialEffectZ(head.handle, 75)
                    head.x = nx
                    head.y = ny
                    head.dist = head.dist + stepsize -- (head.dist = head.dist + Distance(nx, head.x, ny, head.y)) would be more accurate
                    
                    -- collision damage (and avoid multiple strikes)
                    GroupEnumUnitsInRange(ug, head.x, head.y, this.aoe, cond2)
                    ForGroup(ug, function()
                        pu = GetEnumUnit()
                        UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                        GroupAddUnit(already_damaged, pu)
                    end)

                    -- create new pin; append to (end of) table
                    head.pinspawn_counter = head.pinspawn_counter+1
                    if head.pinspawn_counter >= pinspawn_counter_max then
                        local px, py = head.x, head.y
                        local phandle = AddSpecialEffect("Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl", px, py)
                        BlzSetSpecialEffectScale(phandle, 0.55)
                        local alpha = 255
                        local dps_counter = 0
                        local lifetime = this.normaldur
                        table.insert(head.pins, {x = px, y = py, ph = phandle, a=alpha, c = dps_counter, tm = lifetime})
                        head.pinspawn_counter = 0
                    end
                end
                
                -- update old pins
                for pinnumber,pin in ipairs(head.pins) do
                    -- pin alpha fade
                    pin.a = pin.a-reduction
                    BlzSetSpecialEffectAlpha(pin.ph, pin.a)     -- does not seem to work with Burning Oil
                    -- pin area burn
                    pin.c = pin.c+1
                    if pin.c >= dps_counter_max then
                        GroupEnumUnitsInRange(ug, pin.x, pin.y, this.aoe, cond)
                        ForGroup(ug, function()
                            pu = GetEnumUnit()
                            UnitDamageTarget(this.caster, pu, dps, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                            --Abilities\Spells\Human\FlameStrike\FlameStrikeDamageTarget.mdl
                        end)
                        pin.c = 0
                    end
                    -- pin expiration
                    pin.tm = pin.tm - t_interval
                    if pin.tm <= 0 then
                        DestroyEffect(pin.ph)
                        table.remove(head.pins, pinnumber)
                    end
                end
                -- Done updating heads
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