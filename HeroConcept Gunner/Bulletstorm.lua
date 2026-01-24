do
    RAT_id_spool=FourCC('A012')
    RAT_id_spray=FourCC('A013')

    local function bulletstorm_spoolup()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= RAT_id_spool then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local dur = GetAbilityField(RAT_id_spray, "followthrough", 0)
        local dmg = BlzGetUnitBaseDamage(u,0) -- replace with GetUnitAvgAttackDamage
        local owner = GetOwningPlayer(u)
        local pi = GetPlayerId(owner)

        -- issue order to cast the new channeling spell (Burrow)
        IssueImmediateOrderBJ(u, "burrow")

        -- Periodicity
        local t = CreateTimer()
        local tinterval = 0.10
        TimerStart(t, tinterval, true, function()
            --[[
                Since we can only get player mouse (x,y) from within a TriggeringPlayer function
                we have to get the necessary coordinates from another trigger, and then save them 
                to a global storage, which THIS timing loop accesses.
            ]]
            local unit_x = GetUnitX(u)
            local unit_y = GetUnitY(u)
            local mouse_x = GunnerSights[pi][1]
            local mouse_y = GunnerSights[pi][2]
            local ang = AngleBetweenCoords(unit_x, mouse_x, unit_y, mouse_y)
            SetUnitFacing(u, ang*(180/math.pi))

            -- Launch projectiles
            local targ_x, targ_y = PolarStep(unit_x, unit_y, 700, ang)
            local model_str1 = "Abilities\\Weapons\\GyroCopter\\GyroCopterImpact.mdl"
            local model_str2 = "Abilities\\Weapons\\GyroCopter\\GyroCopterImpact.mdl"
            local bullet_spd = 1800
            local aoe = 125
            local bullet_collision = 75
            local missile = SkillShotMissile(unit_x, unit_y, 60, targ_x, targ_y, 50, u, dmg, bullet_collision, aoe, bullet_spd, model_str1, model_str2, 1.0)
            missile:launch()

            -- Attempt to end
            dur = dur - tinterval
            if (dur<=0 or GetUnitCurrentOrder(u)~=852533) then -- order id of Burrow
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
    -- END --
    end


    --[[ Just use Chopinski's mouse utils:
    do
        -- -------------------------------------------------------------------------- --
        --                                   System                                   --
        -- -------------------------------------------------------------------------- --
        local mouse = {}
        local trigger = CreateTrigger()
        
        onInit(function()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                local player = Player(i)
                
                if GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
                    mouse[player] = {}
                    TriggerRegisterPlayerEvent(trigger, player, EVENT_PLAYER_MOUSE_MOVE)
                end
            end
            TriggerAddCondition(trigger, Condition(function()
                local player = GetTriggerPlayer()
                
                mouse[player].x = BlzGetTriggerPlayerMouseX()
                mouse[player].y = BlzGetTriggerPlayerMouseY()
            end))  
        end)
        
        -- -------------------------------------------------------------------------- --
        --                                   LUA API                                  --
        -- -------------------------------------------------------------------------- --
        function GetPlayerMouseX(player)
            return mouse[player].x or 0
        end
        
        function GetPlayerMouseY(player)
            return mouse[player].y or 0
        end
    end
    ]]


    local function bulletstorm_mousetrack()
        local p = GetTriggerPlayer()
        local pi= GetPlayerId(p)
        local mouse_x = BlzGetTriggerPlayerMouseX()
        local mouse_y = BlzGetTriggerPlayerMouseY()
        GunnerSights[pi] = {mouse_x, mouse_y}
    end


    ------------------ Create the triggers ------------------
    local function CreateBulletStormCast()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        TriggerAddAction(trg, bulletstorm_spoolup)
    end
    
     local function CreateBulletstormMouseTrack()
        local trg = CreateTrigger()
        TriggerRegisterPlayerMouseEventBJ( trg, Player(0), bj_MOUSEEVENTTYPE_MOVE )
        TriggerRegisterPlayerMouseEventBJ( trg, Player(1), bj_MOUSEEVENTTYPE_MOVE )
        TriggerAddAction(trg, bulletstorm_mousetrack)
    end

    OnInit.trig(CreateBulletstormMouseTrack)
    OnInit.trig(CreateBulletStormCast)
end