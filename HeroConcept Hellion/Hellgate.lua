-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
do
    --[[
    After a brief delay; teleport to target area in a blaze of hellfire, dealing <A00Q:ANcl,HeroDur1> damage to all nearby enemies on arrival.
    ]]
    local function HellgateCast()
        local abilId = GetSpellAbilityId()
		if abilId ~= HEL_hellgateSpell.id then
			return
		end

        -- Getters
        local this = HEL_hellgateSpell:NewInstance()
        local dmg = this.herodur

        -- Sinhammer mod
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(this.caster)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Teleport
        SetUnitX(this.caster, this.targ_x)
        SetUnitY(this.caster, this.targ_y)
        DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Flamestrike\\Flamestrike1.mdl", this.targ_x, this.targ_y))

        -- Area damage
        local ug = CreateGroup()
        GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, nil)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            if IsUnitEnemy(pu, this.castplayer) then
                UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                --Sinhammer healing
                if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end
            end
        end)
        DestroyGroup(ug)
        -- END --
    end
    HEL_hellgateSpell:MakeTrigger(HellgateCast)
end