do
    deathdrop_test_id = FourCC('A003')
    local function DeathDropBall()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= deathdrop_test_id then
			return
		end

        -- Ability stats
        local caster = GetTriggerUnit()
        local castplayer = GetOwningPlayer(caster)
        local dmg = 25        -- per lightning zap
        local dmg_end = 250   -- final explosion only
        local t_interval=0.5
        local targ_x, targ_y = GetSpellTargetX(), GetSpellTargetY()
        local duration = 8
        local aoe = 250

        -- ball setup
        local z_start = 400
        local z_end = 50
        local z_speed = ((z_start-z_end) / duration) * t_interval
        local ball = AddSpecialEffect("Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl", targ_x, targ_y)
        BlzSetSpecialEffectScale(ball,3)
        BlzSetSpecialEffectHeight(ball, z_start)
        -- these next two lines are for tilting the model the right way.
        -- They're explicitly here for FireLord's Basic attack missile
        -- If using a symmetric model like Lightning ball (farseer projectile), just remove them
        BlzSetSpecialEffectYaw(ball, math.pi*3/2)
        BlzSetSpecialEffectPitch(ball, math.pi*3/2)


        -- Blizzard objects
        local ug = CreateGroup()
        local cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                IsUnitEnemy(fu, castplayer)
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
            GroupEnumUnitsInRange(ug, targ_x, targ_y, aoe, cond)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                UnitDamageTarget(caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)

                -- Create a lightning effect between ball and targets in aoe
                local pu_x, pu_y = GetUnitX(pu), GetUnitY(pu)
                local chain = AddLightningEx("AFOD", false, targ_x, targ_y, z, pu_x, pu_y, 50)
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl", pu_x, pu_y))
                -- then removes it after 0.33 seconds
                local t_lightning = CreateTimer()
                TimerStart(t_lightning, 0.33, false, function()
                    DestroyLightning(chain)
                    PauseTimer(t_lightning)
                    DestroyTimer(t_lightning)
                end)
            end)

            --attempt to end and clean up
            dur = dur + t_interval
            if (dur>=duration) then
                -- Big kaboom ending!
                DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", targ_x, targ_y))
                GroupEnumUnitsInRange(ug, targ_x, targ_y, aoe*1.2, cond)
                ForGroup(ug, function()
                    local pu = GetEnumUnit()
                    UnitDamageTarget(caster, pu, dmg_end, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                end)
                -- clean remaining memory
                DestroyGroup(ug)
                DestroyCondition(cond)
                DestroyEffect(ball)
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
        -- END --
    end


    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        -- OR SOME OTHER MECHANIC FOR STARTING THIS EFFECT --
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, DeathDropBall)
    end

    OnInit.trig(CreateCastTrigger)
end