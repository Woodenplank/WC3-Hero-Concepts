-- requires SpellTemplate.lua
-- requires QuickHeal.lua
do
--[[
    Inscribes a rune upon target enemy, staggering them with eldritch knowledge.
    After <____:ANcl,Dur1> seconds the target is overwhelmed, and becomes stunned for <____:ANcl,HeroDur1> seconds.

    While the rune is active every 100 points of damage dealt to the target is stored as arcane energy.
    When the spell ends, the <caster_hero> restores Casting Points equal to the energy stored.
]]

--[[ TODO and/or WARNING
    The simple setup of the tracking table means that any one unit (target) will track ALL incoming damage concurrently.
    Regardless of source.
    This is obviously bad for multi-caster instances, but since I'm just using this for SINGLE-HERO-INSTANCE dungeon/RPG 
    cases, it's irrelevant for now.
]]
    -- =================================================== Damage Stacker ============================================================ --
    SupernalRuneStackTab = {}
    local function SupernalRuneStack()
        local u = BlzGetEventDamageTarget()
        local id= GetHandleId(u)
        if SupernalRuneStackTab[id] then
            SupernalRuneStackTab[id] = SupernalRuneStackTab[id] + GetEventDamage()
        end
        -- else return
    end

    -- =================================================== Mana restore func ========================================================== --
    local function SupernalRuneMana(id, u)
        local restore = math.floor(SupernalRuneStackTab[id]/100)
        QuickManaRestore(u, restore)
        DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MagicSentry\\MagicSentryCaster.mdl", GetUnitX(u) , GetUnitY(u)))
    end

    -- =================================================== Main cast trigger ========================================================== --
    local SupernalRuneSpellObj = Spell:Create("A01G", "unit")
    local function SupernalRuneMain()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= SupernalRuneSpellObj.id then
            return
        end

        -- Ability stats
        local this = SupernalRuneSpellObj:NewInstance()
        local waitdur = this.normaldur
        local stundur = this.herodur
        local targ_id = GetHandleId(this.target)
        
        -- if overwriting a previous cast, restore mana anyway
        if SupernalRuneStackTab[targ_id] then 
            SupernalRuneMana(targ_id, this.caster)
        end
        -- reset damage counter
        SupernalRuneStackTab[targ_id] = 0
    
        
        -- Delayed effect
        local debuff_sfx = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Parasite\\ParasiteTarget.mdl", this.target, "overhead")
        local t = CreateTimer()
        TimerStart(t, waitdur, false, function()
            StunTarget(this.target, this.caster, stundur)
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DarkSummoning\\DarkSummonMissile.mdl", GetUnitX(this.target) , GetUnitY(this.target)))
            
            if SupernalRuneStackTab[targ_id] then
                SupernalRuneMana(targ_id, this.caster)
            end
            SupernalRuneStackTab[targ_id] = nil

            -- Cleanup
            DestroyEffect(debuff_sfx)
            PauseTimer(t)
            DestroyTimer(t)
        end)
        -- END --
    end


    -- Build triggers --
    local function CreateStackTrigger()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, SupernalRuneStack)
    end
    OnInit.trig(CreateStackTrigger)

    SupernalRuneSpellObj:MakeTrigger(SupernalRuneMain)
end