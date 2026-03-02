-- this uses orb.lua
-- TODO: switch to projectile type. Although it doesn't matter much here (yet).
do
-----------------------------------------------------
spinster_test_id = FourCC('A001') -- Testing type ---
-----------------------------------------------------

    local function spinster()
        -- insert conditions here --
        --- TESTING BLOCK BEGIN ---
        local abilId = GetSpellAbilityId()
		if abilId ~= spinster_test_id then
			return
		end
        --- TESTING BLOCK END ---

        -- stats
        local enemy_u = GetTriggerUnit()    -- for testing puposes only
        local enemy_p = Player(0)           -- for testing puposes only
        local z_off=50
        local damage = 100
        local max_area = 1000
        local coll = 90
        local orb_count = 12
        local cx, cy = GetUnitX(enemy_u), GetUnitY(enemy_u)
        local circuit_time = 15
        local loops = 5

        -- orbs
        local orbs={}
        for i=1,orb_count do
            local offset = (1-2*i)*80
            local o = Orb:create({
                origin = {x = cx + offset, y = cy, z=z_off},
                destination = {x = cx, y = cy, z=z_off},
                model = "ShadowOrbMissile v1.2.mdx",
                source = enemy_u,
                scale = 1.0,
                area = coll,
            })
            table.insert(orbs, o)
        end

        -- prevent damage stacking
        -- units hit by the orbs will be in a safe group for <dmg_cd> seconds.
        local ug_recently = CreateGroup()
        local dmg_cd = 0.5

        -- Do the dance!
        -- Outwards pattern is circular twirly-whirly
        -- Inwards pattern is straight-shot back to center.
        local t = CreateTimer()
        local t_interval = 1/40
        local radialstep = (max_area/circuit_time) * t_interval
        local ang_step = ((2*math.pi * loops)/circuit_time) * t_interval
        local ang_lag = 2*math.pi/orb_count

        local dist = 0
        local ang = 0
        local returning = false
        TimerStart(t, t_interval, true, function()
            -- destructor/finish
            if dist <= 90 and returning then
                for i, o in ipairs(orbs) do
                    o:destroy()
                end
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug_recently)
            end

            -- return pattern reset
            if dist >= max_area then
                returning = true
            end

            local cx, cy = GetUnitX(enemy_u), GetUnitY(enemy_u)
            -- move orbs accordingly
            if not returning then
                dist = dist + radialstep
                ang = ang + ang_step
                for i,o in ipairs(orbs) do
                    local nx, ny = PolarStep(cx,cy, dist, ang+i*ang_lag)
                    o.coords.x = nx
                    o.coords.y = ny
                    o:update()
                end
            else
                dist = dist - 20
                for i,o in ipairs(orbs) do
                    local nx, ny = PolarStep(cx,cy, dist, i*ang_lag)
                    o.coords.x = nx
                    o.coords.y = ny
                    o:update()
                end
            end
            --------- custom damage functionality begin ---------------
            --[[This could probably be worked in as an extra member function... TOO BAD!]]
            for _,o in ipairs(orbs) do
                local cond = Condition(function() local fu= GetFilterUnit()
                    return IsUnitEnemy(fu, o.owner)
                    and not IsUnitType(fu, UNIT_TYPE_DEAD)
                    and not IsUnitInGroup(fu, ug_recently)
                end)
                
                local ug = CreateGroup()
                GroupEnumUnitsInRange(ug, o.coords.x, o.coords.y, o.area, cond)
                ForGroup(ug, function()
                    local pu = GetEnumUnit()
                    UnitDamageTarget(o.source, pu, damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    GroupAddUnit(ug_recently, pu)
                    local t_recently = CreateTimer()
                    TimerStart(t_recently, 2.0, false,function()
                        GroupRemoveUnit(ug_recently, pu)
                        PauseTimer(t_recently)
                        DestroyTimer(t_recently)
                    end)
                end)
                DestroyGroup(ug)
                DestroyCondition(cond)
            end
            --------- custom damage functionality end ---------------
        end)
        -- END --
    end

    -- Build trigger --
    local function CreateTrig()
        local tr = CreateTrigger()
        --TriggerRegisterAnyUnitEventBJ(tr, --[[------- INSERT EVENT HERE -------]])
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)   -- for testing purposes
        TriggerAddAction(tr, spinster)
    end
    OnInit.trig(CreateTrig)
end