-- requires SpellTemplate.lua
--[[ ability description
    Places a seed of destruction in target unit, dealing damage over time. 
    Upon expiration the seed explodes, dealing damage to all enemies near the main target.

    May be placed on an allied unit, dealing no damage over time, but doubling the explosion damage.
]]
do
    local LivingBombSpellObj = Spell:Create("________", "unit") -- main ability object
    local function LivingBombCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= LivingBombSpellObj.id then
            return
        end

        -- stats
        local this = LivingBombSpellObj:NewInstance()
        local t_interval = 0.5
        local dps = (this.herodur + addSP(this.caster, 0.5)) * t_interval
        local exdmg = dps * this.normaldur * t_interval -- final damage = total DoT damage
        local is_enemy = IsUnitEnemy(this.target, this.castplayer) 


        -- Main target sfx
        local mainsfx = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl", this.target, "chest")

        -- WC3 objects
        local t = CreateTimer()
        local ug = CreateGroup()
        local target_cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                (IsUnitEnemy(fu, this.castplayer) 
                and not IsUnitType(fu, UNIT_TYPE_DEAD) 
                and not BlzIsUnitInvulnerable(fu)
                and not IsUnitType(fu, UNIT_TYPE_MAGIC_IMMUNE))
		end)        

        -- Periodicity
        local elapsed = 0
        TimerStart(t, t_interval, true, function()
            -- dot
            if is_enemy then
                UnitDamageTarget(this.caster, this.target, dps, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
            end

            -- advance timer
            elapsed = elapsed + t_interval
            if (elapsed >= this.normaldur) or (not UnitAlive(this.target)) then
                -- If the main target dies early; still explodes
                if is_enemy then exdmg = exdmg*2 end
                -- do area explosion
                GroupEnumUnitsInRange(ug, GetUnitX(this.target), GetUnitY(this.target), this.aoe, target_cond)
                ForGroup(ug, function()
                    pu = GetEnumUnit()
                    UnitDamageTarget(this.caster, pu, exdmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                    DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl", GetUnitX(pu), GetUnitY(pu)))
                end)
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", GetUnitX(this.target), GetUnitY(this.target)))

                -- cleanup
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
                DestroyCondition(target_cond)
                DestroyEffect(mainsfx)
            end
        end)
    -- END --
    end
    LivingBombSpellObj:MakeTrigger(LivingBombCast)
end