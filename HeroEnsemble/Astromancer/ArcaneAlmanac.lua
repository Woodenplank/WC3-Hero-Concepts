--[[
In-game Tooltip
"Passive: All ability damage has a chance to critically hit, dealing 150% of normal damage.
Active: Empower your next Falling Star. Guaranteeing a critical, adding 5% bonus damage per active Sprite, and the Celestial lasts 30% longer."
]]

-- Globals --
AlmanacBuff_AbilId = FourCC('ASTRAL_DUMMY_THING')
Almanac_AbilId = FourCC('OmgOmgYouGuys') --- TODO: adjust this to the proper editor value...
-------------

do
    --[[ The below trigger handles the >Active< part.
    See further down for the global crit functions. ]]
    local function ArcaneAlmanacActive()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC("A00B") then
            return
        end

        -- Getters
        local u = GetTriggerUnit()
        local alv = GetUnitAbilityLevel(u, FourCC('A00B')) - 1

        -- Get Starsprite count
        local ug = CreateGroup()
        local cond = Condition(function() return UnitTypeCheck(GetFilterUnit(), 'o000') end)
        GroupEnumUnitsOfPlayer(ug, GetOwningPlayer(u), cond)
        local count = CountUnitsInGroup(ug)

        -- Ability stats
        local dur = GetAbilityField(FourCC('A00B'), "normaldur", alv)

        -- Dummy buff ability (also used to check bonus on Falling Star)
        UnitAddAbility(u, FourCC('ASTRAL_DUMMY_THING'))
        SetUnitAbilityLevel(u, FourCC('ASTRAL_DUMMY_THING'), count)

        -- Expiration
        local t = CreateTimer()
        StartTimer(t, dur, false, function()
            UnitRemoveAbility(u, FourCC('ASTRAl_DUMMY_THING'))
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- Clean memory
        DestroyGroup(ug)
        DestroyCondition(cond)
        -- END --
    end

    -- Build trigger --
    local function CreateArcaneAlmanacTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, ArcaneAlmanacActive)
    end

    OnInit.trig(CreateArcaneAlmanacTrig)
end

------------------------------------------------ ARCANE ALMANAC GLOBALS ------------------------------------------------------------------------

---@param caster unit
---@return boolean, number
function AlmaStarmod(caster)
    --[[
        Specifically used with FALLING STAR and ARCANE ALMANAC.
        
        If caster has Arcane_Almanac_Active_buff:
            Returns TRUE, DamageBonusModifier
        Else
            Returns FALSE, 1.0
    ]]
    local lvl = GetUnitAbilityLevel(caster, AlmanacBuff_AbilId)
    if (lvl > 0) then
        return true, (1.5 + lvl * 0.05)
    end
    -- Default
    return false, 1.0
end

----------------------------------------------------------------------------------------------------------------------------------

---@param caster unit
---@return number
function GetAlmaCritmod(caster)
    -- Gets the critical damage mod (multiplier) for the caster through Arcane Almanac
    -- If the caster does not have the ability, returns 1.0 (no additional damage)
    local alv = GetUnitAbilityLevel(caster, Almanac_AbilId)
    if (alv > 0) then
        return 1.5
    end
    -- Default
    return 1.0
end

---@param caster unit
---@return number
function GetAlmaCritchance(caster)
    -- Gets the chance (as a float between 0 and 1) for the caster to deal critical damage through Arcane Almanac
    -- If the caster does not have the ability, returns 0.0
    local alv = GetUnitAbilityLevel(caster, Almanac_AbilId)
    if (alv > 0) then
        return GetAbilityField(Almanac_AbilId, "herodur", alv-1)
    end
    -- Default
    return 0.0
end


---@param caster unit
---@return number
function AlmaCrit(caster)
    --[[
        Full critical calculation.
        Determines if the caster does a critical hit through Arcane Almanac. 
            If yes; returns the critical multiplier
            If no; (ability not learned or bad random roll) returns 1.0
    ]]
    local alv = GetUnitAbilityLevel(caster, Almanac_AbilId)
    -- Early return if ability not learnt
    if (alv == 0) then
        return 1.0
    end

    -- Fetch ability stats
    local critmod = 1.5
    local critchance = GetAbilityField(Almanac_AbilId, "herodur", alv-1)

    -- Roll for crit
    if (math.random() <= critchance) then
        return critmod
    end
    -- Default
    return 1.0
end