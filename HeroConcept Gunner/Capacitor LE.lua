do
    --[[ This version is functionality identical to the regular Capacitor trigger, 
        except that rather than launching additional missiles, it creates LIGHTNING EFFECTs
        that briefly attach to secondary targets, dealing damage instantaneously.
    ]]
    RAT_id_capacitor = FourCC('A019')

    local function CapacitorCast()
        -- exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= RAT_id_capacitor then
			return
		end

        -- Getters
        local target=GetSpellTargetUnit()
        local caster= GetTriggerUnit()
        local alv = GetUnitAbilityLevel(caster, RAT_id_capacitor) - 1
        local dmg = GetAbilityField(RAT_id_capacitor, "herodur", alv) + addSP(caster, 1.2)
        local aoe = GetAbilityField(RAT_id_capacitor, "aoe", alv)
        local count=math.floor(GetAbilityField(RAT_id_capacitor, "normaldur", alv))
        local dropp = 1 - 0.3

        -- Main coordinates
        local init_x, init_y = GetUnitX(caster), GetUnitY(caster)
        local x1, y1 = GetUnitX(target), GetUnitY(target)
        
        -- Main projectile
        local bolt = Missiles:create(init_x, init_y, 50, x1, y1, GetUnitFlyHeight(target) + 50)
        bolt:model("Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl")
        bolt:speed(700)
        bolt.source = caster
        bolt.target = target
        bolt.damage = dmg
        
        bolt.onFinish = function()
            UnitDamageTarget(bolt.source, bolt.target, bolt.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl", bolt.x, bolt.y))
            if false then 
                return true
            end

            -- ------ Secondary effect --------- --
            local ug = CreateGroup()
            GroupEnumUnitsInRange(ug, bolt.x, bolt.y, aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                dmg=dmg*dropp
                if IsUnitEnemy(bolt.source, GetOwningPlayer(pu)) and (count>0) then
                    count = count - 1
                    local x2, y2 = GetUnitX(pu), GetUnitY(pu)
                    local chain = AddLightningEx("CHIM", true, bolt.x, bolt.y, GetUnitFlyHeight(target) + 50, x2, y2, 50)
                    
                    UnitDamageTarget(caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    local t = CreateTimer()
                    TimerStart(t, 0.33, false, function()
                    DestroyLightning(chain)
                    PauseTimer(t)
                    DestroyTimer(t)
                    end)
                end
            end)
            DestroyGroup(ug)
            -- ------ Secondary effect END ------ --
            return true
        end
        bolt:launch()        
        -- END --
    end

    ------ Create trigger ------
    local function CreateCastTrigger()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trg, CapacitorCast)
    end

    OnInit.trig(CreateCastTrigger)
end