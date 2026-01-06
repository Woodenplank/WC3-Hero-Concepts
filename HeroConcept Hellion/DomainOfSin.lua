do
--[[
    Srikes a dark taint into the land beneath the Hellion's feet, dealing 200 damage to all nearby enemies; causing additional damage over time to enemies who remain. 
    The Hellion draws power from the darkness, gaining increased attack rate and life regeneration while near it.|nLasts <A00N:ANcl,Dur1> seconds.

    |cffffcc00Level 1|r - <A00N:ANcl,HeroDur1> damage per second, <S000:SCae,DataB1,%>% bonus attack rate, <A00N:ANcl,Rng1> healing per second.
    |cffffcc00Level 2|r - <A00N:ANcl,HeroDur2> damage per second, <S000:SCae,DataB2,%>% bonus attack rate, <A00N:ANcl,Rng1> healing per second.
    |cffffcc00Level 3|r - <A00N:ANcl,HeroDur3> damage per second, <S000:SCae,DataB3,%>% bonus attack rate, <A00N:ANcl,Rng3> healing per second.
]]

    local function DomSinCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= HEL_id_domsin then
            return
        end
        
            -- Getters
        local u = GetTriggerUnit()
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local alv = GetUnitAbilityLevel(u, HEL_id_domsin) - 1

        -- Stats
        local dmg = GetAbilityField(HEL_id_domsin, "herodur", alv)
        local dmg_instant=200
        local aoe = GetAbilityField(HEL_id_domsin, "area", alv)
        local heal= GetAbilityField(HEL_id_domsin, "range", alv)
        local dur = GetAbilityField(HEL_id_domsin, "normaldur", alv)

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Dummy buffer
        local dummy = CreateUnit(GetOwningPlayer(u), FourCC('e002'), x, y, 270)
        SetUnitAbilityLevel(dummy, HEL_id_domsinbuff, alv+1)

        -- Sinhammer mod
        local SH_alv = GetUnitAbilityLevel(u, SHbuff_abilId)
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
            dmg_instant = dmg_instant*SHdmgfactor
        end

        -- Area burst
        GroupEnumUnitsInRange(ug, x, y, aoe, nil)
        if (SHbool) then --with Sinhammer healing
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                    UnitDamageTarget(u, enemy, dmg_instant, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    QuickHealUnit(u, SHhealfactor*dmg_instant)
                end
            end)
        else -- without Sinhammer healing
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                    UnitDamageTarget(u, enemy, dmg_instant, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                end
            end)
        end
        
        -- Periodic effect
        TimerStart(t, 1, true, function()
            -- Area damage
            GroupEnumUnitsInRange(ug, x, y, aoe, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                    UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    --Sinhammer healing
                    if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end
                end
            end)
            -- Self heal (if within aura range)
            if Distance(x,GetUnitX(u),y,GetUnitY(u)) <= 400 then
                QuickHealUnit(u, heal)
            end

            -- Check for ending
            dur = dur - 1
            if (dur <= 0) then
                RemoveUnit(dummy)
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
            end
        end)
    -- END --
    end

    local function CreateDomSinTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, DomSinCast)
    end

    OnInit.trig(CreateDomSinTrig)

end