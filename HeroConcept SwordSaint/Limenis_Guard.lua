-- requires SpellTemplate.lua
-- requires HideAbilitySafe.lua
-- requires (explicitly) GetAbilityField.lua
do
-- =================================================== Deflection Effects ======================================================= --

    local function GuardVisual(source, target)
        local x_source = GetUnitX(source)
        local y_source = GetUnitY(source)
        local x_target = GetUnitX(target)
        local y_target = GetUnitY(target)
        local ang = AngleBetweenCoords(x_target,x_source, y_target,y_source)
        local sfx_x, sfx_y = PolarStep(x_target, y_target, 65, ang)
        local sfx = AddSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", sfx_x, sfx_y)
        BlzSetSpecialEffectZ(sfx, 100+GetUnitFlyHeight(target))
        BlzSetSpecialEffectColor(sfx, 255, 255, 255)
        BlzSetSpecialEffectScale(sfx, 0.9)
        BlzSetSpecialEffectAlpha(sfx, 85)
        BlzSetSpecialEffectTimeScale(sfx, 7.5)
        BlzSetSpecialEffectOrientation(sfx, (1.57 + ang), 1.57, 1.57) -- yaw, pitch roll
        DestroyEffect(sfx)
    end

    local function GuardDeflection()
        -- Early return if spell damage
        if (not BlzGetEventIsAttack()) then
            return
        end

        local source = GetEventDamageSource()
        local target = BlzGetEventDamageTarget()

        -- Early return if the unit doesn't have the shield buff (dummy ability)
        local buff_abil = FourCC('S002')
        local alv = GetUnitAbilityLevel(target, buff_abil)
        if (alv <= 0) then
            return
        end

        -- Get deflect chance from ability object
        local deflectchance = GetAbilityField(GuardSpellObj.id, "aoe", alv-1)
        if (math.random() <= deflectchance) then
            local dmg_amount = GetEventDamage()
            -- Melee attacker
            if (IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER)) then
                local reflect = dmg_amount * 0.5
                UnitDamageTarget(target, source, reflect, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                BlzSetEventDamage(reflect)
                GuardVisual(source, target)
                -- Check for Saving Grace
                PassionSavingGrace(target)
            -- Ranged attacker
            elseif (IsUnitType(source, UNIT_TYPE_RANGED_ATTACKER)) then
                BlzSetEventDamage(dmg_amount*0.1)
                GuardVisual(source,target)
            end
        end
        -- END --
    end

    -- Build trigger --
    local function CreateGuardDeflectTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, GuardDeflection)
    end
    OnInit.trig(CreateGuardDeflectTrig)


    -- =================================================== Main Ability Cast ======================================================= --
    local function GuardCast()
        -- Exit early if wrong ability
        local abilId = GetSpellAbilityId()
		if abilId ~= GuardSpellObj.id then
			return
		end

        -- Getters
        local this = GuardSpellObj:NewInstance()
        local id = GetHandleId(this.caster)
        local deflectchance = this.aoe
        local dur = this.normaldur

        -- Dummy (buff) ability
        local buff_abil = FourCC('S002')
        UnitAddAbility(this.caster, buff_abil)
        SetUnitAbilityLevel(this.caster, buff_abil, this.alv+1)
        HideAbility(this.caster, buff_abil)

        -- Prep caster
        local sfx = AddSpecialEffectTarget("PaladinAura.mdx", this.caster, 'origin')
        AddUnitAnimationProperties(this.caster, 'Lumber', false)  -- remove animation tag
        AddUnitAnimationProperties(this.caster, 'Defend', true)   -- add animation tag

        -- Duration
        local t = CreateTimer()
        TimerStart(t, this.normaldur, false, function()
            AddUnitAnimationProperties(this.caster, 'Lumber', true)
            AddUnitAnimationProperties(this.caster, 'Defend', false)
            RemoveAbility(this.caster, buff_abil)
            DestroyEffect(sfx)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end
    GuardSpellObj:MakeTrigger(GuardCast)
end