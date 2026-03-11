-- A.k.a. Omnislash
-- requires SpellTemplate.lua
do 
    -- ======================================================= Repeat Slash Function ======================================================= --
    local function DoSlashEffect(caster, target, damage)
        local x = GetUnitX(target) + 50 * (math.random()+math.random(-1,1))
        local y = GetUnitY(target) + 50 * (math.random()+math.random(-1,1))
        SetUnitX(caster, x)
        SetUnitY(caster, y)
        SetUnitFacingToFaceUnitTimed(caster, target, 0)
        SetUnitAnimation(caster, "spell throw gold alternate")
        UnitDamageTarget(caster, target, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
        DestroyEffect(AddSpecialEffectTarget("Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl", target, "chest"))
    end

    -- ======================================================= Active Cast Function ======================================================= --
    local function OmnislashMain()
        -- early return if wrong spell
        if GetSpellAbilityId() ~= OmniFlurrySpellObj.id then
            return
        end

        -- Ability stats
        local this = OmniFlurrySpellObj:NewInstance()
        local dmg = this.herodur
        local numhits = this.normaldur

        -- Objects
        local weaponSFX = AddSpecialEffectTarget("Sweep_Fire_Large.mdx", this.caster, "weapon")
        local ug = CreateGroup()       
        local cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                IsUnitEnemy(fu,this.castplayer)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
                and not BlzIsUnitInvulnerable(fu)
        end)

        -- Caster modifications
        PauseUnitBJ(true, this.caster)
        SetUnitVertexColorBJ(this.caster, 100, 100, 100, 25.00)
        SetUnitTimeScalePercent(this.caster, 250.00)

        -- First jump is always main target
        DoSlashEffect(this.caster, this.target, dmg)

        -- Repeat motion
        local t = CreateTimer()
        TimerStart(t, 0.5, true, function()
            -- Get a target
            GroupEnumUnitsInRange(ug, this.targ_x, this.targ_y, this.aoe, cond)
            local nextu = GroupPickRandomUnit(ug)
            
            -- Do a slash if a target is available
            if not (nextu == nil) then
                DoSlashEffect(this.caster, nextu, dmg)
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
                PauseUnitBJ(false, this.caster)
                SetUnitVertexColorBJ(this.caster, 100, 100, 100, 0.0)
                SetUnitTimeScalePercent(this.caster, 100)
                DestroyEffect(weaponSFX)
                -- Reset caster position to main target
                SetUnitX(this.caster, this.targ_x)
                SetUnitY(this.caster, this.targ_y)
            end
        end)
        -- END --    
    end
    OmniFlurrySpellObj:MakeTrigger(OmnislashMain)
end