function Trig_Omnislash_cast_Conditions takes nothing returns boolean
    return ( GetSpellAbilityId() == 'A000' )
endfunction

function Trig_Omnislash_cast_Actions takes nothing returns nothing
    set udg_Omnislash_MUI = ( udg_Omnislash_MUI + 1 )
    set udg_Omnislash_casteru[udg_Omnislash_MUI] = GetTriggerUnit()
    set udg_Omnislash_targetu[udg_Omnislash_MUI] = GetSpellTargetUnit()
    set udg_Omnislash_dmg[udg_Omnislash_MUI] = ( ( 50.00 + ( 100.00 * I2R(GetUnitAbilityLevelSwapped(GetSpellAbilityId(), udg_Omnislash_casteru[udg_Omnislash_MUI])) ) ) + ( 0.35 * I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, udg_Omnislash_casteru[udg_Omnislash_MUI], true)) ) )
    set udg_Omnislash_slashmax[udg_Omnislash_MUI] = ( 1 + ( 2 * GetUnitAbilityLevelSwapped(GetSpellAbilityId(), udg_Omnislash_casteru[udg_Omnislash_MUI]) ) )
    set udg_Omnislash_first[udg_Omnislash_MUI] = true
    // Visuals
    call PauseUnitBJ( true, udg_Omnislash_casteru[udg_Omnislash_MUI] )
    call SetUnitVertexColorBJ( udg_Omnislash_casteru[udg_Omnislash_MUI], 100, 100, 100, 25.00 )
    call SetUnitTimeScalePercent( udg_Omnislash_casteru[udg_Omnislash_MUI], 250.00 )
    call AddSpecialEffectTargetUnitBJ( "weapon", udg_Omnislash_casteru[udg_Omnislash_MUI], "Sweep_Fire_Large.mdx" )
    set udg_Omnislash_attach[udg_Omnislash_MUI] = GetLastCreatedEffectBJ()
    // AoE is the maximum distance from original target where Hero will seek new targets
    set udg_Omnislash_AoE[udg_Omnislash_MUI] = 650.00
    // slashcount will be used to count how many Slashes the caster has performed
    set udg_Omnislash_slashcount[udg_Omnislash_MUI] = 0
    // Start looping
    if ( IsTriggerEnabled(gg_trg_Omnislash_loop) == false ) then
        call EnableTrigger( gg_trg_Omnislash_loop )
    else
    endif
endfunction

//===========================================================================
function InitTrig_Omnislash_cast takes nothing returns nothing
    set gg_trg_Omnislash_cast = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Omnislash_cast, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Omnislash_cast, Condition( function Trig_Omnislash_cast_Conditions ) )
    call TriggerAddAction( gg_trg_Omnislash_cast, function Trig_Omnislash_cast_Actions )
endfunction

