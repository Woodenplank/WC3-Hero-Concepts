-- requires SpellTemplate.lua
-- requires Geometry.lua
do
    local function DashCast()
        local abilId = GetSpellAbilityId()
		if abilId ~= DashSpellObj.id then
			return
		end

        -- Ability stats
        local this = DashSpellObj:NewInstance()
        local dmg = this.herodur

        -- Objects
        local ug = CreateGroup()
        local protgroup = CreateGroup()
        local t = CreateTimer()
        local cond = Condition(function() 
            local fu= GetFilterUnit()
            return IsUnitEnemy(fu, this.castplayer)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitInGroup(fu, protgroup)
        end)

        -- Geometry
        local x_0, y_0 = this.cast_x, this.cast_y
        local x_2, y_2 = this.targ_x, this.targ_y
        local ang = AngleBetweenCoords(x_0, x_2, y_0, y_2)

        -- Prep caster
        local sfx = AddSpecialEffectTarget("Valiant Charge.mdx", this.caster, 'origin')
        PauseUnit(this.caster, true)
        SetUnitPathing(this.caster, false)

        -- Smooth slide
        TimerStart(t, 0.03, true, function()
            local x_1, y_1 = PolarStep(GetUnitX(this.caster), GetUnitY(this.caster), 20, ang)
            SetUnitX(this.caster, x_1)
            SetUnitY(this.caster, y_1)

            -- Area damage
            GroupEnumUnitsInRange(ug, x_1, y_1, this.aoe, cond)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                GroupAddUnit(protgroup, pu)
            end)

            -- Check for destination
            if (Distance(x_1,x_2,y_1,y_2) <= 30) then
                --Reset caster
                PauseUnit(this.caster, false)
                SetUnitPathing(this.caster, true)

                -- clean memory
                PauseTimer(t)
                DestroyTimer(t)
                DestroyEffect(sfx)
                DestroyGroup(ug)
                DestroyGroup(protgroup)
                DestroyCondition(cond)
            end
        end)
        -- END --
    end
    DashSpellObj:MakeTrigger(DashCast)
end