function Trig_HellfuryStrike_ShitVersion_Conditions takes nothing returns boolean
	return (GetSpellAbilityId() == 'A00I')
endfunction


function TargetCondition takes nothing returns boolean
	if IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) then
		return false
	elseif IsUnitType(GetFilterUnit(), UNIT_TYPE_ETHEREAL) then
		return false
	elseif IsUnitType(GetFilterUnit(), UNIT_TYPE_FLYING) then
		return false
	elseif IsUnitDeadBJ(GetFilterUnit()) then
		return false
	elseif not IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) then
		return false
	else
		return true
	endif
endfunction

function GroupDamage takes nothing returns nothing
	local unit pu= GetEnumUnit()
	call UnitDamageTarget(udg_HeFu_u, pu, udg_HeFu_dmg[GetUnitUserData(udg_HeFu_u)], true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_ENHANCED, null)
	call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", GetUnitX(pu), GetUnitY(pu)))
endfunction

function AoA_dot takes nothing returns nothing
	local timer t = GetExpiredTimer()
	local integer id = GetHandleId(t)

	local unit pu
	local unit cast = LoadUnitHandle(udg_Spell_Table, id, 1)
	local integer cv = GetUnitUserData(cast)

	local integer count = LoadInteger(udg_Spell_Table, id, 2) + 1
	call SaveInteger(udg_Spell_Table, id, 2, count)
	
	set udg_HeFu_u = cast
	if (count < 5) then
		call ForGroupBJ( udg_HeFu_ug[cv], function GroupDamage)
		call TimerStart(t, 1.0, false, function AoA_dot)
	else
		// clean memory
		call FlushChildHashtable(udg_Spell_Table, id)
		call PauseTimer(t)
		call DestroyTimer(t)
	endif

	set pu = null
	set cast = null
	set t = null
endfunction

//////////////////////////////////////////////////////////////////////////////

function Trig_HellfuryStrike_ShitVersion_Actions takes nothing returns nothing
	local unit cast = GetTriggerUnit()
	local unit targ = GetSpellTargetUnit()

	local integer alv = GetUnitAbilityLevel(cast, 'A00I') - 1 // adjust GUI/JASS indexing mismatch
	local real damage = GetAbilityReal("herodur", cast, alv, 'A00I') + addSP(cast, 1.2)

	local real x = GetSpellTargetX()
	local real y = GetSpellTargetY()

	local real aoe = GetAbilityReal("AoE", cast, alv, 'A00I')
	local group ug = CreateGroup()
	local unit pu
	local integer targetcount = 1
	local filterfunc targetfilter = Filter(function TargetCondition)
	
	// 	If ARMS OF ASTAROTH is not active, these are not needed 
	//	but must be declared here for locality.
	
		local timer t = CreateTimer()
		local integer id = GetHandleId(t)
		local boolean AoAactive = (udg_HF_activeHellion[GetUnitUserData(cast)] == 1)

	call GroupEnumUnitsInRange(ug, x, y, aoe, targetfilter)
	if AoAactive then
		call GroupEnumUnitsInRange(udg_HeFu_ug[GetUnitUserData(cast)], x, y, aoe, targetfilter)
	endif

	set targetcount = CountUnitsInGroup(ug)
	if (targetcount >= 4) then
		// AoE spread damage
		set damage = (damage*2)/targetcount
		loop
			set pu = FirstOfGroup(ug)
			exitwhen (pu == null)
			call UnitDamageTarget(cast, pu, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, null)	// Hero damage, ignore armor
			call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", GetUnitX(pu) , GetUnitY(pu)))
			call GroupRemoveUnit(ug, pu)
		endloop
	else
		// Single target damage
		call UnitDamageTarget(cast, targ, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, null)
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", GetUnitX(targ) , GetUnitY(targ)))
	endif

	//	Modify here for ARMS OF ASTAROTH dot damage
	if AoAactive then
		set udg_HeFu_dmg[GetUnitUserData(cast)] = damage/20
		call SaveUnitHandle(udg_Spell_Table, id, 1, cast)
		call SaveInteger(udg_Spell_Table, id, 2, 0)
		call TimerStart(t, 1.0, false, function AoA_dot)
	endif

	call DestroyGroup(ug)
	call DestroyFilter(targetfilter)
	set ug = null
	set t = null
	set cast = null
	set targ = null
	set pu = null
	
endfunction


//===========================================================================
function InitTrig_HellfuryStrike_ShitVersion takes nothing returns nothing
    set gg_trg_HellfuryStrike_ShitVersion = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_HellfuryStrike_ShitVersion, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_HellfuryStrike_ShitVersion, Condition( function Trig_HellfuryStrike_ShitVersion_Conditions ) )
    call TriggerAddAction( gg_trg_HellfuryStrike_ShitVersion, function Trig_HellfuryStrike_ShitVersion_Actions )
endfunction