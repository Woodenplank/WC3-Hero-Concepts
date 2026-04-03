-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
-- requires QuickHeal.lua
-- requires AbilityPowerScale.lua
do
--[[
    Emits 7 tongues of a flames in a circle around the hero, dealing damage (+Focus) to enemies on contact.
]]
    local function TonguesOfFlameMain()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= HEL_ftonguesSpell.id then
            return
        end

        -- Ability stats
        local this = HEL_ftonguesSpell:NewInstance()
        local dmg = this.herodur + addSP(this.caster, 2.0)
        local area = this.aoe
        local tongues = 7
        local tonguesteps = (2*math.pi)/tongues

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        
        -- Sinhammer mod
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(this.caster)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Flame effect crawl
        local dist=0
        TimerStart(t, 0.15, true, function()
            -- Protect units from being damage multiple times in one flame round
            local protgroup = CreateGroup()
            
            -- Draw a 'circle' of flames at current distance
            local ang = 0
            while (ang < 2 * math.pi) do
                local new_x = this.cast_x + dist * math.cos(ang)
                local new_y = this.cast_y + dist * math.sin(ang)
                ang = ang + tonguesteps
		        
                -- Damage enemies around each flamesprout
                DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", new_x , new_y))
                GroupEnumUnitsInRange(ug, new_x, new_y, 150, nil)
                ForGroup(ug, function()
                    local pu = GetEnumUnit()
                    if (IsUnitEnemy(pu, this.castplayer) and not IsUnitInGroup(pu, protgroup)) then
                        UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        GroupAddUnit(protgroup, pu)
                        --Sinhammer healing
                        if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end
                    end
                end)
            end
            DestroyGroup(protgroup)

            -- Advance distance ; Check if we've reached the max
            dist = dist + 100
            if (dist >= area) then
                DestroyGroup(ug)
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
        -- END --
    end
    HEL_ftonguesSpell:MakeTrigger(TonguesOfFlameMain)
end