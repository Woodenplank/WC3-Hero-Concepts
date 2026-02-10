do
    --[[ Null Zone
        Nullifies magical and life forces in target area, dealing constant damage to enemies in the zone.
        Friendly units within the barrier take reduced damage from incoming magic or spell attacks.

        Level 1 - <A003:ANcl,HeroDur1> damage per second, 15% damage reduction.
        Level 2 - <A003:ANcl,HeroDur2> damage per second, 30% damage reduction.
        Level 3 - <A003:ANcl,HeroDur3> damage per second, 45% damage reduction.    
    ]]
    
    SHA_id_nullzonebuff = FourCC("B000")
    local function NullZoneShield()
        local instance = CreateFromEvent()

        -- Early return if the unit doesn't have the shield buff (dummy ability)
        local alv = GetUnitAbilityLevel(instance.target.unit, SHA_id_nullzonebuff)
        if (alv <= 0) then
            return
        end
        local reduc = alv*0.15 -- DAMAGE REDUCTION PERCENTAGE HERE
        local atype = BlzGetEventAttackType()
        print(tostring(atype))
        if (atype==ATTACK_TYPE_NORMAL or atype==ATTACK_TYPE_MAGIC) then
            BlzSetEventDamage(instance.damageamount*(1-reduc))
        end 
        -- END --
    end
    
    local function CreateShieldTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, NullZoneShield)
    end
    OnInit.trig(CreateShieldTrig)


    ----------------------------------------------------------------------------------------------------------


    local NullZoneSpellObj = Spell:Create("A003", "point")
    local function nzcast()
        if GetSpellAbilityId() ~= NullZoneSpellObj.id then
            return
        end

        local this = NullZoneSpellObj:NewInstance()
        local dmg = this.herodur / 2
        --local heal = this.herodur
        --local aoe = 300

        -- sfx
        local nullzone_sfx = AddSpecialEffect("AntimagicBarrier_Necrotic.mdx", this.targ_x, this.targ_y)

        -- blizzard objects
        local cond_enemy = Condition(function()
            local fu = GetFilterUnit()
            return
			IsUnitEnemy(fu, this.castplayer)
			and not IsUnitType(fu, UNIT_TYPE_DEAD)
			and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
			and not BlzIsUnitInvulnerable(fu)
		end)
        -- local cond_friend = Condition(function() 
        --     local fu = GetFilterUnit()
        --     return
		-- 	not IsUnitType(fu, UNIT_TYPE_DEAD)
		-- 	and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
		-- end)
        local ug = CreateGroup()
        
        -- Dummy
        local dummy = CreateUnit(GetOwningPlayer(this.caster), FourCC('e000'), this.targ_x, this.targ_y, 270)
        UnitApplyTimedLifeBJ(this.normaldur - 1, FourCC('BTLF'), dummy)
        UnitAddAbility(dummy, FourCC("A004"))
        SetUnitAbilityLevel(dummy, FourCC("A004"),this.alv+1)

        -- periodic effect
        local t = CreateTimer()
        local t_interval = 0.5
        local elapsed = 0.0
        TimerStart(t, t_interval, true, function()
            -------------
            GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond_enemy)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            end)
            -- GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond_friend)
            -- ForGroup(ug, function()
            --     local pu = GetEnumUnit()
            --     QuickHealUnit(pu, heal)          
            -- end)

            -- attempt  to end spell
            elapsed = elapsed + t_interval
            if elapsed >= this.normaldur then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyCondition(cond_enemy)
                --DestroyCondition(cond_friend)
                DestroyGroup(ug)
                DestroyEffect(nullzone_sfx)
            end
        end)
        -- END --
    end
    NullZoneSpellObj:MakeTrigger(nzcast)
end