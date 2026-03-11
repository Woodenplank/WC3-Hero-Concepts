-- requires SpellTemplate.lua
-- requires Geometry.lua
do
--[[
    |cffffb446Wroth|r: Release your passion in a wave of Spirit-Fire, devastating enemies in a frontal cone.
]]
    local function SaintsWrothcast()
        -- early return if wrong spell
        if GetSpellAbilityId() ~= SaintsWrothSpellObj.id then
            return
        end

        -- ability stats
        local this = SaintsWrothSpellObj:NewInstance()
        local dmg = this.herodur
        local stundur = this.normaldur

        -- Target filtering
        -- (An enemy may only be damaged ONCE per cast)
        local ug = CreateGroup()
        local ug_filter = CreateGroup()
        local cond = Condition(function() 
            local fu= GetFilterUnit()
            return IsUnitEnemy(fu, this.castplayer)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitInGroup(fu, ug_filter)
        end)
    
        -- Getters
        local ang = AngleBetweenCoords(this.cast_x, this.targ_x, this.cast_y, this.targ_y)
        local slicewidth = 100 * math.pi/180
        local ang_l = ang - slicewidth/2
        --local ang_r = ang + slicewidth/2

        -- build cone (Triangular array, really)
        local spawncount = 1
        local diststep = 120
        local dist_current = diststep
        local range = this.range
        local waves = math.floor(range/diststep)

        local t = CreateTimer()
        local delay = 0.12
        TimerStart(t, delay, true, function()
            if dist_current <= range then
                local angstep = (slicewidth/spawncount)
                local ang_current = ang_l-angstep/2
                for i=1, spawncount do
                    local x,y = PolarStep(this.cast_x, this.cast_y, dist_current, ang_current + angstep)

                    DestroyEffect(AddSpecialEffect("Flamestrike I.mdx", x, y))
                    GroupEnumUnitsInRange(ug, x, y, this.aoe, cond)
                    ForGroup(ug, function()
                        local pu = GetEnumUnit()
                        UnitDamageTarget(this.caster, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        StunTarget(pu, this.caster, stundur)
                    end)
                    ang_current = ang_current + angstep
                end

                -- increment for next
                dist_current = dist_current + diststep
                spawncount = spawncount + 1
            else
                PauseTimer(t)
                DestroyTimer(t)
                DestroyGroup(ug)
                DestroyGroup(ug_filter)
                DestroyCondition(cond)
            end
        end)
    
    end
    SaintsWrothSpellObj:MakeTrigger(SaintsWrothcast)
end