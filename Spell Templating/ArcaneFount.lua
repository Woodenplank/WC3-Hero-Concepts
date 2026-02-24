do
    --[[ in-game tooltip
    Tethers all nearby allies' life forces with the [Caster], linking with them for up to <A01E:ANcl,Dur1> seconds. 
    While the tether holds, units are restored <A01E:ANcl,HeroDur1> life and 0.5 casting points per second.
    
    If an ally moves too far from the [Caster], the tether is broken.
    
    -- Healing in the tooltip is stated per-second, but we run it twice per second here for a smoother look.
    -- Hence, the actual heal value is halved after fetching from Object Data.
    ]]
    
    UAS_id_arcanefount = FourCC('A01E')

    local function ArcaneFountCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= UAS_id_arcanefount then
			return
		end

        -- Getters
        local caster= GetTriggerUnit()
        local owner = GetOwningPlayer(caster)
        local alv = GetUnitAbilityLevel(caster, UAS_id_arcanefount) - 1
        local dur = GetAbilityField(UAS_id_arcanefount, "normaldur", alv)
        local heal = GetAbilityField(UAS_id_arcanefount, "herodur", alv) / 2 
        local cpheal = (alv+1)/4 -- for 0.5, 1., 1.5 per second 
        local aoe = GetAbilityField(UAS_id_arcanefount, "aoe", alv)
        local x0, y0 = GetUnitX(caster), GetUnitY(caster)
        local z0 = BlzGetUnitRealField(caster, UNIT_RF_FLY_HEIGHT)+60   -- how good this looks is going to be on a per-model basis, really

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local lightning_refs = {}
        local special_refs = {}

        -- Tether init
        GroupEnumUnitsInRange(ug, x0, y0, aoe, nil)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            if not IsUnitEnemy(pu, owner) then
                local this_handle = GetHandleId(pu)
                local x1, y1 = GetUnitX(pu), GetUnitY(pu)
                lightning_refs[this_handle] = AddLightningEx("DRAL", false, x0, y0, z0, x1, y1, 50)
                special_refs[this_handle] = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl", pu, "chest")
            else
                GroupRemoveUnit(ug, pu)
            end
        end)

        -- periodic update
        local elapsed=0
        local t_interval = 0.05
        local count=0
        local count_max = math.floor(0.5 / t_interval) -- healing occurs every 0.5 seconds
        TimerStart(t, t_interval, true, function()
            local x0, y0 = GetUnitX(caster), GetUnitY(caster)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                local this_handle = GetHandleId(pu)
                local x1, y1 = GetUnitX(pu), GetUnitY(pu)
                if (Distance(x0,x1, y0, y1) > aoe) or (IsUnitDeadBJ(pu)) then
                    GroupRemoveUnit(ug, pu)
                    DestroyLightning(lightning_refs[this_handle])
                    DestroyEffect(special_refs[this_handle])
                    lightning_refs[this_handle] = nil
                    special_refs[this_handle] = nil
                else
                    MoveLightningEx(lightning_refs[this_handle], true, x0, y0, 50, x1, y1, 50)
                    if count == count_max then
                        QuickHealUnit(pu, heal)
                        QuickManaRestore(pu, cpheal)
                    end
                end
            end)
            
            -- tick counter
            count = count+1
            if count==count_max then
                count = 0
            end

            -- Finish and clean up
            elapsed = elapsed + t_interval
            if elapsed >= dur then
                PauseTimer(t)
                DestroyTimer(t)
                for k,v in pairs(lightning_refs) do
                    DestroyLightning(v)
                end
                for k,v in pairs(special_refs) do
                    DestroyEffect(v)
                end
                DestroyGroup(ug)
            end
        end)
        -- END --
    end


    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, ArcaneFountCast)
    end

    OnInit.trig(CreateCastTrigger)
end