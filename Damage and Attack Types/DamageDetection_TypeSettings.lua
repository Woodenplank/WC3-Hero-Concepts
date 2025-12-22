-- Global variables
-- These are known as ARMOR_TYPE in Blizzard's own programming.
-- This is confusing to me, so here it's DefenseTypeMaterial
DefenseTypeMaterials = {
    [0] = "none",
    [1] = "flesh",
    [2] = "metal",
    [3] = "wood",
    [4] = "ethereal",
    [5] = "stone",
    ["none"] = 0,
    ["flesh"] = 1,
    ["metal"] = 2,
    ["wood"] = 3,
    ["ethereal"] = 4,
    ["stone"] = 5
}
-- DEFENSE_TYPE by Blizzard terminology, but these correspond to "in-game" unit armor types. Go figure.
DefenseTypeArmors = {
    [0] = "light",
    [1] = "medium",
    [2] = "heavy",
    [3] = "fortified",
    [4] = "normal",
    [5] = "hero",
    [6] = "divine",
    [7] = "unarmored",
    ["light"] = 0,
    ["medium"] = 1,
    ["heavy"] = 2,
    ["fortified"] = 3,
    ["normal"] = 4,
    ["hero"] = 5,
    ["divine"] = 6,
    ["unarmored"] = 7
}
function GetUnitMaterialType(which_unit)
    local i = BlzGetUnitIntegerField(which_unit, UNIT_IF_ARMOR_TYPE)
    return DefenseTypeMaterials[i]
end
function GetUnitArmorType(which_unit)
    local i = BlzGetUnitIntegerField(which_unit, UNIT_IF_DEFENSE_TYPE)
    return DefenseTypeArmors[i]
end

-- These correspond to attack types as used by object editor units
AttackTypes = {
    [0] = "spell", -- "normal" in Blizzard terminology
    [1] = "normal", -- "melee" in Blizzard terminology
    [2] = "pierce",
    [3] = "siege",
    [4] = "magic",
    [5] = "chaos",
    [6] = "hero",
    [7] = "universal" -- this one does not appear as an object editor option.
}

-- See https://www.hiveworkshop.com/threads/spell-ability-damage-types-and-what-they-mean.316271/#post-3354015
-- Also; ConvertDamageType takes integer returns DamageType (handle)
DamageTypes = {
    [0] = "unknown",    --[[This is always a zero damage event. Used when most debuffs are applied, also when Stuns wear off. Used by almost all Orbs - even Orb of Frost 
                            ]]
    [4] = "normal",     --[[ Ignore Spell Immunity [X], applies to armor [X]        !!!CAN damage spell immune UNLESS applied via MAGIC_ATTACK!!!
                                All melee/ranged attacks, Volcano, suicide (Kaboom! etc.), Locust Swarm 
                            ]]
    [5] = "enhanced",   --[[ Ignore Spell Immunity [X], ignores armor [X]
                                Cleaving Attack (other than main target), Pulverize, Fan of Knives, Bladestorm, Burning Oil 
                            ]]
    [8] = "fire",       --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Rain of Fire, Flame Strike, Firebolt, Immolation, Liquid Fire, Soul Burn, Phoenix Fire, Drunken Haze+Breath of Fire (DoT only), Incinerate 
                            ]]
    [9] = "cold",       --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Blizzard, Frost Nova, Cold/Frost Arrows/Freezing breath (zero-damage event on top of the normal attack; only on-buff) 
                            ]]
    [10] = "lightning", --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Chain Lightning, Forked Lightning, Mana Flare, Lightning Shield, Healing Wave (when set to negative) 
                            ]]
    [11] = "poison",    --[[ Ignore Spell Immunity [X], ignores armor [X]
                                Parasite, Evenomed Weapons 
                            ]] 
    [12] = "disease",   --[[ Ignore Spell Immunity [X], ignores armor [X]
                                Disease Cloud 
                            ]] 
    [13] = "divine",    --[[ Applies to Spell Immune [  ], ignores armor [X]
                                Holy Light 
                            ]]
    [14] = "magic",     --[[ Ignore Spell Immunity [  ], ignores armor [X]
                                Aerial Shackles, Mana Burn, Finger of Death/Pain, Life Drain, Dispel/Devour Magic/Purge/Abolish Magic  
                            ]]
    [15] = "sonic",     --[[ Ignore Spell Immunity [  ], ignores armor [X]
                                Storm Bolt, Frost Bolt, Hurl Boulder, Thunder Clap, War Stomp, Shockwave, Breath of Fire, Crushing Wave, Carrion Swarm 
                            ]]
    [16] = "acid",      --[[ Ignore Spell Immunity [X], ignores armor [X]
                                Devour 
                            ]] 
    [17] = "force",     --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Cluster Rockets, Impale, Bash, Tornado (building), Inferno 
                            ]]
    [18] = "death",     --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Death Coil, Unholy Frenzy 
                            ]]
    [19] = "mind",      --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                <none> 
                            ]]
    [20] = "plant",     --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Thorns Aura, Entangling Roots 
                            ]]
    [21] = "defensive", --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Spiked Carapace, Spiked Defenses (Orc Buildings) 
                            ]]
    [22] = "demolition",    --[[ Ignore Spell Immunity [X], ignores armor [X]
                                unsummon 
                            ]] 
    [23] = "slow_poison",   --[[ Ignore Spell Immunity [X], ignores armor [X]
                                Slow Poison 
                            ]]
    [24] = "spirit_link",   --[[ 
                            ]]
    [25] = "shadow_strike", --[[ Ignore Spell Immunity [  ], ignores armor [X] 
                                Shadow Strike, Acid Bomb 
                            ]]
    [26] = "universal"      --[[ Ignore Spell Immunity [X], ignores armor [X] and applies to Ethereal [X] when using ATTACK_TYPE_NORMAL
                                Earthquake, Doom, Stampede, Starfall, Death and Decay, Monsoon, Orb of Fire (splash only), Healing Spray (when set to negative) 
                            ]] 
}


