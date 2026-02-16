-- this uses ProjectileType.lua
do

    local function doomclock()
        -- insert conditions here --

        -- stats
        local enemy_u = nil
        local enemy_p = Player(12)
        local damage = 100
        local max_area = 1000
        local coll = 90
        local orb_count = 20
        local cx, cy = GetUnitX(enemy_u), GetUnitY(enemy_u)
        local circuit_time = 15

        -- orbs
        local orbs={}
        for i=1,orb_count do
            local offset = (1-2*i)*80
            local o = Orb:create({
                origin = {x = this.cast_x + offset, y = this.cast_y, z=z_off},
                destination = {x = this.cast_x, y = this.cast_y, z=z_off},
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
        local l = CreateLightning("AFOD", false, cx, nx, cy, ny)
        SetLightningColor(l, 1, 0, 1, 1)

        -- Periodic movement
        local t = CreateTimer()
        local t_interval = 1/40
        local angstep = (2*math.pi/circuit_time) * t_interval
        local ang_lag = 2*math.pi/orb_count

        local spacing = math.floor(max_area/orb_count)
        local ang = 3/4 * math.pi
        TimerStart(t, t_interval, true, function()
            ang = ang+angstep
            -- lightning
            local nx, ny = PolarStep(cx,cy, max_area, ang)
            MoveLightning(l, false, cx, nx, cy, ny)

            -- move orbs accordingly
            for i,o in ipairs(orbs) do
                local nx, ny = PolarStep(cx,cy, i*dist, ang)
                o.coords.x = nx
                o.coords.y = ny
                o:hitscan()
                o:update()
            end

            -- destructor/finish
            if ang <= 11/4 * math.pi then
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
        TriggerRegisterAnyUnitEventBJ(tr, --[[------- INSERT EVENT HERE -------]])
        TriggerAddAction(tr, doomclock)
    end
    OnInit.trig(CreateTrig)
end