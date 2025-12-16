do
    --[[
    Dashes to target location, dealing damage (|cffdbb8eb+100% Focus|r) to enemies along the path. 
    
    |cffffcc00Level 1|r - <A004:ANcl,HeroDur1> damage, <A004:ANcl,Cool1> seconds cooldown. 
    |cffffcc00Level 2|r - <A004:ANcl,HeroDur2> damage, <A004:ANcl,Cool2> seconds cooldown. 
    |cffffcc00Level 3|r - <A004:ANcl,HeroDur3> damage, <A004:ANcl,Cool3> seconds cooldown.
    ]]

    local function DashCast()
        local abilId = GetSpellAbilityId()
		if abilId ~= FourCC("A004") then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, FourCC('A004')) - 1
        
        -- Fetch ability stats
        local dmg = GetAbilityField(FourCC('A004'), "herodur", alv)
        local aoe = GetAbilityField(FourCC('A004'), "area", alv)
        local range=GetAbilityField(FourCC('A004'), "range", alv)

        -- Objects
        local ug = CreateGroup()
        local protgroup = CreateGroup()
        local t = CreateTimer()

        -- Geometry
        local x_0 = GetUnitX(u)
        local y_0 = GetUnitY(u)
        local x_2 = GetSpellTargetX()
        local y_2 = GetSpellTargetY()
        local ang = AngleBetweenCoords(x_0, x_2, y_0, y_2)

        -- Prep caster
        local sfx = AddSpecialEffectTarget("Valiant Charge.mdx", u, 'origin')
        PauseUnit(u, true)
        SetUnitPathing( u, false ) -- collision Off

        -- Motion
        TimerStart(t, 0.03, true, function()
            -- move hero forwards
            local x_1, y_1 = PolarStep(GetUnitX(u), GetUnitY(u), 20, ang)
            SetUnitX(u, x_1)
            SetUnitY(u, y_1)

            -- Area damage
            GroupEnumUnitsInRange(ug, x_1, y_1, aoe, nil)
            ForGroup(ug, function()
                local enemy = GetEnumUnit()
                if (IsUnitEnemy(u, GetOwningPlayer(enemy)) and not IsUnitInGroup(enemy, protgroup)) then
                    UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    GroupAddUnit(protgroup, enemy)
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
                PauseUnit(u, false)
                SetUnitPathing(u, true)
            end
        end)
        -- END --
    end

    -- Build trigger --
    local function CreateDashTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, DashCast)
    end
    OnInit.trig(CreateDashTrig)
end