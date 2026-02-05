do
	--[[
		Slams a target foe in melee range, dealing instant damage. If 3 or more enemies are within range of the main target the damage is doubled, but is distributed evenly among all targets.
	]]
	local UnitStrikeSpellObject = Spell:Create("A001", "unit")	-- may as well keep these in a "global" scope segment somewhere.

	-- UnitStrikeSpellObject:MakeTrigger(function()
	-- end)
	local function UnitStrikeSpellCast()
		local abilId = GetSpellAbilityId()
		if abilId ~= UnitStrikeSpellObject.id then
			return
		end

		-- Get this instance
		local this = UnitStrikeSpellObject:NewInstance()
		local dmg = this.herodur
		
		-- Objects
		local ug = CreateGroup()
		local cond = Condition(function() return
			IsUnitEnemy(GetFilterUnit(), this.castplayer)
			and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
			and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(GetFilterUnit())
		end)
		
		GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond)
		local count = CountUnitsInGroup(ug)
		if (count >= 4) then
			dmg = (dmg*2)/count
			ForGroup(ug, function()
				pu = GetEnumUnit()
				UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
				DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", GetUnitX(pu), GetUnitY(pu)))
			end)
		else
			UnitDamageTarget(this.caster, this.target, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
			DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", this.targ_x, this.targ_y))
		end
		
		DestroyGroup(ug)
		DestroyCondition(cond)
		-- END --
	end
	UnitStrikeSpellObject:MakeTrigger(UnitStrikeSpellCast)
end