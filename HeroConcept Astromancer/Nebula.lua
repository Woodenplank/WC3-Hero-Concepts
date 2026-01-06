do 
    --[[ See Discussion at 
        https://www.hiveworkshop.com/threads/delayed-actions-and-mui-management-in-lua.367956/

        Summons a churning vortex of stardust that deals continuous damage to enemies within target area, lasting <A003:ANcl,Dur1> seconds.
        While active, the Nebula slows enemy movement and summons Star Sprites.

        |cffffcc00Level 1|r - <A003:ANcl,HeroDur1> damage per second. <A00C:Aasl,DataA1,%>% slow.
        |cffffcc00Level 2|r - <A003:ANcl,HeroDur2> damage per second. <A00C:Aasl,DataA2,%>% slow.
        |cffffcc00Level 3|r - <A003:ANcl,HeroDur3> damage per second. <A00C:Aasl,DataA3,%>% slow.
    ]]

    local function NebulaCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= AST_id_nebula then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        local lvl = GetUnitAbilityLevel(u, AST_id_nebula) - 1
 
        -- Stats
        local dmg = GetAbilityField(AST_id_nebula, "herodur", lvl) / 2
        local aoe = GetAbilityField(AST_id_nebula, "area", lvl)
        local dur = 7.0
 
        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local sfx = AddSpecialEffect("Fire Aura.mdx", x , y)

        -- Timers
        local tinterval = 0.5
        local ticks_max = 14
        local tick = 0

        -- Arcane Almanac crit stats fetch
        local critmod = GetAlmaCritmod(u)
        local critchance = GetAlmaCritchance(u)
        local moddeddmg = dmg

        -- START --
        TimerStart(t, tinterval, true, function()
            -- Deal AoE damage
            GroupEnumUnitsInRange(ug, x, y, aoe, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                    if (critmod > 1.0) then
                        -- roll for crit damage
                        if (math.random() <= critchance) then
                            moddeddmg = dmg*critmod
                        end
                    end
                    UnitDamageTarget(u, enemy, moddeddmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                end
            end)

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
        TriggerAddAction(tr, NebulaCast)
    end

    OnInit.trig(CreateNebulaTrig)
end