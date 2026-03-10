-- requires SpellTemplate.lua
do
    local BalefireSpellObj = Spell:Create("A01M", "unit") -- main ability object
    local function BalefireCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= BalefireSpellObj.id then
            return
        end

        -- stats
        local this = BalefireSpellObj:NewInstance()
        local t_interval = 0.5
        local dmg = (this.herodur + addSP(this.caster, 0.6)) * t_interval
        local last_x, last_y = this.targ_x, this.targ_y
        
        -- Main target sfx
        local mainsfx = AddSpecialEffectTarget("WitheringPresence.mdx", this.target, "chest")

        -- WC3 objects
        local ug = CreateGroup()
        local target_cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                (IsUnitEnemy(fu, this.castplayer) 
                and not IsUnitType(fu, UNIT_TYPE_DEAD) 
                and not BlzIsUnitInvulnerable(fu)
                and not IsUnitType(fu, UNIT_TYPE_MAGIC_IMMUNE))
		end)
        GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, target_cond)
        local t = CreateTimer()

        local elapsed = 0
        TimerStart(t, t_interval, true, function()
            -- This structure ensures that if the main target dies early, the effect lingers "on the ground" where they died.
            if UnitAlive(this.target) and this.target~=nil then
                last_x, last_y = this.targ_x, this.targ_y
            else
                this.target = nil
            end
            GroupEnumUnitsInRange(ug, last_x, last_y, this.aoe, target_cond)
            ForGroup(ug, function()
                pu = GetEnumUnit()
                UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdl", GetUnitX(pu), GetUnitY(pu)))
            end)


            elapsed = elapsed + t_interval
            if (elapsed >= this.normaldur) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
                DestroyCondition(target_cond)
                DestroyEffect(mainsfx)
            end
        end)
    -- END --
    end
    BalefireSpellObj:MakeTrigger(BalefireCast)
end