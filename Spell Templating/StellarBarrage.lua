-- takes inspiration from SC2 Yamato Cannon (Co-op Pride of Augustgrad version)
-- requires SpellTemplate.lua
-- requires Chopinski Missiles
--[[ Ability description
    Launches a barrage of <count> projectiles towards a target enemy unit, striking it and nearby foes at random.
    (Main target is hit at least once. A single target may be hit multiple times)
]]
do
    local StellarBarrageSpellObj = Spell:Create("A01F", "unit") -- main ability object
    local function StellarBarrageCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= StellarBarrageSpellObj.id then
            return
        end

        -- stats
        local this = StellarBarrageSpellObj:NewInstance()
        local dmg = this.herodur + addSP(this.caster, 1.3)
        local missilecount = this.normaldur
        local t_delay = 0.33

        -- WC3 objects
        local ug = CreateGroup()
        local target_cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                (IsUnitEnemy(fu, this.castplayer) 
                and not IsUnitType(fu, UNIT_TYPE_DEAD) 
                and not BlzIsUnitInvulnerable(fu)
                and not IsUnitType(fu, UNIT_TYPE_MAGIC_IMMUNE))
		end)
        GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, target_cond)
        local t = CreateTimer()

        -- Main target always gets hit once!
        local stellar = Missiles:create(this.cast_x, this.cast_y, 50, this.targ_x, this.targ_y, GetUnitFlyHeight(this.target))
        stellar:model("Voidball Medium.mdx")
        stellar:speed(800)
        stellar.target = this.target
        stellar.onFinish = function()
            UnitDamageTarget(this.caster, stellar.target, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            return true
        end
        stellar:launch()

        -- Do projectiles with slight pauses
        local counter = 1
        TimerStart(t, t_delay, true, function()
            counter = counter +1
            if (counter >= missilecount) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
                DestroyCondition(target_cond)
            end

            local u = GroupPickRandomUnit(ug)
            if (u and not IsUnitType(u, UNIT_TYPE_DEAD) and not BlzIsUnitInvulnerable(u)) then 
                GroupRemoveUnit(ug, u) -- prevent multiple hits on same target
                local stellar = Missiles:create(this.cast_x, this.cast_y, 50, GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u))
                stellar:model("Voidball Medium.mdx")
                stellar:speed(800)
                stellar:curve(GetRandomReal(-10, 10))
                stellar.target = u

                stellar.onFinish = function()
                    if UnitAlive(stellar.target) then
                        UnitDamageTarget(this.caster, stellar.target, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    end
                    return true
                end
                
                stellar:launch()
            else
                -- If the target somehow died or became invulnerable in the meantime
                -- this gives another chance instead.
                counter = counter-1
                GroupRemoveUnit(ug, u)
            end
        end)
    -- END --
    end
    StellarBarrageSpellObj:MakeTrigger(StellarBarrageCast)
end