--[[
local cond = Condition(function() return
        IsUnitEnemy(GetFilterUnit(),player)
        and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
        and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)
        and not BlzIsUnitInvulnerable(GetFilterUnit())
    end)
]]

local function DoSlashEffect(caster, target)
    local x = GetUnitX(target) + 50 * (math.random()+math.random(-1,1))
    local y = GetUnitY(target) + 50 * (math.random()+math.random(-1,1))
    SetUnitX(caster, x)
    SetUnitY(caster, y)
    SetUnitFacingToFaceUnitTimed(u, target, 0)
    SetUnitAnimation( caster, "spell throw gold alternate" )
    UnitDamageTarget(caster, target, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
    DestroyEffect(AddSpecialEffectTarget("Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl", target, "chest"))
end

local function OmnislashMain()
    -- Getters
    local u = GetTriggerUnit()
    local tu = GetSpellTargetUnit()
    local centerX = GetUnitX(tu)
    local centerY = GetUnitY(tu)
    local alv = GetUnitAbilityLevel(FourCC('A000'), u) - 1

    -- Ability stats
    local dmg = GetAbilityField(FourCC('A000'), "herodur", alv)
    local area= GetAbilityField(FourCC('A000'), "aoe", alv)
    local numhits=GetAbilityField(FourCC('A000'), "normaldur", alv)

    -- Objects
    local ug = CreateGroup()
    local t = CreateTimer()
    local weaponSFX = AddSpecialEffectTargetUnitBJ( "weapon", u, "Sweep_Fire_Large.mdx" )
    
    -- Caster modifications
    PauseUnitBJ(true, u)
    SetUnitVertexColorBJ(u, 100, 100, 100, 25.00)
    SetUnitTimeScalePercent(u, 250.00)

    -- First jump is always main target
    DoSlashEffect(u, targ)

    -- Repeat motion
    TimerStart(t, 0.5, true, function()
        -- Get a target
        GroupEnumUnitsInRange(ug, CenterX, CenterY, aoe, cond)
        local nextu = GroupPickRandomUnit(ug)
        
        -- Do a slash if a target is available
        if not (nextu == nil) then
            DoSlashEffect(u, nextu)
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
            SetUnitVertexColorBJ(u, 100, 100, 100, 100.00)
            SetUnitTimeScalePercent(u, 100)
            DestroyEffect(weaponSFX)
            -- Reset caster position to main target
            SetUnitX(u, CenterX)
            SetUnitY(u, CenterY)
        end
    end)
    
    -- END --
end