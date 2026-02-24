-- this uses ProjectileType.lua
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

spinster_test_id = FourCC('A01M')

    -----------------------------------------------------

    local function spinster()
        -- insert conditions here --
        --- TESTING BLOCK ---
        local abilId = GetSpellAbilityId()
		if abilId ~= spinster_test_id then
			return
		end
        ----------------------

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
        local loops = 6

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
                collision = coll,
            })
            table.insert(orbs, o)
        end

        -- Periodic movement
        --[[
            Outwards pattern is circular twirly-whirly
            Inwards pattern is straight-shot back to center.
        ]]
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
            end

            -- return pattern reset
            if dist >= max_area then
                returning = true
                for i, o in ipairs(orbs) do
                    o:flush()
                end
            end

            -- move orbs accordingly
            if not returning then
                dist = dist + radialstep
                ang = ang + ang_step
                for i,o in ipairs(orbs) do
                    local nx, ny = PolarStep(cx,cy, dist, ang+i*ang_lag)
                    o.coords.x = nx
                    o.coords.y = ny
                    o:hitscan()
                    o:update()
                end
            else
                dist = dist - 20
                for i,o in ipairs(orbs) do
                    local nx, ny = PolarStep(cx,cy, dist, i*ang_lag)
                    o.coords.x = nx
                    o.coords.y = ny
                    o:hitscan()
                    o:update()
                end
            end
            -- end of orb movement --
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