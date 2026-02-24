do
--[[
    Inscribes a rune upon target enemy, staggering them with eldritch knowledge.
    After <____:ANcl,Dur1> seconds the target is overwhelmed, and becomes stunned for <____:ANcl,HeroDur1> seconds.

    While the rune is active, [??Which??]
        • Allied Heroes striking the target are restored Casting Points.
        • Allied Heroes striking the target with Spell Damage are restored Casting Points.
        • The target takes additional Spell Damage from all sources.
        • The [THIS_HERO_TYPE] regains Casting Points when striking the target (?with other abilities?).
        • Damage dealt is remembered, and a percentage is dealt as bonus damage upon expiration.
]]
    UAS_id_superrune = FourCC('____')
    
    local function SupernalRuneMain()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= UAS_id_superrune then
            return
        end

        -- Getters --
        local caster = GetTriggerUnit()
        local target = GetSpellTargetUnit()
        local alv = GetUnitAbilityLevel(caster, UAS_id_superrune) - 1
        local waitdur = GetAbilityField(UAS_id_superrune, "normaldur", alv)
        local stundur = GetAbilityField(UAS_id_superrune, "herodur", alv)
        --local mod= GetAbilityField(UAS_id_superrune, "aoe", alv)

        -- Timing
        local t = CreateTimer()
        TimerStart(t, waitdur, false, function()
            StunTarget(target, caster, stundur)
            DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", GetUnitX(target) , GetUnitY(target)))
            
            -- other effects... ?

            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end
    
    local function Temp_CreateThisTrigger()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, SupernalRuneMain)
    end

    OnInit.trig(Temp_CreateThisTrigger)
end