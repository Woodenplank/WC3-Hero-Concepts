do 
    --[[ See Discussion at 
        https://www.hiveworkshop.com/threads/delayed-actions-and-mui-management-in-lua.367956/]]
    --local q_dmg = { 100, 200, 300, 400 }
    --local q_aoe = { 200, 200, 200, 200 }
    --local q_dur = { 3, 4, 5, 6 }

    local function Nebula_Q()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A003") then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        local lvl = GetUnitAbilityLevel(u, abilId) - 1
 
        -- Stats
        --local dmg = q_dmg[lvl]
        --local aoe = q_aoe[lvl]
        --local dur = q_dur[lvl]
        local dmg = GetAbilityField(FourCC('A003'), "herodur", lvl) / 2
        local aoe = GetAbilityField(FourCC('A003'), "area", lvl)
        local dur = 7.0
 
        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local sfx = AddSpecialEffect("Fire Aura.mdx", x , y)

        -- Timers
        local tinterval = 0.5
        local ticks_max = 14
        local tick = 0

        -- START --
        TimerStart(t, tinterval, true, function()
            
            -- Deal AoE damage
            GroupEnumUnitsInRange(ug, x, y, aoe, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                    UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                end
            end)
    
            -- No (periodic) visual effects

            -- Star sprites
            --[[ Avoid floating point errors by some modulo arithmetic on ticks ]]
            tick = tick + 1
            if (tick%%4 == 0) then -- every 4th tick
                local new_x = x + (aoe/2) * (math.random()+math.random(-1,1))
		        local new_y = y + (aoe/2) * (math.random()+math.random(-1,1))
                local sprite = CreateUnit(GetOwningPlayer(u), FourCC('o000'), new_x, new_y, 0)
                UnitApplyTimedLifeBJ(5.0, FourCC('BTLF'), sprite)
            end
            if (tick == 10 ) then
                -- the effect takes ~2 seconds to stop animation, so we destroy it early
                DestroyEffect(sfx)
            end
            
            -- Try to end the spell
            dur = dur - tinterval
            if dur == 0 then
                DestroyGroup(ug)
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
        -- END --
    end

    local function CreateNebulaTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, Nebula_Q)
    end

    OnInit.trig(CreateNebulaTrig)
end