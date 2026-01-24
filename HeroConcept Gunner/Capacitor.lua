do
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
        local count=math.tointeger(GetAbilityField(RAT_id_capacitor, "normaldur", alv))
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

            -- ------ Secondary projectiles --------- --
            local ug = CreateGroup()
            GroupEnumUnitsInRange(ug, bolt.x, bolt.y, aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if IsUnitEnemy(bolt.source, GetOwningPlayer(pu)) and (count>0) then
                    count = count - 1
                    local x2, y2 = GetUnitX(pu), GetUnitY(pu)
                    local discharge = Missiles:create(bolt.x, bolt.y, 50, x2, y2, 0)
                    discharge:model("Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl")
                    discharge:speed(900)
                    discharge.source=caster
                    discharge.target=pu
                    discharge.damage = dmg * dropp

                    discharge.onFinish = function()
                        UnitDamageTarget(discharge.source, discharge.target, discharge.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        return true
                    end
                    discharge:launch()
                end
            end)
            DestroyGroup(ug)
            -- ------ Secondary projectiles END ------ --
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