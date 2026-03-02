-- requires Mine.lua
do
-----------------------------------------------------
warnwave_test_id = FourCC('A000') -- Testing type ---
-----------------------------------------------------
    local function warnwave()
        -- insert conditions here --
        --- TESTING BLOCK BEGIN ---
        local abilId = GetSpellAbilityId()
        if abilId ~= warnwave_test_id then
            return
        end
        --- TESTING BLOCK END ---
        local caster = GetTriggerUnit()

        local mine_dmg = 90
        local mine_aoe = 70
        local mine_armtime = 2.0
        paramset = {
            x=nil,
            y=nil,
            z=5,
            source = caster,
            dur = mine_armtime,
            aoe = mine_aoe,
            dmg = mine_dmg,
            scale1 = 0.8,
            modelwarn = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl",
            modelblow = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl"
        }

        local cast_x, cast_y = GetUnitX(caster), GetUnitY(caster)
        local targ_x, targ_y = GetSpellTargetX(), GetSpellTargetY()
        local ang = AngleBetweenCoords(cast_x, targ_x, cast_y, targ_y)
        local slicewidth = 100 * math.pi/180    -- 'degrees to radians'
        local ang_l = ang - slicewidth/2
        local ang_r = ang + slicewidth/2

        -- build "triangular" cone
        local spawncount = 1
        local diststep = 60
        local dist_current = diststep
        local range = 700
        local waves = math.floor(range/diststep)

        local t = CreateTimer()
        local delay = 0.3
        TimerStart(t, delay, true, function()
            if dist_current <= range then
                local angstep = (slicewidth/spawncount)
                local ang_current = ang_l-angstep/2
                for i=1, spawncount do
                    local x,y = PolarStep(cast_x, cast_y, dist_current, ang_current + angstep)
                    paramset.x = x
                    paramset.y = y
                    local bomb = Mine:create(paramset)
                    bomb:arm()
                    ang_current = ang_current + angstep
                end

                -- increment for next
                dist_current = dist_current + diststep
                spawncount = spawncount +1
            else
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)

        -- for i=1,waves do
        --     local angstep = (slicewidth/spawncount)
        --     local ang_current = ang_l-angstep/2
        --     for i=1, spawncount do
        --         local x,y = PolarStep(cast_x, cast_y, dist_current, ang_current + angstep)
        --         paramset.x = x
        --         paramset.y = y
        --         local bomb = Mine:create(paramset)
        --         bomb:arm()
        --         ang_current = ang_current + angstep
        --     end

        --     -- increment for next
        --     dist_current = dist_current + diststep
        --     spawncount = spawncount +1
        -- end
        -- ???
    end

    -- Build trigger --
    local function CreateTrig()
        local tr = CreateTrigger()
        --TriggerRegisterAnyUnitEventBJ(tr, --[[------- INSERT EVENT HERE -------]])
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)   -- for testing purposes
        TriggerAddAction(tr, warnwave)
    end
    OnInit.trig(CreateTrig)
end