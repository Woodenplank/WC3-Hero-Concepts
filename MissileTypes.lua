--[[ Fired towards target point, 
    will always detonate/finish on impact.
    Does not register hits between launch and destination.
]]
function PointTargetMissile(x1, y1, z1_offset, x2, y2, z2_offset,
    caster, dmg, collision, aoe, spd,
        sfx, sfx_finish, scale, arc)
    local missile = Missiles:create(x1, y1, z1_offset, x2, y2, z2_offset)
    missile:model(sfx)
    missile:speed(spd)
    missile:scale(scale)
    missile.source = caster
    missile.owner = GetOwningPlayer(caster)
    missile:vision(1)
    missile.collision = collision
    missile.damage=dmg
    
    missile.onFinish = function()
        if (aoe > 0) then
            local ug = CreateGroup()
            GroupEnumUnitsInRange(ug, missile.x, missile.y, aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if IsUnitEnemy(missile.source, GetOwningPlayer(pu)) then
                    UnitDamageTarget(missile.source, pu, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                end
            end)
            DestroyGroup(ug)
        end
        if sfx_finish ~= nil then
            DestroyEffect(AddSpecialEffect(sfx_finish, missile.x, missile.y))
        end
    end
    
    return missile
end


--[[ Fired towards target point, 
    will always detonate/finish on impact.
    will detonate early if striking an enemy unit
    No arc or intermediate adjustments
]]
function SkillShotMissile(x1, y1, z1_offset, x2, y2, z2_offset, 
        caster, dmg, collision, aoe, spd,
        sfx, sfx_finish, scale)
    
    local missile = Missiles:create(x1, y1, z1_offset, x2, y2, z2_offset)
    missile:model(sfx) --"Abilities\\Weapons\\GyroCopter\\GyroCopterImpact.mdl"
    missile:speed(spd)
    missile:scale(scale)
    missile.source = caster
    missile.owner = GetOwningPlayer(caster)
    missile:vision(1)
    missile.collision = collision
    missile.damage=dmg

    missile.onHit = function(unit)
        if UnitAlive(unit) and IsUnitEnemy(missile.source, GetOwningPlayer(unit)) then
            if (aoe > 0) then
                local ug = CreateGroup()
                GroupEnumUnitsInRange(ug, missile.x, missile.y, aoe, nil)
                ForGroup(ug, function()
                    local pu = GetEnumUnit()
                    if IsUnitEnemy(missile.source, GetOwningPlayer(pu)) then
                        UnitDamageTarget(missile.source, pu, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    end
                end)
                DestroyGroup(ug)
            else
                UnitDamageTarget(missile.source, unit, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            end
            return true
        end

        return false
    end
    missile.onFinish = function()
        --DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\GyroCopter\\GyroCopterImpact.mdl", missile.x, missile.y))
        if sfx_finish ~= nil then
            DestroyEffect(AddSpecialEffect(sfx_finish, missile.x, missile.y))
        end
        
        return false
    end

    return missile
end


--[[ Chases a particular target unit
    onFinish and onHit functions are left blank here
        They must be supplied after creation, 
        depending on desired effects
    
]]
function HomingMissileTemplate(x1, y1, z1_offset, x2, y2, z2_offset, 
        caster, target, collision, spd,
        sfx, scale)
    
    local missile = Missiles:create(x1, y1, z1_offset, x2, y2, z2_offset)
    missile:model(sfx)
    missile:speed(spd)
    missile:scale(scale)
    missile.source = caster
    missile.target = target
    missile.owner = GetOwningPlayer(caster)
    missile:vision(1)
    missile.collision = collision

    return missile
end


--[[ Continuous without stop to target point
    will always detonate/finish on impact.
    does register unit hits along the way
    Does not take AoE-param, use collision only
    
]]
function ShockwaveMissile(x1, y1, z1_offset, x2, y2, z2_offset, 
        caster, dmg, collision, spd,
        sfx, sfx_finish, scale)
    local missile = Missiles:create(x1, y1, z1_offset, x2, y2, z2_offset)
    missile:model(sfx)
    missile:speed(spd)
    missile:scale(scale)
    missile.source = caster
    missile.owner = GetOwningPlayer(caster)
    missile:vision(1)
    missile.collision = collision
    missile.damage=dmg

    missile.onHit = function(unit)
        if UnitAlive(unit) and IsUnitEnemy(missile.source, GetOwningPlayer(unit)) then
                UnitDamageTarget(missile.source, unit, missile.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
        end

        return false
    end
    -- missile.onFinish = function()
    --     --DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\GyroCopter\\GyroCopterImpact.mdl", missile.x, missile.y))
    --     if sfx_finish ~= nil then
    --         DestroyEffect(AddSpecialEffect(sfx_finish, missile.x, missile.y))
    --     end
        
    --     return false
    -- end

    return missile
end


