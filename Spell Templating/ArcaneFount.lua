-- requires SpellTemplate.lua
-- requires QuickHeal.lua
-- requires Geometry.lua
do
    --[[ in-game tooltip
    Tethers all nearby allies' life forces with the [Caster], linking with them for up to <A01E:ANcl,Dur1> seconds. 
    While the tether holds, units are restored <A01E:ANcl,HeroDur1> life and 0.5 casting points per second.
    
    If an ally moves too far from the [Caster], the tether is broken.
    
    -- Healing in the tooltip is stated per-second, but we run it twice per second here for a smoother look.
    -- Hence, the actual heal value is halved after fetching from Object Data.
    ]]
    
    local ArcaneFountSpellObj = Spell:Create("A01E", "instant")
    local function ArcaneFountCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= ArcaneFountSpellObj.id then
			return
		end

        -- Ability stats
        local this = ArcaneFountSpellObj:NewInstance()
        local heal = this.herodur / 2 
        local cpheal = (alv+1)/4 -- for 0.5, 1., 1.5 per second 
        local x0, y0 = GetUnitX(this.caster), GetUnitY(this.caster)
        local z0 = BlzGetUnitRealField(this.caster, UNIT_RF_FLY_HEIGHT) + 60   -- how good this looks is going to be on a per-model basis, really

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local lightning_refs = {}
        local special_refs = {}

        -- Tether init
        GroupEnumUnitsInRange(ug, x0, y0, this.aoe, nil)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            if not IsUnitEnemy(pu, this.castplayer) then
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
            local x0, y0 = GetUnitX(this.caster), GetUnitY(this.caster)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                local this_handle = GetHandleId(pu)
                local x1, y1 = GetUnitX(pu), GetUnitY(pu)
                if (Distance(x0,x1, y0, y1) > this.aoe) or (IsUnitDeadBJ(pu)) then
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
            if elapsed >= this.dur then
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
    ArcaneFountSpellObj:MakeTrigger(ArcaneFountCast)
end