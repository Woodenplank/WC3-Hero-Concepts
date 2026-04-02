-- requires Chopinski's Missile system
-- requires SpellTemplate.lua
--[[ Ability description
    Creates a fiery orb over target area, which will periodically launch fiery projectiles upon nearby foes.
]]
do
    local FlameBallSpellObj = Spell:Create("A001", "point")

    local function FlameBallCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= FlameBallSpellObj.id then
			return
		end

        -- Ability stats
        local this = FlameBallSpellObj:NewInstance()
        local dmg = this.herodur        -- per projectile
        local t_interval=0.5


        -- fireball
        local z_start = 400
        local z_end = 50
        local z_speed = ((z_start-z_end) / this.normaldur) * t_interval
        local ball = AddSpecialEffect("Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl", this.targ_x, this.targ_y)
        BlzSetSpecialEffectScale(ball,3)
        BlzSetSpecialEffectHeight(ball, z_start)

        -- Rotate so it looks pretty (Firelord Projectile)
        BlzSetSpecialEffectYaw(ball, math.pi*3/2)
        BlzSetSpecialEffectPitch(ball, math.pi*3/2)


        -- Blizzard objects
        local ug = CreateGroup()
        local cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                IsUnitEnemy(fu, this.castplayer)
                and not IsUnitType(fu, UNIT_TYPE_DEAD) 
                and not IsUnitType(fu, UNIT_TYPE_STRUCTURE) 
                and not BlzIsUnitInvulnerable(fu)
        end)

        -- periodicity
        local t = CreateTimer()
        local dur = 0
        local z = z_start
        TimerStart(t, t_interval, true, function()
            -- D-d-d-d-drop the ball
            z = z - z_speed
            BlzSetSpecialEffectHeight(ball, z)
            
            -- area damage
            GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                local firebolt = Missiles:create(this.targ_x, this.targ_y, z+30, GetUnitX(pu), GetUnitY(pu), GetUnitFlyHeight(pu) + 50)
                firebolt:model("Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl")
                firebolt:speed(500)
                firebolt:arc(15)
                firebolt.target = pu
                firebolt.source = this.caster
                
                firebolt.onFinish = function()
                    UnitDamageTarget(firebolt.source, firebolt.target, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    return true
                end
                
                firebolt:launch()
            end)

            --attempt to end and clean up
            dur = dur + t_interval
            if (dur>=this.normaldur) then
                ---- cleanup ----
                DestroyEffect(ball)
                PauseTimer(t)
                DestroyTimer(t)                
                DestroyGroup(ug)
                DestroyCondition(cond)
                -- fancy ending special effect... ?
                -- spawn something?
                -- big, final aoe explosion?
            end
        end)
        -- END --
    end


    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, FlameBallCast)
    end

    OnInit.trig(CreateCastTrigger)
end