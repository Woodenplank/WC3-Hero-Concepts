do

    function HellgateCast()
        -- Getters
        local u = GetTriggerUnit()
        local ug = CreateGroup()
        local alv = GetUnitAbilityLevel(u, FourCC('A00Q')) - 1

        -- Fetch ability stats
        local dmg = GetAbilityField('A00Q', "herodur", alv)
        local aoe = GetAbilityField('A00Q', "area", alv)

        -- Teleport
        local x = GetSpellTargetX()
        local y = GetSpellTargetY()
        SetUnitX(u, x)
        SetUnitY(u, y)
        DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Flamestrike\\Flamestrike1.mdl", x, y))

        -- Area damage
        GroupEnumUnitsInRange(ug, x, y, aoe, nil)
        ForGroup(ug, function()
            local enemy = GetEnumUnit()
            if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            end
        end)

        DestroyGroup(ug)
        -- END --
    end


    -- Build trigger --
    local function CreateHellgateTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, HellgateCast)
    end
    OnInit.trig(CreateHellgateTrig)
end