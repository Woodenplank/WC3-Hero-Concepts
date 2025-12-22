do
    local shield = {}
    local effect = {}
    local sfxstring = "Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl"--"PinkMagicShield_.mdx"

    onInit(function()
        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()
        
            if damage > 0 then
                local remain = (shield[Damage.target.id] or 0) - damage

                if remain >= 0 then
                    shield[Damage.target.id] = remain

                    BlzSetEventDamage(0)
                    if remain == 0 then
                        DestroyEffect(effect[Damage.target.id])
                        effect[Damage.target.id] = nil
                        UnitRemoveAbility(Damage.target.unit, FourCC('A00F'))
                    end

                    -- ClearTextMessages()
                    -- print(GetUnitName(Damage.target.unit) .. " Shield: " .. shield[Damage.target.id])
                else
                    shield[Damage.target.id] = 0
                    BlzSetEventDamage(-remain)
                    DestroyEffect(effect[Damage.target.id])
                    effect[Damage.target.id] = nil
                    UnitRemoveAbility(Damage.target.unit, FourCC('A00F'))
                end
            end
        end)
        
        RegisterSpellEffectEvent(FourCC('A002'), function()
            -- Getters
            local u = Spell.source.unit
            local x = GetUnitX(u)
            local y = GetUnitY(u)
            local alv = GetUnitAbilityLevel(u, FourCC('A002')) - 1
            local id = Spell.source.id

            -- Stats
            local dmg = GetAbilityField(FourCC('A002'), "herodur", alv) + addSP(u, 1.8)
            local aoe = GetAbilityField(FourCC('A002'), "area", alv)
            local dur = GetAbilityField(FourCC('A002'), "normaldur", alv)
            local shieldfactor = 0.3

            -- Objects
            local ug = CreateGroup()
            local t = CreateTimer()
            local cond = Condition(function() return
                (IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(u))
                or UnitTypeCheck(GetFilterUnit(), 'e003'))
                and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
                and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
                and not BlzIsUnitInvulnerable(GetFilterUnit())
            end)

            -- Dummy ability (buff)
            UnitAddAbility(u, FourCC('A00F'))
            SetUnitAbilityLevel(u, FourCC('A00F'), alv+1)
            BlzUnitHideAbility(u, FourCC('A00F'), true)

            -- Arcane Almanac crit stats fetch
            local critmod = GetAlmaCritmod(u)
            local critchance = GetAlmaCritchance(u)
            local moddeddmg = dmg

            -- Area damage and shield
            GroupEnumUnitsInRange(ug, x, y, aoe, cond)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if (critmod > 1.0) then
                    -- roll for crit damage
                    if (math.random() <= critchance) then
                        moddeddmg = dmg*critmod
                    end
                end
                UnitDamageTarget(u, pu, moddeddmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                -- Shield (via damage interface)
                if (shield[id] or 0) == 0 then
                    print("a print!")
                    effect[id] = AddSpecialEffectTarget(sfxstring, u, "origin")
                end
                    shield[id] = moddeddmg*shieldfactor
            end)
            -- print(GetUnitName(u) .. " will block up to " .. shield[id])

            -- Duration
            TimerStart(t, dur, false, function()
                UnitRemoveAbility(u, FourCC('A00F'))
                DestroyEffect(effect[id])
                shield[id] = 0

                PauseTimer(t)
                DestroyTimer(t)            
            end)
            -- Clean memory
            DestroyGroup(ug)
            DestroyCondition(cond)
            -- END --
        end)
    end)
end