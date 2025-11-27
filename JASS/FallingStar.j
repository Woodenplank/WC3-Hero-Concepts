function Trig_FallingStar_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A012'
endfunction


// =====================================================
function FallingStarBoom takes nothing returns nothing
	local timer t = GetExpiredTimer()
	local integer id = GetHandleId(t)
	
	local unit u = LoadUnitHandle(udg_Spell_Table, id, 1)
	local real dmg = LoadReal(udg_Spell_Table, id, 2)
	local real aoe = LoadReal(udg_Spell_Table, id, 3)
	local real x = LoadReal(udg_Spell_Table, id, 4)
	local real y = LoadReal(udg_Spell_Table, id, 5)
	local effect StarSFX = LoadEffectHandle(udg_Spell_Table, id, 6)

	local unit Celest
	local unit pu
    	local group ug = CreateGroup()
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

	// check for Collapsing Sun

	call GroupEnumUnitsInRange(ug, x, y, 450, null)
	loop
		set pu = FirstOfGroup(ug)
		exitwhen (pu == null)
		if ((GetUnitTypeId(pu) == 'e003' )) then
		
		//	A selected (allied) unit may be a SunCheck dummy. This implies that we're creating a black hole!
		//	Which means changing the boolean associated with said dummy to TRUE.
		//	Otherwise does nothing. See <CollapseSun> trigger for more.
		
			call SaveBoolean(udg_Spell_Table, GetHandleId(pu), 9, true)
		endif
		call GroupRemoveUnit(ug, pu)
	endloop


	// Celestial spawn
	call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl", x , y))
	set Celest = CreateUnit(GetOwningPlayer(u), 'o003', x, y, 0)
	call UnitApplyTimedLifeBJ( 13.0, 'BTLF', Celest)
	
        //cleanup
        call PauseTimer(t)
        call DestroyTimer(t)
        call DestroyEffect(StarSFX)
	call FlushChildHashtable(udg_Spell_Table, id)

	call DestroyGroup(ug)
	set ug=null
	set u=null
	set pu=null
	set t=null
endfunction


// ===================== Main =============================
function Trig_FallingStar_Actions takes nothing returns nothing
	local unit u = GetTriggerUnit()

	local integer alv = GetUnitAbilityLevel(u, 'A012')-1
	local real dmg = GetAbilityReal("herodur", u, alv, 'A012') + addSP(u,1.4)
	local real aoe = GetAbilityReal("aoe", u, alv, 'A012')
	local real delay = 1.5

    local timer t = CreateTimer()
	local integer id = GetHandleId(t)
	local real x = GetSpellTargetX()
	local real y = GetSpellTargetY()

	// setup specialeffect
    local effect StarSFX
	set StarSFX = AddSpecialEffect("Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl", x , y)
	call BlzSetSpecialEffectScale( StarSFX, 2.0 )
	call BlzSetSpecialEffectTimeScale( StarSFX, 0.5 )

    	// save to hashtable
	call SaveUnitHandle(udg_Spell_Table, id, 1, u)				
	call SaveReal(udg_Spell_Table, id, 2, dmg)
	call SaveReal(udg_Spell_Table, id, 3, aoe)
	call SaveReal(udg_Spell_Table, id, 4, x)
	call SaveReal(udg_Spell_Table, id, 5, y)
	call SaveEffectHandle(udg_Spell_Table, id, 7, StarSFX)

	// start countdown to damage
	call TimerStart(t, delay, false, function FallingStarBoom) 

	//cleanup
	set t=null
	set u=null

endfunction


//===========================================================================
function InitTrig_FallingStar takes nothing returns nothing
    set gg_trg_FallingStar = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_FallingStar, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_FallingStar, Condition( function Trig_FallingStar_Conditions ) )
    call TriggerAddAction( gg_trg_FallingStar, function Trig_FallingStar_Actions )
endfunction