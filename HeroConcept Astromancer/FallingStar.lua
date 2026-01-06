do 
    --[[
    Calls down a star to crash against the target area, dealing staggering damage (|cffdbb8eb+140% Focus|r) upon arrival. A Celestial spirit will spawn from the crater to attack nearby foes.

    |cffffcc00Level 1|r - <A00A:ANcl,HeroDur1> damage.
    |cffffcc00Level 2|r - <A00A:ANcl,HeroDur2> damage.
    |cffffcc00Level 3|r - <A00A:ANcl,HeroDur3> damage.
    ]]
    local function FallingStar_W()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= AST_id_fallingstar then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        local lvl = GetUnitAbilityLevel(u, abilId) - 1
 
        -- Stats
        local dmg = GetAbilityField(AST_id_fallingstar, "herodur", lvl)
        local aoe = GetAbilityField(AST_id_fallingstar, "area", lvl)
 
        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Setup sfx
        local effect StarSFX = AddSpecialEffect("Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl", x , y)
	    BlzSetSpecialEffectScale( StarSFX, 2.0 )
	    BlzSetSpecialEffectTimeScale( StarSFX, 0.5 )

        -- Arcane Almanac (Active Bonus or Crit roll)
        local StarmodActive, BonusMod = AlmaStarmod(u)
        if (StarmodActive) then
            -- If Arcane Almanac was actively used
            dmg = dmg*BonusMod
        else
            -- If we didn't have ACTIVE bonus, roll for random crit chance instead
            dmg = dmg * AlmaCrit(u)
        end

        -- Delayed damage effect
        local delay = 1.5
        TimerStart(t, delay, false, function()
            local DoBlackHole = false
            -- Deal AoE damage
            GroupEnumUnitsInRange(ug, x, y, aoe, nil)
            ForGroup(ug, function()
                local pickedu = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(pickedu)) then
                    UnitDamageTarget(u, pickedu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                elseif ((GetUnitTypeId(pickedu) == FourCC('e004') )) then
                    DoBlackHole = true
                    BlackHoleChecks[GetHandleId(pickedu)]=true
                end
            end)
    
            -- Celestial spawn / if we're not doing a black hole
            if not DoBlackHole then
                local Celest = CreateUnit(GetOwningPlayer(u), FourCC('e003'), x, y, 270)
                if StarmodActive then
                    UnitApplyTimedLifeBJ( 13.0 * 1.3, FourCC('BTLF'), Celest)
                else
                    UnitApplyTimedLifeBJ( 13.0, FourCC('BTLF'), Celest)
                end
            end
            
            -- "consume" Almanac Starmod buff
            UnitRemoveAbility(u, AlmanacBuff_AbilId)

            -- Cleanup
            DestroyGroup(ug)
            PauseTimer(t)
            DestroyTimer(t)
            DestroyEffect(StarSFX)
        end)
        -- END --
    end

    local function CreateFallingStarTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, FallingStar_W)
    end

    OnInit.trig(CreateFallingStarTrig)
end