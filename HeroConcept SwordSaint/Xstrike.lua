do
    --[[
        In-game name is "Wrath" - I'm retaining the name "Xstrike" here because it's more descriptive.
        
        Causes a burst of spirit-fire in an cross pattern around the Sword-Saint, dealing damage (|cffdbb8eb+130% Focus|r) to foes struck and healing allies (|cffdbb8eb+200% Focus|r).
        
        |cffffcc00Level 1|r - <A005:ANcl,HeroDur1> damage, <A005:ANcl,Dur1> healing. 
        |cffffcc00Level 2|r - <A005:ANcl,HeroDur2> damage, <A005:ANcl,Dur2> healing. 
        |cffffcc00Level 3|r - <A005:ANcl,HeroDur3> damage, <A005:ANcl,Dur3> healing.
    ]]
    local function XstrikeCast()
        -- Exit early if it's the wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= HSS_id_xstrike then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, HSS_id_xstrike) - 1
        
        -- Fetch ability stats
        local dmg = GetAbilityField(HSS_id_xstrike, "herodur", alv) + addSP(u, 1.3)
        local heal= GetAbilityField(HSS_id_xstrike, "normaldur", alv) + addSP(u, 2.0)
        local aoe = GetAbilityField(HSS_id_xstrike, "area", alv)
        local stepsize = 175
        local range = 4*stepsize
        
        -- Objects
        local ug = CreateGroup()

        -- Center of spell
        local x_0 = GetUnitX(u)
        local y_0 = GetUnitY(u)
        DestroyEffect(AddSpecialEffect("Flamestrike I.mdx", x_0, y_0))

        -- "Draw points and blast them"
        local dist = stepsize
        while (dist <= range)
        do
            -- Draw 4 explosions around Hero, starting at 45 degrees
            local ang = math.pi/4
            while (ang <= 2*math.pi)
            do
                x_1, y_1 = PolarStep(x_0, y_0, dist, ang)
                -- Area damage and healing
                GroupEnumUnitsInRange(ug, x_1, y_1, aoe, nil)
                ForGroup(ug, function()
                    local pickedu = GetEnumUnit()
                    if (IsUnitEnemy(u, GetOwningPlayer(pickedu))) then
                        UnitDamageTarget(u, pickedu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    else
                        QuickHealUnit(pickedu, heal)
                    end
                    --DestroyEffect(AddSpecialEffectTarget("Flamestrike I.mdx", pickedu, 'chest'))
                end)
                DestroyEffect(AddSpecialEffect("Flamestrike I.mdx", x_1, y_1))
                ang = ang + math.pi/2
            end
            -- move further outwards
            dist = dist + stepsize
        end

        -- Clean memory
        DestroyGroup(ug)
        -- END --
    end

    -- Build trigger --
    local function CreateXstrikeTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, XstrikeCast)
    end
    OnInit.trig(CreateXstrikeTrig)
end