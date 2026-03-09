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
        local hot = heal * 1.5/dur

        --[[
            I also wanted this ability to purge all Poison & Disease debuffs from the Hero and nearby allies on use.
            However, in a basic test map with no debuffs, this doesn't make much sense.

            For an actual (RPG?) map implementation, fill a (global) table with Poison debuff ability IDs, 
            then feed that table into this ability
        ]]
        -- local aoe = GetAbilityField(RAT_id_sewerbrew, "aoe", alv)
        -- local init_x, init_y = GetUnitX(u), GetUnitY(u)
        -- local ug = CreateGroup()
        -- ForGroup(ug, function()
        --     local pu = GetEnumUnit()
        --     if IsUnitEnemy(u, GetOwningPlayer(pu)) then 
        --         for _,id in PoisonDebuffsList do
        --             UnitRemoveAbility(pu, debuff_id)
        --         end
        --     end
        -- end)

        QuickHealUnit(u, heal)
        -- Healing over time
        local heal_sfx = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", u, "origin")
        local t = CreateTimer()
        local tinterval = 0.5
        TimerStart(t, tinterval, true, function()
            QuickHealUnit(u, hot)

            -- Check for effect ending
            dur = dur - tinterval
            if (dur<=0) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyEffect(heal_sfx)
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