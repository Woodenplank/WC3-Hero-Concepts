-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
-- requires QuickHeal.lua
-- requires Geometry.lua
do
    local function ChargeCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= HEL_chargeSpell.id then
			return
		end

        -- Ability stats
        local this = HEL_chargeSpell:NewInstance()
        local dmg = this.herodur

        -- Sinhammer mod
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(this.caster)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Objects
        local ug = CreateGroup()
        local protgroup = CreateGroup()
        local t = CreateTimer()

        -- Geometry
        local x_0 = this.cast_x
        local y_0 = this.cast_y
        local x_2 = this.targ_x
        local y_2 = this.targ_y
        local ang = AngleBetweenCoords(x_0, x_2, y_0, y_2)

        -- Prep caster
        local sfx = AddSpecialEffectTarget("Valiant Charge.mdx", this.caster, 'origin')
        PauseUnit(this.caster, true)
        SetUnitPathing(this.caster, false) -- collision Off

        -- Motion
        TimerStart(t, 0.03, true, function()
            -- move hero forwards
            local x_1, y_1 = PolarStep(GetUnitX(this.caster), GetUnitY(this.caster), 20, ang)
            SetUnitX(this.caster, x_1)
            SetUnitY(this.caster, y_1)

            -- Area damage
            GroupEnumUnitsInRange(ug, x_1, y_1, this.aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if (IsUnitEnemy(pu, this.casterplayer) and not IsUnitInGroup(pu, protgroup)) then
                    UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    GroupAddUnit(protgroup, pu)
                    --Sinhammer healing
                   if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end
                end
            end)

            -- Check for destination
            if (Distance(x_1,x_2,y_1,y_2) <= 30) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyEffect(sfx)
                DestroyGroup(ug)
                DestroyGroup(protgroup)
                --Reset caster
                PauseUnit(this.caster, false)
                SetUnitPathing(this.caster, true)
            end
        end)
        -- END --
    end
    HEL_chargeSpell:MakeTrigger(ChargeCast)
end