-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
-- requires QuickHeal.lua
do
	--[[
		Slams a target foe in melee range, dealing instant damage (|cffdbb8eb+120% Focus|r). If 3 or more enemies are within range of the main target the damage is doubled, but is distributed evenly among all targets.

		|cffffcc00Level 1|r - <A00I:Ancl,HeroDur1> damage.
		|cffffcc00Level 2|r - <A00I:Ancl,HeroDur2> damage.
		|cffffcc00Level 3|r - <A00I:Ancl,HeroDur3> damage.
	]]
	local function HellfuryStrike()
		local abilId = GetSpellAbilityId()
		if abilId ~= HEL_hfstrikeSpell.id then
			return
		end

		-- Ability stats
		local this = HEL_hfstrikeSpell:NewInstance()
		local dmg = this.herodur


		-- Getters
		local u = GetTriggerUnit()
		local targ = GetSpellTargetUnit()
		local x = GetUnitX(targ)
		local y = GetUnitY(targ)
		local alv = GetUnitAbilityLevel(u, HEL_id_hfstrike) - 1

		-- Hellforge mod (bool)
		local ArmsOfAstaroth = (GetUnitAbilityLevel(this.caster, HellforgedSpells["ArmsOfAstaroth"])>0)

		-- Ability stats
		local dmg = GetAbilityField(HEL_id_hfstrike, "herodur", alv)
		local aoe = GetAbilityField(HEL_id_hfstrike, "area", alv)
		
        -- Sinhammer mod
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(this.caster)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

		-- Objects
		local ug = CreateGroup()
		local cond = Condition(function() 
			local fu = GetFilterUnit()
			return IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(fu)
		end)
		
		GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond)
		local count = CountUnitsInGroup(ug)
		if (count >= 4) then
			dmg = (dmg*2)/count
			ForGroup(ug, function()
				pu = GetEnumUnit()
				UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
				DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", GetUnitX(pu) , GetUnitY(pu)))
				if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end-- Sinhammer healing
			end)
		else
			UnitDamageTarget(this.caster, this.target, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
			DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", x, y))
			if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end-- Sinhammer healing
		end
		
		if ArmsOfAstaroth then
			local t = CreateTimer()
			local dur = 5.0
			dmg = dmg/20 -- dmg * 0.25 / 5
			TimerStart(t, 1.0, true, function()
				ForGroup(ug, function()
					pu = GetEnumUnit()
					UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_ENHANCED, nil)
					-- TODO: burning over time effect? Sadly immolation doesn't work when instantly destroyed
                	if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end --Sinhammer healing
				end)

				-- Attempt to end DoT
				dur = dur - 1
				if (dur<=0) then
					DestroyGroup(ug)
					PauseTimer(t)
					DestroyTimer(t)
				end
			end)
		else
			DestroyGroup(ug)
		end

		-- Misc. Cleanup
		DestroyCondition(cond)
		-- END --
	end
	HEL_hfstrikeSpell:MakeTrigger(HellfuryStrike)
end