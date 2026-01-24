do
    RAT_id_blast=FourCC('A014')
    RAT_id_blastArmorDebuff=FourCC('A016')

    local function ChargedBlast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= RAT_id_blast then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, RAT_id_blast) - 1
        local dur = GetAbilityField(RAT_id_blast, "normaldur", alv)
        local dmg = GetAbilityField(RAT_id_blast, "herodur", alv)
        local rng = GetAbilityField(RAT_id_blast, "range", alv) + 100
        local aoe = GetAbilityField(RAT_id_blast, "aoe", alv)

        local unit_x, unit_y = GetUnitX(u), GetUnitY(u)
        local targ_x, targ_y = GetSpellTargetX(), GetSpellTargetY()
        local ang = AngleBetweenCoords(unit_x, targ_x, unit_y, targ_y)

        -- Adjust targeting, launch projectile
        local targ_x, targ_y = PolarStep(unit_x, unit_y, rng, ang)
        local model_str = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
        local bullet_spd = 1000
        local bullet_collision = aoe
        local missile = ShockwaveMissile(unit_x, unit_y, 30, targ_x, targ_y, 30, u, dmg, bullet_collision, bullet_spd, model_str, nil, 1.0)
        
        -- specify a new onHit function to include debuffing
        missile.onHit = function(unit)
            if UnitAlive(unit) and IsUnitEnemy(missile.source, GetOwningPlayer(unit)) then
                UnitDamageTarget(missile.source, unit, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                
                -- Debuff
                UnitAddAbility(unit, RAT_id_blastArmorDebuff)
                SetUnitAbilityLevel(unit, RAT_id_blastArmorDebuff, alv+1)
                local t = CreateTimer()
                TimerStart(t, dur, true, function()
                    UnitRemoveAbility(unit, RAT_id_blastArmorDebuff)
                    PauseTimer(t)
                    DestroyTimer(t)
                end)
            end

            return false
        end
        missile:launch()
    -- END --
    end

    ------------------ Create the triggers ------------------
    local function CreateChargedBlastCast()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, ChargedBlast)
    end

    OnInit.trig(CreateChargedBlastCast)
end