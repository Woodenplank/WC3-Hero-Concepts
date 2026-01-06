do
    --[[
    Spawns an unstable Sun at the target area, burning nearby enemies for terrible, terrible damage.
    If struck by a Falling Star, the Sun will collapse into a black hole, which pulls in nearby foes. |nLasts <A013:ANcl,Dur1> seconds.

    |cffffcc00Level 1|r - <A00B:ANcl,HeroDur1> damage per second.
    |cffffcc00Level 2|r - <A00B:ANcl,HeroDur2> damage per second.
    |cffffcc00Level 3|r - <A00B:ANcl,HeroDur3> damage per second.
    ]]
    local function CollapseSun_X()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= AST_id_collapsesun then
            return
        end

        -- Getters
        local u = GetTriggerUnit()
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        local lvl = GetUnitAbilityLevel(u, abilId) - 1
    
        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local tinterval = 0.05
        local sfx = AddSpecialEffect("Star_Red.mdx", x, y)
        BlzSetSpecialEffectZ( sfx, 125.0 )
        DestroyEffect(AddSpecialEffect("Shining Flare.mdx", x, y)) -- pretty spawning effect

        -- Stats
        local dmg = GetAbilityField(AST_id_collapsesun, "herodur", lvl) * tinterval
        local aoe = GetAbilityField(AST_id_collapsesun, "area", lvl)
        local dur = GetAbilityField(AST_id_collapsesun, "normaldur", lvl)

        -- Check
        local Transformed = false
        SunCheckDummy = CreateUnit(GetOwningPlayer(u), FourCC("e004"),x,y,270)

        -- Arcane Almanac crit stats fetch
        local critmod = GetAlmaCritmod(u)
        local critchance = GetAlmaCritchance(u)
        local moddeddmg = dmg

        -- Periodicity --
        TimerStart(t, tinterval, true, function()
            if not Transformed then
                -- Select units in AoE; do damage; check for SunDummy
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
                    elseif (BlackHoleChecks[GetHandleId(enemy)] == true) then
                        -- Run transformation to black hole
                        RemoveUnit(enemy)
                        Transformed = true
                        DestroyEffect(sfx)
                        DestroyEffect(AddSpecialEffect("DarkLightning.mdx", x, y))
                        local Voidsfx = AddSpecialEffect("Void Disc.mdx", x, y)
                        dmg = dmg * 1.5 / 20
                    end -- -- -- -- -- -- --
                end)
            else
                --[[ If Transformed == TRUE...
                    Do damage and pull towards center ]]
                GroupEnumUnitsInRange(ug, x, y, aoe, nil)
                ForGroup(ug, function()
                    local enemy = GetEnumUnit()
                    if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                        -- roll for crit damage
                        if (critmod > 1.0) then
                            if (math.random() <= critchance) then
                                UnitDamageTarget(u, enemy, dmg*critmod, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                            end
                        else -- No crit; do regular damage
                            UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        end
                        local enemy_x = GetUnitX(enemy)
                        local enemy_y = GetUnitY(enemy)
                        local ang = AngleBetweenCoords(enemy_x, x, enemy_y, y)
                        SetUnitX(enemy, enemy_x + 5 * math.cos(ang))
                        SetUnitY(enemy, enemy_y + 5 * math.sin(ang)) 
                    end
                end)
            end
            
            -- Try to end the spell
            dur = dur - tinterval
            if dur == 0 then
                DestroyGroup(ug)
                PauseTimer(t)
                DestroyTimer(t)
                if Transformed then
                    DestroyEffect(Voidsfx)
                else
                    DestroyEffect(sfx)
                    DestroyEffect(AddSpecialEffect("Shining Flare.mdx", x, y)) -- pretty de-spawning effect
                end
                RemoveUnit(SunCheckDummy)
            end
        end)
        -- END --
    end

    local function CreateCollapseSunTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, CollapseSun_X)
    end

    OnInit.trig(CreateCollapseSunTrig)
end