do 
    --[[
    
    ]]
    local function FallingStar_W()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A00B") then
            return
        end
 
        -- Getters
        local u = GetTriggerUnit()
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        local lvl = GetUnitAbilityLevel(u, abilId) - 1
 
        -- Stats
        local dmg = GetAbilityField(FourCC('A00B'), "herodur", lvl)
        local aoe = GetAbilityField(FourCC('A00B'), "area", lvl)
 
        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Setup sfx
        local effect StarSFX = AddSpecialEffect("Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl", x , y)
	    BlzSetSpecialEffectScale( StarSFX, 2.0 )
	    BlzSetSpecialEffectTimeScale( StarSFX, 0.5 )

        -- Delayed damage effect
        local delay = 1.5
        TimerStart(t, delay, false, function()
            local boolean DoBlackHole = false
            -- Deal AoE damage
            GroupEnumUnitsInRange(ug, x, y, aoe, nil)
            ForGroup(ug, function()
                local pickedu = GetEnumUnit()
                if IsUnitEnemy(u, GetOwningPlayer(pickedu)) then
                    UnitDamageTarget(u, pickedu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                elseif ((GetUnitTypeId(pickedu) == 'e002' )) then
                    DoBlackHole = true
                    BlackHoleChecks[GetHandleId(pickedu)]=true
                end
            end)
    
            -- Celestial spawn / if we're not doing a black hole
            if not DoBlackHole then
                local Celest = CreateUnit(GetOwningPlayer(u), 'o003', x, y, 0)
	            UnitApplyTimedLifeBJ( 13.0, FourCC('BTLF'), Celest)
            end
                        
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