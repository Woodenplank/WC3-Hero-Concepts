-- requires HellionGlobal.lua
-- requires SpellTemplate.lua
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
        if abilId ~= HEL_emberSpell.id then
            return
        end

        -- ability stats
        local this = HEL_emberSpell:NewInstance()
        local tinterval = 0.5
        local dmg = (60 + 20*(this.alv+1)) * tinterval
        local aoe = this.aoe
        local dur = this.herodur

        -- WC3 Objects
        local ug = CreateGroup()
        local t = CreateTimer()

        -- Sinhammer mod
        local SHbool, SHdmgfactor, SHhealfactor = GetSinhammerMod(this.caster)
        if (SHbool) then
            dmg = dmg*SHdmgfactor
        end

        -- Hellforge mod
        local SevenTonguesOfPytho = (GetUnitAbilityLevel(this.caster, HellforgedSpells["SevenTonguesOfPytho"]) > 0)

        -- AoE dps
        TimerStart(t, tinterval, true, function()
            local x = GetUnitX(this.caster)
            local y = GetUnitY(this.caster)
            -- Deal area damage
            GroupEnumUnitsInRange(ug, x, y, this.aoe, nil)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                if IsUnitEnemy(pu, this.castplayer) then
                    UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    --Sinhammer healing
                    if (SHbool) then QuickHealUnit(this.caster, SHhealfactor*dmg) end
                end
            end)
            
            -- Flame tornados
            if SevenTonguesOfPytho then
                if (math.random() <= 0.4) then
                    local summoned = CreateUnit(this.castplayer, utype_FlameTornado, x, y, 270)
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
    HEL_emberSpell:MakeTrigger(EmberstormCast)
end
