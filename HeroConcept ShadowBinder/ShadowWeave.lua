-- this uses SpellTemplate.lua
-- this uses Chopinski missiles
do
    local location = Location(0., 0.)
    local rect = Rect(0., 0., 0., 0.)

    local function GetLocZ(x, y)
        MoveLocation(location, x, y)
        return GetLocationZ(location)
    end

    local function GetUnitZ(unit)
        return GetLocZ(GetUnitX(unit), GetUnitY(unit)) + GetUnitFlyHeight(unit)
    end

    local ShadowWeaveSpellObj = Spell:Create("A002", "point")
    local function swcast()
        if GetSpellAbilityId() ~= ShadowWeaveSpellObj.id then
            return
        end

        -- Ability stats
        local this = ShadowWeaveSpellObj:NewInstance()
        local dmg = this.herodur
        local heal = this.normaldur
        local healbonus = 0

        -- blizzard objects
        local count_ug = CreateGroup()
        
        -- Projectile
        local zoffset = 150
        local shadow = Missiles:create(this.cast_x, this.cast_y, zoffset, this.targ_x, this.targ_y, zoffset)
        shadow.source = this.caster
        shadow:model("Voidball Major.mdx")
        shadow:speed(500)
        shadow:vision(500)
        --shadow:scale(1.5)
        shadow.damage = dmg
        shadow.collision = this.aoe
        shadow.deflected = false

        shadow.onHit = function(unit)
            if shadow.deflected==false and UnitAlive(unit) and IsUnitEnemy(shadow.source, GetOwningPlayer(unit)) then
                UnitDamageTarget(shadow.source, unit, shadow.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                GroupAddUnit(count_ug, unit)
            end
            if shadow.deflected==true and UnitAlive(unit) and not IsUnitEnemy(shadow.source, GetOwningPlayer(unit)) then
                QuickHealUnit(unit, healbonus)
                DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", GetUnitX(unit), GetUnitY(unit)))
            end
            
            return false
        end
        shadow.onFinish = function()
            if not shadow.deflected then
                shadow.deflected = true
                shadow:deflect(GetUnitX(shadow.source), GetUnitY(shadow.source), zoffset)
                shadow.target = this.caster
                shadow:flushAll()
                shadow:model("Voidball Medium.mdx")
                --shadow:scale(1.5)
                healbonus = heal * (1 + (CountUnitsInGroup(count_ug)*0.05))
                DestroyGroup(count_ug)
            end
            return false
        end
        shadow:launch()
        -- END --
    end
    ShadowWeaveSpellObj:MakeTrigger(swcast)
end