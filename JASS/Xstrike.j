function Trig_Xstrike_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A005' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Xstrike_Func015Func002Func001C takes nothing returns boolean
    if ( not ( IsUnitEnemy(udg_Xstrike_tempu, GetOwningPlayer(udg_Xstrike_caster)) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Xstrike_Func015Func002C takes nothing returns boolean
    if ( not ( IsUnitType(udg_Xstrike_tempu, UNIT_TYPE_STRUCTURE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitType(udg_Xstrike_tempu, UNIT_TYPE_MAGIC_IMMUNE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitDeadBJ(udg_Xstrike_tempu) == false ) ) then
        return false
    endif
    if ( not ( IsUnitPausedBJ(udg_Xstrike_tempu) == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Xstrike_Func015A takes nothing returns nothing
    set udg_Xstrike_tempu = GetEnumUnit()
    if ( Trig_Xstrike_Func015Func002C() ) then
        if ( Trig_Xstrike_Func015Func002Func001C() ) then
            call UnitDamageTargetBJ( udg_Xstrike_caster, udg_Xstrike_tempu, udg_Xstrike_dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
        else
            call SetUnitLifeBJ( udg_Xstrike_tempu, ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_Xstrike_tempu) + udg_Xstrike_heal ) )
        endif
        call AddSpecialEffectTargetUnitBJ( "chest", udg_Xstrike_tempu, "BoilingBlood_effect.mdx" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    else
    endif
endfunction

function Trig_Xstrike_Actions takes nothing returns nothing
    set udg_Xstrike_caster = GetTriggerUnit()
    set udg_Xstrike_lvl = ( GetUnitAbilityLevelSwapped('A005', udg_Xstrike_caster) - 1 )
    set udg_Xstrike_dmg = GetAbilityReal("herodur", udg_Xstrike_caster, udg_Xstrike_lvl, 'A005')
    set udg_Xstrike_dmg = ( udg_Xstrike_dmg + ( 1.30 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, udg_Xstrike_caster, true)) ) )
    set udg_Xstrike_heal = GetAbilityReal("normaldur", udg_Xstrike_caster, udg_Xstrike_lvl, 'A005')
    set udg_Xstrike_heal = ( udg_Xstrike_dmg + ( 2.00 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, udg_Xstrike_caster, true)) ) )
    set udg_Xstrike_center = GetUnitLoc(udg_Xstrike_caster)
    set udg_Xstrike_ang = 45.00
    // Targeting
    call AddSpecialEffectLocBJ( udg_Xstrike_center, "Flamestrike I.mdx" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    set udg_Xstrike_targetgroup = GetUnitsInRangeOfLocAll(175.00, udg_Xstrike_center)
    set udg_Xstrike_loopi1 = 1
    loop
        exitwhen udg_Xstrike_loopi1 > 4
        set udg_Xstrike_dist = 175.00
        set udg_Xstrike_loopi2 = 1
        loop
            exitwhen udg_Xstrike_loopi2 > 2
            set udg_Xstrike_tempp = PolarProjectionBJ(udg_Xstrike_center, udg_Xstrike_dist, udg_Xstrike_ang)
            set udg_Xstrike_tempug = GetUnitsInRangeOfLocAll(175.00, udg_Xstrike_tempp)
            call GroupAddGroup( udg_Xstrike_tempug, udg_Xstrike_targetgroup )
            set udg_Xstrike_dist = ( udg_Xstrike_dist + 175.00 )
            call AddSpecialEffectLocBJ( udg_Xstrike_tempp, "Flamestrike I.mdx" )
            call DestroyEffectBJ( GetLastCreatedEffectBJ() )
            call RemoveLocation(udg_Xstrike_tempp)
            call DestroyGroup(udg_Xstrike_tempug)
            set udg_Xstrike_loopi2 = udg_Xstrike_loopi2 + 1
        endloop
        set udg_Xstrike_ang = ( udg_Xstrike_ang + 90.00 )
        set udg_Xstrike_loopi1 = udg_Xstrike_loopi1 + 1
    endloop
    // Damage and healing
    call ForGroupBJ( udg_Xstrike_targetgroup, function Trig_Xstrike_Func015A )
    // Final cleanup
    call DestroyGroup(udg_Xstrike_targetgroup)
    call RemoveLocation(udg_Xstrike_center)
endfunction

//===========================================================================
function InitTrig_Xstrike takes nothing returns nothing
    set gg_trg_Xstrike = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Xstrike, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Xstrike, Condition( function Trig_Xstrike_Conditions ) )
    call TriggerAddAction( gg_trg_Xstrike, function Trig_Xstrike_Actions )
endfunction

