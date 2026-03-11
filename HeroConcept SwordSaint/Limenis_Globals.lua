-- requires SpellTemplate.lua
-- requires (explicit) GetAbilityField.lua
-- requires QuickHeal.lua
do
    -- This must be loaded BEFORE any of her other ability scripts
    SaintsWrothSpellObj = Spell:Create("A002", "point")
    DashSpellObj = Spell:Create("A004", "point")
    OmniFlurrySpellObj = Spell:Create("A000", "unit")
    GuardSpellObj = Spell:Create("A001", "instant")
    ExploitWeaknessSpellObj = Spell:Create("A009", "unit")
    SwordSaint_CritStackTab = {}


    -- =================================================== Passion of a Saint (Healing) ======================================================= --

    function PassionSavingGrace(u)
        local alv = GetUnitAbilityLevel(u, SaintsWrothSpellObj.id)
        -- Early return if ability not learned yet
        if alv<1 then
            return
        end
        if (math.random() < 0.3) then
            local heal = GetAbilityField(SaintsWrothSpellObj.id, "artdur", alv-1)
            QuickHealUnit(u, heal)
            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl",u,"origin"))
        end
        -- END --
    end



end