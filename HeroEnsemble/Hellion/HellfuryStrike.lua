do
	--[[

	]]
	local function HellfuryStrike_Q()
		-- Getters
		local cast = GetTriggerUnit()
		local targ = GetSpellTargetUnit()
		local x = GetUnitX(targ)
		local y = GetUnitY(targ)
		local alv = GetUnitAbilityLevel(u, FourCC('A00Q')) - 1

		-- [[ here we need to fetch the state of ARMS OF ASTAROTH ]]
		-- [[ //If Arms of Astaroth is enabled, the ability deals an additional 25% damage over 5 seconds.\\ ]]
		local ArmsOfAstaroth = false
		-- TODO: how do we save/fetch the Arms of Astaroth setting?

		-- Ability stats
		local dmg = GetAbilityField(FourCC('A00Q'), "herodur", alv)
		local aoe = GetAbilityField(FourCC('A00Q'), "area", alv)
		
		-- Sinhammer mod
        local SH_alv = GetUnitAbilityLevel(u, SHbuff_abilID)
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

		-- Objects
		local group ug = CreateGroup()
		local cond = Condition(function() return
			IsUnitEnemy(GetFilterUnit(),player)
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
				UnitDamageTarget(cast, pu, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
				if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end-- Sinhammer healing
				DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", GetUnitX(pu) , GetUnitY(pu)))
			end)
		else
			-- single target damage
			UnitDamageTarget(cast, targ, dmg, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
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
					UnitDamageTarget(cast, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_ENHANCED, nil)
					--Sinhammer healing
                	if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end
					-- TODO: burning over time effect? Sadly immolation doesn't work when instantly destroyed
				end)
				-- Attempt to end DoT
				dur = dur - 1
				if (dur==0) then
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
		TriggerAddAction(tr, HellfuryStrike_Q)
	end

	OnInit.trig(CreateHfStrikeTrig)
end