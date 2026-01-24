do
    RAT_id_sewerbrew = FourCC('A01A')

    local function SewerBrewCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= RAT_id_sewerbrew then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, RAT_id_sewerbrew) - 1
        local dur = GetAbilityField(RAT_id_sewerbrew, "normaldur", alv)
        local heal = GetAbilityField(RAT_id_sewerbrew, "herodur", alv)
        local hot = heal * 1.5/dur --3/(dur*2)
        --local aoe = GetAbilityField(RAT_id_sewerbrew, "aoe", alv)
        --local init_x, init_y = GetUnitX(u), GetUnitY(u)
        --local ug = CreateGroup()

        -- Purge
        -- TODO populate objectconstant with poison debuff IDs.        
        -- if PoisonDebuffsList then 
        --     for _,debuffcode in PoisonDebuffsList do
        --         UnitRemoveAbility(u, debuffcode)
        --     end
        -- end

        QuickHealUnit(u, heal)
        -- Healing over time
        local t = CreateTimer()
        local tinterval = 0.5
        TimerStart(t, tinterval, true, function()
            QuickHealUnit(u, hot)
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", GetUnitX(u), GetUnitY(u)))

            dur = dur - tinterval
            if (dur<=0) then
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)

        DestroyGroup()
        -- END --
    end

    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, SewerBrewCast)
    end

    OnInit.trig(CreateCastTrigger)
end