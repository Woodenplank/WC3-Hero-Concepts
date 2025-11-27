do
    --[[

    ]]
    local function CollapseSun_X()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A00C") then
            return
        end

        -- Getters
        local u = GetTriggerUnit()
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        local lvl = GetUnitAbilityLevel(u, abilId) - 1
    
        -- Objects
        local t = CreateTimer()
        local tinterval = 0.5
        local sfx = AddSpecialEffect("sun_red", x, y)
        BlzSetSpecialEffectZ( sfx, 125.0 )

        -- Stats
        local dmg = GetAbilityField(FourCC('A00C'), "herodur", lvl) * tinterval
        local aoe = GetAbilityField(FourCC('A00C'), "area", lvl)
        local dur = GetAbilityField(FourCC('A00C'), "normaldur", lvl)

        -- Check
        local Transformed = false

        -- Periodicity --
        TimerStart(t, tinterval, true, function()
            if not Transformed then
                -- Select units in AoE; do damage; check for SunDummy
                GroupEnumUnitsInRange(ug, x, y, aoe, nil)
                ForGroup(ug, function()
                    local enemy = GetEnumUnit()
                    if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                        UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    elseif (BlackHoleChecks[GetHandleId(enemy)]) then
                        -- Run transformation to black hole
                        RemoveUnit(enemy)
                        Transformed = true
                        DestroyEffect(sfx)
                        DestroyEffect(AddSpecialEffect("DarkLightning.mdx", x, y))
                        Voidsfx = AddSpecialEffect("Void Disc.mdx", x, y)
                        dmg = dmg * 1.5 / 20
                        tinterval = 0.05
                    end -- -- -- -- -- -- --
                end)
            else
                --[[ If Transformed == TRUE...
                    Do damage and pull towards center ]]
                GroupEnumUnitsInRange(ug, x, y, aoe, nil)
                ForGroup(ug, function()
                    local enemy = GetEnumUnit()
                    if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                        UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
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
                end
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