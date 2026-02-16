-- this uses ProjectileType.lua
do
    --- every boolean in a table is true
    --- otherwise return false
    local function every(tab)
        for _,b in pairs(tab) do
            if b==false then return false end
        end
        return true
    end


    --[[ TODO:
    Probably better do to this with a dummy ability that gets removed/added to the 
    units as invulnerability is turned on/off.
    They're not player units any way, so no one will see it.
    ]]
    local invul_group = CreateGroup()
    local function ignoredamage()
        local instance = CreateFromEvent()
        if not IsUnitInGroup(instance.target.unit, invul_group) then
            return
        end
        BlzSetEventDamage(0)
        -- END --
    end


    -----------------------------------------------------

    local function shadowproj()
        -- insert conditions here --

        -- stats
        local enemy_u = nil
        local enemy_p = Player(12)
        local cx, cy = GetUnitX(enemy_u), GetUnitY(enemy_u)
        local proj_utype = FourCC("")
        local spawn_offset = 750
        local spawn_count = 4

        -- spawns
        local ang = math.pi/4
        local projections={}
        for i=1,spawn_count do
            ang = ang + math.pi/2
            local nx,ny = PolarStep(cx,cy, spawn_offset, ang)
            local face = AngleBetweenCoords(nx, cx, ny, cy)
            local u = CreateUnit(enemy_p, proj_utype, nx, ny, face)
            SetUnitVertexColor(u, 175, 50, 175, 255) -- r/g/b/alpha
            table.insert(projections, u)
        end

        -- Periodic movement
        --[[
            Outwards pattern is circular twirly-whirly
            Inwards pattern is straight-shot back to center.
        ]]
        local t = CreateTimer()
        local t_interval = 10
        local flip = false
        TimerStart(t, t_interval, true, function()
            local is_proj_dead={}
            for i,v in ipairs(projections) do
                ClearGroup(invul_group)
                if flip then
                    if (i==1 or i==3) then
                        SetUnitVertexColor(v, 175, 50, 175, 100)
                        GroupAddUnit(invul_group, v)
                    else
                        SetUnitVertexColor(v, 175, 50, 175, 255)
                else
                    if (i==2 and i==4) then
                        SetUnitVertexColor(v, 175, 50, 175, 100)
                        GroupAddUnit(invul_group, v)
                    else
                        SetUnitVertexColor(v, 175, 50, 175, 255)
                end
                -- update live/dead bools
                table.insert(IsUnitType(v, UNIT_TYPE_DEAD))
            end
            flip = not flip

            -- invulnerability settings... UP

            --ending
            if every(is_proj_dead) then
                PauseTimer(t)
                DestroyTimer(t)
                --DestroyGroup(invul_group) ???
                --- activate another phase ---
            end
        end)
        -- END --
    end

    -- Build trigger --
    local function CreateTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, --[[------- INSERT EVENT HERE -------]])
        TriggerAddAction(tr, shadowproj)
    end
    OnInit.trig(CreateTrig)
end