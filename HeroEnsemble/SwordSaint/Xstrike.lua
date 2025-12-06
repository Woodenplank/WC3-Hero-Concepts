do
    --[[
        In-game name is "Wrath" - I'm retaining the name "Xstrike" here because it's more descriptive.
    ]]
    local function XstrikeCast()
        -- Exit early if it's the wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= FourCC('A005') then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, FourCC('A005')) - 1
        
        -- Fetch ability stats
        local dmg = GetAbilityField(FourCC('A005'), "herodur", alv) + addSP(u, 1.3)
        local heal= GetAbilityField(FourCC('A005'), "normaldur", alv) + addSP(u, 2.0)
        local aoe = GetAbilityField(FourCC('A005'), "area", alv)
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