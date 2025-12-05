--[[
    ...
    Some implementation of damage detection
    ...
    ...
]]

local guard = DamageEventTarget
local atcker= DamageEventSource
local guardchance = 0 -- get value from unit level/buff activity
if (math.random() <= guardchance) then
    if (IsDamageMelee) then
        local dmg = DamageEventPrevAmount * 0.5
        NextDamageType = DamageEventAttackT
        UnitDamageTarget(guard, atcker, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
        DamageEventAmount = dmg
    elseif (IsDamageRanged) then
        DamageEventAmount = DamageEventAmount * 0.1
    end
    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", guard, 'chest'))
end
