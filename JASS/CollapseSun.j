function Trig_CollapseSun_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A013'
endfunction

// ================== Periodic Burn (Blackhole) ==========================
function BlackHolePeriodic takes nothing returns nothing
	local timer t = GetExpiredTimer()
	local integer id = GetHandleId(t)
	
	local unit u = LoadUnitHandle(udg_Spell_Table, id, 1)
	local real dmg = LoadReal(udg_Spell_Table, id, 2)
	local real aoe = LoadReal(udg_Spell_Table, id, 3)
	local real x = LoadReal(udg_Spell_Table, id, 4)
	local real y = LoadReal(udg_Spell_Table, id, 5)
	local real dur = LoadReal(udg_Spell_Table, id, 6) - 0.05
    local effect VoidSFX = LoadEffectHandle(udg_Spell_Table, id, 7)

	local real temp_x
	local real temp_y
	local real ang

    local unit pu
    local group ug = CreateGroup()
	if (dur >= 0) then
		//aoe damage
		call GroupEnumUnitsInRange(ug, x, y, aoe, null)
		loop
			set pu = FirstOfGroup(ug)
			exitwhen (pu == null)
			if (IsUnitEnemy(pu, GetOwningPlayer(u)) and (IsUnitType(pu, UNIT_TYPE_MAGIC_IMMUNE) == false)) then
				call UnitDamageTarget(u, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
				set ang = AngleBetweenCoords(GetUnitX(pu), x, GetUnitY(pu), y)
				set temp_x = GetUnitX(pu) + 5 * Cos(ang * bj_DEGTORAD)
				set temp_y = GetUnitY(pu) + 5 * Sin(ang * bj_DEGTORAD)
				call SetUnitX(pu, temp_x)
				call SetUnitY(pu, temp_y) 
			endif
			call GroupRemoveUnit(ug, pu)
		endloop
		call SaveReal(udg_Spell_Table, id, 6, dur)
		call TimerStart(t, 0.05, false, function BlackHolePeriodic) 	
	else
		//cleanup
	        call PauseTimer(t)
		call DestroyTimer(t)
	        call DestroyEffect(VoidSFX)
		call FlushChildHashtable(udg_Spell_Table, id)
	endif
	
	// null references
    	call DestroyGroup(ug)
	set ug=null
	set u=null
	set pu=null
	set t=null
endfunction

// ==================== Periodic Burn ===========================
function SunBurn takes nothing returns nothing
	local timer t = GetExpiredTimer()
	local integer id = GetHandleId(t)
	
	local unit u = LoadUnitHandle(udg_Spell_Table, id, 1)
	local real dmg = LoadReal(udg_Spell_Table, id, 2)
	local real aoe = LoadReal(udg_Spell_Table, id, 3)
	local real x = LoadReal(udg_Spell_Table, id, 4)
	local real y = LoadReal(udg_Spell_Table, id, 5)
	local real dur = LoadReal(udg_Spell_Table, id, 6) - 0.5
    local effect SunSFX = LoadEffectHandle(udg_Spell_Table, id, 7)
	local unit SunDummy = LoadUnitHandle(udg_Spell_Table, id, 8)
	local boolean SunCollapse = LoadBoolean(udg_Spell_Table, GetHandleId(SunDummy), 9)
	
	local effect VoidSFX
    local unit pu
    local group ug = CreateGroup()
	
	// check if we should transition to Black Hole
	if (SunCollapse) then
		// we no longer need the Dummy
		call FlushChildHashtable(udg_Spell_Table, GetHandleId(SunDummy))
		call RemoveUnit(SunDummy)

		// Transisition effect
		call DestroyEffect(SunSFX)
		call DestroyEffect(AddSpecialEffect("DarkLightning.mdx", x, y))
		
		// make new effect for black hole
		set VoidSFX = AddSpecialEffect("Void Disc.mdx", x, y)
		call SaveEffectHandle(udg_Spell_Table, id, 7, VoidSFX)
		
		// setup new loop
		call SaveReal(udg_Spell_Table, id, 2, (dmg*1.5)/10)
		call TimerStart(t, 0.05, false, function BlackHolePeriodic)
		
	else // otherwise do normal Sun-Burn
		if (dur>0) then
        		//aoe damage
			call GroupEnumUnitsInRange(ug, x, y, aoe, null)
			loop
				set pu = FirstOfGroup(ug)
				exitwhen (pu == null)
				if IsUnitEnemy(pu, GetOwningPlayer(u)) then
	    				call UnitDamageTarget(u, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
		    		endif
				call GroupRemoveUnit(ug, pu)
			endloop
			call SaveReal(udg_Spell_Table, id, 6, dur)
			call TimerStart(t, 0.5, false, function SunBurn) 
		else
        		//cleanup
			// TODO more impressive looking end
	        	call PauseTimer(t)
			call DestroyTimer(t)
	        	call DestroyEffect(SunSFX)
			call FlushChildHashtable(udg_Spell_Table, id)
			call FlushChildHashtable(udg_Spell_Table, GetHandleId(SunDummy))
			call RemoveUnit(SunDummy)
		endif
	endif

	// null references
    	call DestroyGroup(ug)
	set ug=null
	set u=null
	set SunDummy=null
	set pu=null
	set t=null
endfunction



// ===================== Main =============================
function Trig_CollapseSun_Actions takes nothing returns nothing
	local unit u = GetTriggerUnit()
	
	local integer alv = GetUnitAbilityLevel(u, 'A013')-1
	local real dmg = (GetAbilityReal("herodur", u, alv, 'A013') + addSP(u,1)) / 2
	local real aoe = GetAbilityReal("aoe", u, alv, 'A013')
	local real dur = GetAbilityReal("normaldur", u, alv, 'A013')

    local timer t = CreateTimer()
	local integer id = GetHandleId(t)
	local real x = GetSpellTargetX()
	local real y = GetSpellTargetY()
	
	// This dummy does nothing, but allows FallingStar to register if a sun is struck
	local unit SunCheckDummy = CreateUnit(GetOwningPlayer(u), 'e003', x, y, 0)    
	local boolean SunCollapse = false

	// setup specialeffect
    	local effect SunSFX
	set SunSFX = AddSpecialEffect("star_red.mdx", x , y)
	call BlzSetSpecialEffectZ( SunSFX, 125.0 )

    	// save to hashtable
	call SaveUnitHandle(udg_Spell_Table, id, 1, u)				
	call SaveReal(udg_Spell_Table, id, 2, dmg)
	call SaveReal(udg_Spell_Table, id, 3, aoe)
	call SaveReal(udg_Spell_Table, id, 4, x)
	call SaveReal(udg_Spell_Table, id, 5, y)
	call SaveReal(udg_Spell_Table, id, 6, dur)
	call SaveEffectHandle(udg_Spell_Table, id, 7, SunSFX)
	call SaveUnitHandle(udg_Spell_Table, id, 8, SunCheckDummy)
	call SaveBoolean(udg_Spell_Table, GetHandleId(SunCheckDummy), 9, SunCollapse)

	// start countdown to damage
	call TimerStart(t, 0.5, false, function SunBurn) 

	//cleanup
	set t=null
	set u=null

endfunction


//===========================================================================
function InitTrig_CollapseSun takes nothing returns nothing
    set gg_trg_CollapseSun = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_CollapseSun, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_CollapseSun, Condition( function Trig_CollapseSun_Conditions ) )
    call TriggerAddAction( gg_trg_CollapseSun, function Trig_CollapseSun_Actions )
endfunction