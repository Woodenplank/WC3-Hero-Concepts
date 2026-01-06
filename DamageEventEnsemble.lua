do

    --[[ 
        !!! Do NOT import this into the map !!!

        This is an experimental setup, which is not yet complete.
    ]]

    lethal_threshold = 0.405    -- this is the health where the game registers lethal. For some reason.

    ShieldAbilities = {
        NetherWeaver = {
            buffID = FourCC('A00F'),
            sfxID="PinkMagicShield_.mdx",
            shield = {},
            shieldSFX={}
        },
        Imaginary = {
            buffID = FourCC('ZZZZ'),
            sfxID = "Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl",
            shield = {},
            shieldSFX = {}
        },
        something = {
            buffID = FourCC('XXXX'),
            sfxID = "",
            shield = {},
            shieldSFX = {}
        }
    }


    local function LethalDamageTrigger()
        local instance = CreateFromEvent()
        local isLethal = (GetUnitState(instance.target.unit, UNIT_STATE_LIFE) < lethal_threshold) and (instance.damageamount >= lethal_threshold)
        if not isLethal then
            return
        end
        -- ...
    end

    local function pre_damaging_actions()
        -- triggers before any armor, armor type, and other resistances are applied.
        local instance = CreateFromEvent()
        if ((instance.damageamount) == 0) then
            return
        end
        local damage_remain = instance.damageamount

        ------------------ Damage Shields ------------------        
        for spell,spelltable in pairs(ShieldAbilities) do
        ----key,value
            local shield_remain = (spelltable.shield[instance.target.id] or 0)
            if (shield_remain >= damage_remain) then
                -- the damage dealt has now been fully blocked
                shield_remain = shield_remain - damage_remain
                damage_remain = 0
                spelltable.shield[instance.target.id] = shield_remain
                -- Early loop exit?
            else
                -- damage not completely blocked. Remove current-loop shield, update damage for next run
                damage_remain = damage_remain - shield_remain
                spelltable.shield[instance.target.id] = 0
                DestroyEffect(spelltable.shieldSFX[instance.target.id])
                UnitRemoveAbility(instance.target.unit, spelltable.buffID)
        end

        -- All shield loops finished
        if (damage_remain) >= 0 then
            BlzSetEventDamage(damage_remain)
        else -- avoiding negative damage
            BlzSetEventDamage(0)
            return
        end

        --------------- Damage reduction or deflection AFTER shields ---------------
        

        -- END --
    end

    local function CreateLethalTrigger()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, LethalDamageTrigger)
    end

    local function CreatePreDamageTrigger()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddAction(tr, pre_damaging_actions)
    end

    OnInit.trig(CreatePreDamagingTrigger)
end