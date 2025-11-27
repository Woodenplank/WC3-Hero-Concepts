// This is mostly just the <Convert to Custom Text> standard option, taken from GUI
// Which is why the names are spaghetti

function Trig_Omnislash_loop_Func001Func005Func002C takes nothing returns boolean
    if ( not ( IsUnitType(udg_Omnislash_victim, UNIT_TYPE_STRUCTURE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitType(udg_Omnislash_victim, UNIT_TYPE_MAGIC_IMMUNE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitDeadBJ(udg_Omnislash_victim) == false ) ) then
        return false
    endif
    if ( not ( IsUnitAlly(udg_Omnislash_victim, GetOwningPlayer(udg_Omnislash_casteru[udg_Omnislash_i])) == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Omnislash_loop_Func001Func005A takes nothing returns nothing
    set udg_Omnislash_victim = GetEnumUnit()
    if ( Trig_Omnislash_loop_Func001Func005Func002C() ) then
    else
        call GroupRemoveUnitSimple( udg_Omnislash_victim, udg_Omnislash_ug[1] )
    endif
endfunction

function Trig_Omnislash_loop_Func001Func006Func002Func019C takes nothing returns boolean
    return ( udg_Omnislash_MUI == 0 )
endfunction

function Trig_Omnislash_loop_Func001Func006Func002C takes nothing returns boolean
    return ( (CountUnitsInGroup(udg_Omnislash_ug[1]) > 0) and (udg_Omnislash_slashcount[udg_Omnislash_i] <= udg_Omnislash_slashmax[udg_Omnislash_i]) )
endfunction

function Trig_Omnislash_loop_Func001Func006C takes nothing returns boolean
    return ( udg_Omnislash_first[udg_Omnislash_i] == true )
endfunction

function Trig_Omnislash_loop_Actions takes nothing returns nothing
    set udg_Omnislash_i = 1
    loop
        exitwhen udg_Omnislash_i > udg_Omnislash_MUI
        set udg_Omnislash_p[1] = GetUnitLoc(udg_Omnislash_targetu[udg_Omnislash_i])
        set udg_Omnislash_slashcount[udg_Omnislash_i] = ( udg_Omnislash_slashcount[udg_Omnislash_i] + 1 )
        // Get potential targets
        set udg_Omnislash_ug[1] = GetUnitsInRangeOfLocAll(udg_Omnislash_AoE[udg_Omnislash_i], udg_Omnislash_p[1])
        call ForGroupBJ( udg_Omnislash_ug[1], function Trig_Omnislash_loop_Func001Func005A )
        if ( Trig_Omnislash_loop_Func001Func006C() ) then
            // First "jump" is always main target
            call SetUnitX(udg_Omnislash_casteru[udg_Omnislash_i],GetLocationX(udg_Omnislash_p[1]))
            call SetUnitY(udg_Omnislash_casteru[udg_Omnislash_i],GetLocationY(udg_Omnislash_p[1]))
            call SetUnitFacingToFaceUnitTimed( udg_Omnislash_casteru[udg_Omnislash_i], udg_Omnislash_targetu[udg_Omnislash_i], 0 )
            call SetUnitAnimation( udg_Omnislash_casteru[udg_Omnislash_i], "spell throw gold alternate" )
            call UnitDamageTargetBJ( udg_Omnislash_casteru[udg_Omnislash_i], udg_Omnislash_targetu[udg_Omnislash_i], udg_Omnislash_dmg[udg_Omnislash_i], ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
            call AddSpecialEffectTargetUnitBJ( "chest", udg_Omnislash_victim, "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl" )
            call DestroyEffectBJ( GetLastCreatedEffectBJ() )
            set udg_Omnislash_first[udg_Omnislash_i] = false
        else
            // Any additional jumps go here
            if ( Trig_Omnislash_loop_Func001Func006Func002C() ) then
                set udg_Omnislash_victim = GroupPickRandomUnit(udg_Omnislash_ug[1])
                set udg_Omnislash_p[2] = GetUnitLoc(udg_Omnislash_victim)
                set udg_Omnislash_p[3] = PolarProjectionBJ(udg_Omnislash_p[2], 50.00, GetRandomDirectionDeg())
                call SetUnitX(udg_Omnislash_casteru[udg_Omnislash_i],GetLocationX(udg_Omnislash_p[3]))
                call SetUnitY(udg_Omnislash_casteru[udg_Omnislash_i],GetLocationY(udg_Omnislash_p[3]))
                call SetUnitFacingToFaceUnitTimed( udg_Omnislash_casteru[udg_Omnislash_i], udg_Omnislash_victim, 0 )
                call SetUnitAnimation( udg_Omnislash_casteru[udg_Omnislash_i], "spell throw gold alternate" )
                call UnitDamageTargetBJ( udg_Omnislash_casteru[udg_Omnislash_i], udg_Omnislash_victim, udg_Omnislash_dmg[udg_Omnislash_i], ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
                call AddSpecialEffectTargetUnitBJ( "chest", udg_Omnislash_victim, "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl" )
                call DestroyEffectBJ( GetLastCreatedEffectBJ() )
                // Clean temp points
                call RemoveLocation(udg_Omnislash_p[2])
                call RemoveLocation(udg_Omnislash_p[3])
            else
                // No more targets/slashes
                call PauseUnitBJ( false, udg_Omnislash_casteru[udg_Omnislash_i] )
                call SetUnitVertexColorBJ( udg_Omnislash_casteru[udg_Omnislash_MUI], 100, 100, 100, 0.00 )
                call SetUnitTimeScalePercent( udg_Omnislash_casteru[udg_Omnislash_MUI], 100.00 )
                call DestroyEffectBJ( udg_Omnislash_attach[udg_Omnislash_i] )
                call SetUnitX(udg_Omnislash_casteru[udg_Omnislash_i],GetLocationX(udg_Omnislash_p[1]))
                call SetUnitY(udg_Omnislash_casteru[udg_Omnislash_i],GetLocationY(udg_Omnislash_p[1]))
                // Recycle indices
                set udg_Omnislash_AoE[udg_Omnislash_i] = udg_Omnislash_AoE[udg_Omnislash_MUI]
                set udg_Omnislash_dmg[udg_Omnislash_i] = udg_Omnislash_dmg[udg_Omnislash_MUI]
                set udg_Omnislash_attach[udg_Omnislash_i] = udg_Omnislash_attach[udg_Omnislash_MUI]
                set udg_Omnislash_casteru[udg_Omnislash_i] = udg_Omnislash_casteru[udg_Omnislash_MUI]
                set udg_Omnislash_targetu[udg_Omnislash_i] = udg_Omnislash_targetu[udg_Omnislash_MUI]
                set udg_Omnislash_first[udg_Omnislash_i] = udg_Omnislash_first[udg_Omnislash_MUI]
                set udg_Omnislash_slashcount[udg_Omnislash_i] = udg_Omnislash_slashcount[udg_Omnislash_MUI]
                set udg_Omnislash_slashmax[udg_Omnislash_i] = udg_Omnislash_slashcount[udg_Omnislash_MUI]
                set udg_Omnislash_MUI = ( udg_Omnislash_MUI - 1 )
                set udg_Omnislash_i = ( udg_Omnislash_i - 1 )
                if ( Trig_Omnislash_loop_Func001Func006Func002Func019C() ) then
                    call DisableTrigger( GetTriggeringTrigger() )
                else
                endif
            endif
        endif
        // Clean memory
        call RemoveLocation(udg_Omnislash_p[1])
        call DestroyGroup(udg_Omnislash_ug[1])
        set udg_Omnislash_i = udg_Omnislash_i + 1
    endloop
endfunction

//===========================================================================
function InitTrig_Omnislash_loop takes nothing returns nothing
    set gg_trg_Omnislash_loop = CreateTrigger(  )
    call DisableTrigger( gg_trg_Omnislash_loop )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Omnislash_loop, 0.50 )
    call TriggerAddAction( gg_trg_Omnislash_loop, function Trig_Omnislash_loop_Actions )
endfunction

