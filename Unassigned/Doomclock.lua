-- this uses ProjectileType.lua
do

    doomclock_test_id = FourCC('A01M')

    local function doomclock()
        -- insert conditions here --
        --- TESTING BLOCK ---
        local abilId = GetSpellAbilityId()
		if abilId ~= spinster_test_id then
			return
		end
        ----------------------
        -- stats
        local enemy_u = GetTriggerUnit() -- this is for testing purposes only
        local z_off=50
        local enemy_p = Player(0)
        local damage = 100
        local max_area = 1000
        local coll = 90
        local orb_count = 12
        local cx, cy = GetUnitX(enemy_u), GetUnitY(enemy_u)
        local circuit_time = 15

        -- projectiles
        local orbs={}
        for i=1,orb_count do
            local offset = (1-2*i)*80
            local o = Proj:create({
                origin = {x = this_x + offset, y = cy, z=z_off-25},
                destination = {x = cx, y = cy, z=z_off-25},
                model = "ShadowOrbMissile v1.2.mdx",
                source = enemy_u,
                scale = 1.0,
                collision = coll,
            })
            table.insert(orbs, o)
        end

        local anim_dur = 1.5
        local t_anim = CreateTimer()
        TimerStart(t_anim, anim_dur, true, function()
            SetUnitAnimation(enemy_u, "spell channel")
        end)

        -- lightning
        local nx, ny = PolarStep(cx,cy, max_area, 3/4 * math.pi)
        local l = AddLightningEx("AFOD", false, cx, cy, z_off, nx, ny,z_off)
        SetLightningColor(l, 0.85, 0.5, 1, 1)

        -- Periodic movement
        local t = CreateTimer()
        local t_interval = 1/40
        local angstep = (2*math.pi/circuit_time) * t_interval
        local ang_lag = 2*math.pi/orb_count

        local spacing = math.floor(max_area/orb_count)
        local ang = 3/2 * math.pi
        TimerStart(t, t_interval, true, function()
            ang = ang+angstep
            -- lightning
            local nx, ny = PolarStep(cx,cy, max_area, ang)
            MoveLightningEx(l, false, cx, cy, z_off, nx, ny, z_off)

            -- move orbs accordingly
            for i,o in ipairs(orbs) do
                local nx, ny = PolarStep(cx,cy, i*spacing, ang)
                o.coords.x = nx
                o.coords.y = ny
                o:hitscan()
                o:update()
            end

            -- destructor/finish
            if ang >= 7/2 * math.pi then
                for i, o in ipairs(orbs) do
                    o:destroy()
                end
                PauseTimer(t)
                DestroyTimer(t)
                DestroyLightning(l)
            end
        end)
        -- END --
    end

    -- Build trigger --
    local function CreateTrig()
        local tr = CreateTrigger()
        --TriggerRegisterAnyUnitEventBJ(tr, --[[------- INSERT EVENT HERE -------]])
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)   -- for testing purposes
        TriggerAddAction(tr, doomclock)
    end
    OnInit.trig(CreateTrig)
end