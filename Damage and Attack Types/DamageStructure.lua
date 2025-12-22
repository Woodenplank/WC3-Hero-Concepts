do


    DamageInstance = {  -- "struct"
        source = {
            unit,       -- widget
            id,         -- GetHandleId()
            isMelee,    -- bool
            isRanged,   -- bool
        },
        target = {
            unit,       -- widget
            id,         -- GetHandleId()
            isMelee,    -- bool
            isRanged,   -- bool
        },
        damageamount,   -- number (float)
        damagetype,     -- widget damagetype
        attacktype,     -- widget attacktype
        isSpell,        -- bool
        isAttack        -- bool
    }
    function DamageInstance:new (o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end


    function CreateFromEvent()
        local this_instance = DamageInstance:new()
        this_instance.damageamount = GetEventDamage()
        this_instance.damagetype = BlzGetEventDamageType()
        this_instance.attacktype = BlzGetEventAttackType()
        this_instance.isSpell = (this_instance.attacktype == ATTACK_TYPE_NORMAL)
        this_instance.isAttack = (this_instance.damagetype == DAMAGE_TYPE_NORMAL)

        local u_source = GetEventDamageSource()
        this_instance.source.unit = u_source
        this_instance.source.handle = GetHandleId(u_source)
        this_instance.source.isMelee = IsUnitType(u_source, UNIT_TYPE_MELEE_ATTACKER)       -- unit type (7)
        this_instance.source.isRanged = IsUnitType(u_source, UNIT_TYPE_RANGED_ATTACKER)     -- unit type (8)
        local u_target = BlzGetEventDamageTarget()
        this_instance.target.unit = u_target
        this_instance.target.handle = GetHandleId(u_target)
        this_instance.target.isMelee = IsUnitType(u_target, UNIT_TYPE_MELEE_ATTACKER)       -- unit type (7)
        this_instance.target.isRanged = IsUnitType(u_target, UNIT_TYPE_RANGED_ATTACKER)     -- unit type (8)
        return this_instance
    end

end