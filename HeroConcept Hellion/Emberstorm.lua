do
--[[
    Ignites the Hellion in a storm of fire and blades, spinning around to deal periodic damage to nearby enemies. 
    While active, the Hellion is immune to spells and disabling effects.|nLasts <A00M:AOww,HeroDur1> seconds. 
    
    |cffffcc00Level 1|r - 80 Damage per second. 
    |cffffcc00Level 2|r - 100 Damage per second. 
    |cffffcc00Level 3|r - 120 Damage per second.

    HELLFORGED BONUS; Passive: 	Emberstorm unleashes a torrent of fiery winds at random.
        40% chance per interval to create a 'e001' flame tornado, lasting 3-5 seconds (random) 

    NOTE:
    The ability is based on Bladestorm, thus all the animation and control-modding is handled by the ability.
    The trigger only takes care of area DPS and the Flame Tornado spawns.
]]
    local function EmberstormCast()
    -- Exit early if this is the wrong ability
    local abilId = GetSpellAbilityId()
    if abilId ~= FourCC("A00M") then
        return
    end

    -- Getters
    local u = GetTriggerUnit()
    local alv = GetUnitAbilityLevel(u, FourCC('A00M'))
    
    -- Ability stats
    local tinterval = 0.5
    local dmg = (60 + 20*(alv)) * tinterval
    local aoe = GetAbilityField(FourCC('A00M'), "aoe", alv-1)
    local dur = GetAbilityField(FourCC('A00M'), "herodur", alv-1)

    -- Objects
    local ug = CreateGroup()
    local t = CreateTimer()

    -- Sinhammer mod
    local SH_alv = GetUnitAbilityLevel(u, SHbuff_abilId)
    local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(SH_alv)
    if (SHbool) then
        dmg = dmg*SHdmgfactor
    end

    -- Hellforge mod
    local SevenTonguesOfPytho = ( GetUnitAbilityLevel(u, HellforgedSpells["SevenTonguesOfPytho"]) > 0 )

    TimerStart(t, tinterval, true, function()
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        -- Deal area damage
        GroupEnumUnitsInRange(ug, x, y, aoe, nil)
        ForGroup(ug, function()
            local enemy = GetEnumUnit()
            if IsUnitEnemy(u, GetOwningPlayer(enemy)) then
                UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                --Sinhammer healing
                if (SHbool) then QuickHealUnit(u, SHhealfactor*dmg) end
            end
        end)
        
        -- Flame tornados
        if SevenTonguesOfPytho then
            if (math.random() <= 0.4) then
                local summoned = CreateUnit(GetOwningPlayer(u), FourCC('e001'), x, y, 270)
                UnitApplyTimedLife(summoned, FourCC('BTLF'), math.random(3,5))
            end
        end

        -- Check for ending
        dur = dur - tinterval
        if (dur <= 0) then
            PauseTimer(t)
            DestroyTimer(t)
            DestroyGroup(ug)
        end
    end)
    -- END --
    end

    -- Build trigger --
    local function CreateEmberstormTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, EmberstormCast)
    end

    OnInit.trig(CreateEmberstormTrig)
end
