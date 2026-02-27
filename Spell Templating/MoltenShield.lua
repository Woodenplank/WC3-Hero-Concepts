-- requires SpellTemplate.lua
do
    --[[ Tooltip
    "Enshrouds a target ally in twirling flames, shielding them from damage and burning nearby enemies constantly.
    The more damage the shield absorbs, the hotter the flames burn nearby enemies."
    ]]

    -- Variables used throughout this spell setup.
    UAS_tab_moltenshield = {} -- table for storing unit shield values (like a GUI hashtable)
    UAS_tab_moltenshieldSFX = {} -- table for storing special effect handles (like a GUI hashtable)
    local UAS_id_moltenshieldbuff = FourCC("S000") -- ID of the dummy ability


    -- helper function to remove the dummy buff/ability and special effect
    local function cleanmoltenshieldbuff(u)
        UnitRemoveAbility(u, UAS_id_moltenshieldbuff)
        BlzUnitHideAbility(u, UAS_id_moltenshieldbuff, false)
        local id = GetHandleId(u)
        DestroyEffect(UAS_tab_moltenshieldSFX[id])
    end


    -- Damage shielding actions
    local function MoltenShieldBlock()     
        local u = BlzGetEventDamageTarget()
        local lvl = GetUnitAbilityLevel(u, UAS_id_moltenshieldbuff)

        -- early return if the damaged unit does not have the dummy buff
        if lvl<=0 then
            return
        end

        local id = GetHandleId(u)
        local dmg = GetEventDamage()
        local shield = UAS_tab_moltenshield[id]
        if dmg >= shield then
            dmg = dmg - shield
            shield = 0
            cleanmoltenshieldbuff(u)
        else
            shield = shield - dmg
            dmg = 0
        end

        -- Update remaining damage/shield
        BlzSetEventDamage(dmg)
        UAS_tab_moltenshield[id] = shield
    end


    -- Main spellcast actions
    local MoltenShieldSpellObj = Spell:Create("A000", "unit") -- main ability object
    local function MoltenShieldCast()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= MoltenShieldSpellObj.id then
            return
        end

        -- stats
        local this = MoltenShieldSpellObj:NewInstance()
        local t_interval = 0.5                  -- this is how often (in seconds) the timer updates
        local shield_cap = this.herodur         -- use CHANNEL - Duration (Hero) in object editor to set shield value
        local dps = GetAbilityField(this.id, "artdur", this.alv) * t_interval    -- use CHANNEL - Art Duration in object editor to set damage per second
        local targ_id = GetHandleId(this.target)
        local cast_id = GetHandleId(this.caster)


        -- Update shield value in global table
        UAS_tab_moltenshield[targ_id] = shield_cap


        -- Dummy ability (buff)
        UAS_tab_moltenshieldSFX[targ_id] = AddSpecialEffectTarget("FireShell.mdx", this.target, 'chest')
        UnitAddAbility(this.target, UAS_id_moltenshieldbuff)
        SetUnitAbilityLevel(this.target, UAS_id_moltenshieldbuff, this.alv+1)
        BlzUnitHideAbility(this.target, UAS_id_moltenshieldbuff, true)


        -- WC3 objects
        local ug = CreateGroup()
        local target_cond = Condition(function()
            local fu = GetFilterUnit()
            return 
                (IsUnitEnemy(fu, this.castplayer) 
                and not IsUnitType(fu, UNIT_TYPE_DEAD) 
                and not BlzIsUnitInvulnerable(fu)
                and not IsUnitType(fu, UNIT_TYPE_MAGIC_IMMUNE))
		end)
        local t = CreateTimer()


        -- Periodic timing
        local dur = 0
        TimerStart(t, t_interval, true, function()
            -- adjust damage based on remaining shield
            local dps_mod = dps * (1.0 + (1-UAS_tab_moltenshield[targ_id]/shield_cap))    -- linear scaling. e.g. 30% shield left = 70% more dps
            
            -- Damage enemies around this target
            GroupEnumUnitsInRange(ug, GetUnitX(this.target), GetUnitY(this.target), this.aoe, target_cond)
            ForGroup(ug, function()
                local pu = GetEnumUnit()
                UnitDamageTarget(this.caster, pu, dps_mod, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                -- this is where you would probably also add some sort of lovely special effect to show burning of enemies
                -- But for now just imagine that it looks cool.
            end)

            -- If shield is broken or duration over; remove shield and do cleanup
            dur = dur + t_interval
            if dur >= this.normaldur or (UAS_tab_moltenshield[targ_id]==0) then
                UAS_tab_moltenshield[targ_id] = 0
                cleanmoltenshieldbuff(this.target)

                -- Clean memory
                DestroyGroup(ug)
                DestroyCondition(target_cond)
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
    -- END --
    end


    -- Build triggers --
    local function CreateMoltenShieldTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(tr, MoltenShieldCast)
    end
    local function CreateMoltenShieldBlockTrig()
        local tr = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(tr, MoltenShieldBlock)
    end

    OnInit.trig(CreateMoltenShieldTrig)
    OnInit.trig(CreateMoltenShieldBlockTrig)
end