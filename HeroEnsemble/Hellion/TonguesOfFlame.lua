do
--[[
    Emits 7 tongues of a flames in a circle around the hero, dealing damage (+Focus) to enemies on contact.
]]
    function TonguesOfFlameMain()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC('A00P') then
            return
        end
        -- Getters --
        local u = GetTriggerUnit()
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local alv = GetUnitAbilityLevel(u, FourCC('A00P')) - 1

        -- Ability stats
        local dmg = GetAbilityField(FourCC('A00P'), "herodur", alv) + addSP(u, 2.0)
        local area= GetAbilityField(FourCC('A00P'), "aoe", alv)
        local tongues=7
        local tonguesteps = (2*math.pi)/tongues

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        
        -- Sinhammer mod
        local SH_alv = GetUnitAbilityLevel(u, SHbuff_abilId)
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Flame effect crawl
        local dist=0
        TimerStart(t, 0.15, true, function()
            -- Protect units from being damage multiple times in one flame round
            local protgroup = CreateGroup()
            -- Draw a 'circle' of flames at current distance
            local ang = 0
            while (ang < 2 * math.pi)
            do
                -- SFX
                local new_x = x + dist * math.cos(ang)
                local new_y = y + dist * math.sin(ang)
		        DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", new_x , new_y))
                -- area damage around each flame spout
                GroupEnumUnitsInRange(ug, new_x, new_y, 150, nil)
                ForGroup(ug, function()
                    local enemy = GetEnumUnit()
                    if (IsUnitEnemy(u, GetOwningPlayer(enemy)) and not IsUnitInGroup(enemy, protgroup)) then
                        UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        GroupAddUnit(protgroup, enemy)
                        --Sinhammer healing
                        if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end
                    end
                end)
                ang = ang + tonguesteps
            end
            DestroyGroup(protgroup)
            -- Advance distance ; Check if we've reached the max
            dist = dist + 100
            if (dist >= area) then
                DestroyGroup(ug)
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
        -- END --
    end
    
    local function CreateTonguesOfFlameTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, TonguesOfFlameMain)
    end

    OnInit.trig(CreateTonguesOfFlameTrig)
end