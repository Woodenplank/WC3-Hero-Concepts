-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
-- requires QuickHeal.lua
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
        if abilId ~= HEL_domainSpell.id then
            return
        end
        
        -- Ability stats
        local this = HEL_domainSpell:NewInstance()
        local dmg = this.herodur
        local dmg_instant = 200
        local heal = this.range
        local dur = this.normaldur

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Dummy buffer
        local dummy = CreateUnit(this.castplayer, utype_PentagramDummy, this.cast_x, this.cast_y, 270)
        SetUnitAbilityLevel(dummy, HEL_domainbuff, this.alv+1)

        -- Sinhammer mod
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(this.caster)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Area burst
        GroupEnumUnitsInRange(ug, this.cast_x, this.cast_y, this.aoe, nil)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            if IsUnitEnemy(pu, this.castplayer) then
                UnitDamageTarget(this.caster, pu, dmg_instant, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                --Sinhammer healing
                if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg_instant) end
            end
        end)
        
        -- Periodic effect
        TimerStart(t, 1.0, true, function()
            -- Area damage
            GroupEnumUnitsInRange(ug, this.cast_x, this.cast_y, this.aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if IsUnitEnemy(pu, this.castplayer) then
                    UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    --Sinhammer healing
                    if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end
                end
            end)
            -- Self heal (if within aura range)
            if Distance(this.cast_x, GetUnitX(this.caster), this.cast_y, GetUnitY(this.caster)) <= 400 then
                QuickHealUnit(this.caster, heal)
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
    HEL_domainSpell:MakeTrigger(DomSinCast)
end