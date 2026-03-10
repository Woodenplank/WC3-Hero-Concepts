-- requires SpellTemplate.lua
-- requires StunUnit.lua
do
    local SupernalRuneSpellObj = Spell:Create("A01G", "unit")
    local function SupernalRuneMain()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= SupernalRuneSpellObj.id then
            return
        end

        -- Ability stats
        local this = SupernalRuneSpellObj:NewInstance()
        local delay = this.normaldur
        local stundur = this.herodur + (math.floor(GetHeroInt(this.caster, true)/20))
        local debuff_sfx = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Parasite\\ParasiteTarget.mdl", this.target, "overhead")
        
        -- Delayed effect
        local t = CreateTimer()
        TimerStart(t, delay, false, function()
            StunTarget(this.target, this.caster, stundur)
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DarkSummoning\\DarkSummonMissile.mdl", GetUnitX(this.target) , GetUnitY(this.target)))

            -- Cleanup
            DestroyEffect(debuff_sfx)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end
    SupernalRuneSpellObj:MakeTrigger(SupernalRuneMain)
end