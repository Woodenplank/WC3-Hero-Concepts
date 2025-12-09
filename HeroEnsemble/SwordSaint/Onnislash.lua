do
--[[
local cond = Condition(function() return
        IsUnitEnemy(GetFilterUnit(),player)
        and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
        and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
        and not BlzIsUnitInvulnerable(GetFilterUnit())
    end)
]]

    local function DoSlashEffect(caster, target, damage)
        local x = GetUnitX(target) + 50 * (math.random()+math.random(-1,1))
        local y = GetUnitY(target) + 50 * (math.random()+math.random(-1,1))
        SetUnitX(caster, x)
        SetUnitY(caster, y)
        SetUnitFacingToFaceUnitTimed(caster, target, 0)
        SetUnitAnimation( caster, "spell throw gold alternate" )
        UnitDamageTarget(caster, target, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
        DestroyEffect(AddSpecialEffectTarget("Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl", target, "chest"))
    end

    local function OmnislashMain()
        -- Exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= FourCC("A000") then
			return
		end

        -- Getters
        local u = GetTriggerUnit()
        local tu = GetSpellTargetUnit()
        local centerX = GetUnitX(tu)
        local centerY = GetUnitY(tu)
        local alv = GetUnitAbilityLevel(u, FourCC('A000')) - 1

        -- Ability stats
        local dmg = GetAbilityField(FourCC('A000'), "herodur", alv)
        local aoe = GetAbilityField(FourCC('A000'), "aoe", alv)
        local numhits=GetAbilityField(FourCC('A000'), "normaldur", alv)

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        local weaponSFX = AddSpecialEffectTargetUnitBJ( "weapon", u, "Sweep_Fire_Large.mdx" )
        local cond = Condition(function() return
            IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(u))
            and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
            and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
            and not BlzIsUnitInvulnerable(GetFilterUnit())
        end)

        -- Caster modifications
        PauseUnitBJ(true, u)
        SetUnitVertexColorBJ(u, 100, 100, 100, 25.00)
        SetUnitTimeScalePercent(u, 250.00)

        -- First jump is always main target
        DoSlashEffect(u, tu, dmg)

        -- Repeat motion
        TimerStart(t, 0.5, true, function()
            -- Get a target
            GroupEnumUnitsInRange(ug, centerX, centerY, aoe, cond)
            local nextu = GroupPickRandomUnit(ug)
            
            -- Do a slash if a target is available
            if not (nextu == nil) then
                DoSlashEffect(u, nextu, dmg)
            else
                numhits = 1
            end
            
            -- Check for finish
            numhits = numhits - 1
            if (numhits == 0) then
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
                DestroyCondition(cond)
                -- Reset Caster state/visuals
                PauseUnitBJ(false, u)
                SetUnitVertexColorBJ(u, 100, 100, 100, 0.0)
                SetUnitTimeScalePercent(u, 100)
                DestroyEffect(weaponSFX)
                -- Reset caster position to main target
                SetUnitX(u, centerX)
                SetUnitY(u, centerY)
            end
        end)
        -- END --    
    end

    -- Build trigger --
    local function CreateOmnislashTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, OmnislashMain)
    end
    OnInit.trig(CreateOmnislashTrig)
end