-- this uses SpellTemplate.lua
-- this uses Chopinskmissile_count missiles
do
    local function domissile(x,y, target, source, damage)
        local homingbolt = Missiles:create(x, y, 50, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + 50)

        homingbolt:model("Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl")
        homingbolt:speed(500)
        --homingbolt:arc(math.random()*45)
        homingbolt:arc(45)
        homingbolt:curve(math.random(-10, 10))
        homingbolt.target = target
        homingbolt.source = source
        
        homingbolt.onFinish = function()
            if UnitAlive(homingbolt.target) then
                UnitDamageTarget(homingbolt.source, homingbolt.target, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
            end
            return true
        end
        
        homingbolt:launch()
    end

    local ShadowPoolSpellObj = Spell:Create("A01G", "point")
    local function spcast()
        if GetSpellAbilityId() ~= ShadowPoolSpellObj.id then
            return
        end

        local this = ShadowPoolSpellObj:NewInstance()
        local dmg = this.herodur
        local bonus_chance = (addSP(this.caster, 0.5))/100  -- +0.5% chance per point of Focus

        -- sfx
        local poolsfx = AddSpecialEffect("Void Disc.mdx", this.targ_x, this.targ_y)
        BlzSetSpecialEffectScale(poolsfx, 1.1)
        --BlzSetSpecialEffectAlpha(poolsfx, 100)--/255
        BlzSetSpecialEffectColor(poolsfx, 100, 100, 150)--r/g/b

        -- blizzard objects
        local cond = Condition(function() 
            local fu = GetFilterUnit()
            return
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(fu)
		end)
        local ug = CreateGroup()
        local t = CreateTimer()

        -- periodic bombardment
        local t_interval = 0.7
        local elapsed = 0.0
        TimerStart(t, t_interval, true, function()
            -- random number of missiles; same unit may only be hit once per interval
            GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond)
            local missile_count = math.random(2,3)
            if (math.random() <= bonus_chance) then
                missile_count = missile_count + 1
            end
            for i=0,missile_count do
                ForGroup(ug, function()
                    local pu = GetEnumUnit()
                    local nx, ny = this.targ_x+math.random(-5,5), this.targ_y+math.random(-5,5)
                    domissile(nx, ny, pu, this.caster, dmg)
                    GroupRemoveUnit(ug, pu)
                end)
            end

            -- attempt  to end spell
            elapsed = elapsed + t_interval
            if elapsed >= this.normaldur then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyCondition(cond)
                DestroyGroup(ug)
                DestroyEffect(poolsfx)
            end
        end)
        -- END --
    end
    ShadowPoolSpellObj:MakeTrigger(spcast)
end