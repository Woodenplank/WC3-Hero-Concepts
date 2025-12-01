do
	--[[

	]]
	local function HellfuryStrikeu()
		local abilId = GetSpellAbilityId()
		if abilId ~= FourCC("A00I") then
			return
		end

		-- Getters
		local u = GetTriggerUnit()
		local targ = GetSpellTargetUnit()
		local x = GetUnitX(targ)
		local y = GetUnitY(targ)
		local alv = GetUnitAbilityLevel(u, FourCC('A00I')) - 1

		-- Hellforge mod (bool)
		local ArmsOfAstaroth = ( GetUnitAbilityLevel(u, HellforgedSpells["ArmsOfAstaroth"]) > 0 )

		-- Ability stats
		local dmg = GetAbilityField(FourCC('A00I'), "herodur", alv)
		local aoe = GetAbilityField(FourCC('A00I'), "area", alv)
		
		-- Sinhammer mod
        local SH_alv = GetUnitAbilityLevel(u, SHbuff_abilId)
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

		-- Objects
		local ug = CreateGroup()
		local cond = Condition(function() return
			IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(u))
			and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
			and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(GetFilterUnit())
		end)
		
		GroupEnumUnitsInRange(ug, x, y, aoe, cond)
		local count = CountUnitsInGroup(ug)
		if (count >= 4) then
			-- aoe spread damage
			dmg = (dmg*2)/count
			ForGroup(ug, function()
				pu = GetEnumUnit()
				UnitDamageTarget(u, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
				if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end-- Sinhammer healing
				DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", GetUnitX(pu) , GetUnitY(pu)))
			end)
		else
			-- single target damage
			UnitDamageTarget(u, targ, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
			if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end-- Sinhammer healing
			DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", x, y))
		end
		
		if ArmsOfAstaroth then
			local t = CreateTimer()
			local dur = 5.
			dmg = dmg/20 -- dmg * 0.25 / 5
			TimerStart(t, 1, true, function()
				ForGroup(ug, function()
					pu = GetEnumUnit()
					UnitDamageTarget(u, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_ENHANCED, nil)
					--Sinhammer healing
                	if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end
					-- TODO: burning over time effect? Sadly immolation doesn't work when instantly destroyed
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

	local function CreateHfStrikeTrig()
		local tr = CreateTrigger()
		TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
		TriggerAddAction(tr, HellfuryStrikeu)
	end

	OnInit.trig(CreateHfStrikeTrig)
end