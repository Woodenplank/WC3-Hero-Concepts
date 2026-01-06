--[[
    These variables are to be considered 
        STATIC CONST (inline)

    Declared here once, according to World Editor Object data.
    In other words; do not fuck with them henceforth.
]]

--Heroes
utype_SwordSaint = FourCC('H000')
utype_Hellion = FourCC('O001')
utype_Astromancer = FourCC('H003')

--Heroic Summons
utype_Celestial = FourCC('e003')
utype_StarSprite = FourCC('o000')
utype_FlameTornado = FourCC('e001')

--Dummies
Dummy_utype=FourCC('e000')
Dummy_Pentagram=FourCC('e002')
Dummy_Sunchecker=FourCC('e004')


-- SwordSaint object data
HSS_id_dash =FourCC("A004")
HSS_id_guard=FourCC("A001")
HSS_id_guardbuff=FourCC("S002")
HSS_id_omnislash=FourCC("A000")
HSS_id_passionON=FourCC("A007")
HSS_id_passionOFF=FourCC('A008')
HSS_id_passionbuff=FourCC('S001')
HSS_id_passionspeed=FourCC('A006')
HSS_id_xstrike=FourCC('A005')

-- Astromancer object data
AST_id_almanac=FourCC("A00D")
AST_id_almanacbuff=FourCC('A00E')
--[[ remember to remove the following two - now superfluous - lines from ArcaneAlmanac.lua 
    --globals
    AlmanacBuff_AbilId = FourCC('A00E')
    Almanac_AbilId = FourCC('A00D')
    ]]
AST_id_collapsesun=FourCC("A00B")
AST_id_fallingstar=FourCC("A00A")
AST_id_nebula=FourCC("A003")
AST_id_nether=FourCC("A002")
AST_id_netherbuff=FourCC('A00F')
AST_id_silver=FourCC("A00H")
AST_id_silverbuff=FourCC('A00G')

-- Hellion object data
HEL_id_hfstrike=FourCC("A00I")
HEL_id_charge=FourCC('A00O')
HEL_id_domsin=FourCC('A00N')
HEL_id_domsinbuff=FourCC('S000')
HEL_id_emberstorm=FourCC("A00M")
HEL_id_hellgate=FourCC("A00Q")
HEL_id_flametongues=FourCC('A00P')
--[[ Remove obsolete Hellion globals
    SHbuff_abilId = FourCC('A00L')
    ]]
HEL_id_sinham=FourCC("A00K")
HEL_id_sinhambuff=FourCC('A00L')
HEL_id_sinhamattributes=FourCC('A00V')


--[[ Remove obsolete Hellion globals ]]
-- Hellion Hellforge settings
    -- Redundancy in table entries; in case someone forgets whether to use upg name or ability name
HellforgedSpells = {
    ["ArmsOfAstaroth"] = FourCC('A00O'),
    ["Charge"] = FourCC('A00O'),
    ["BelialsInsights"] = FourCC('A00Q'),
    ["Hellgate"] = FourCC('A00Q'),
    ["SevenTongues"] = FourCC('A00P'),
    ["SevenTonguesOfPytho"] = FourCC('A00P'),
    ["SevenTonguesOfFlame"] = FourCC('A00P'),
    ["CrownOfTheNineKingdoms"] = nil
}
HellforgedResearches = {
    ["ArmsOfAstaroth"] = FourCC('A00R'),
    ["BelialsInsights"] = FourCC('A00S'),
    ["SevenTonguesOfPytho"] = FourCC('A00T'),
    ["CrownOfTheNineKingdoms"] = FourCC('A00U')
}

Hellforge = FourCC('h005') -- not actually needed. Kept here for bookkeeping though
Hellforge_QEnabler=FourCC('h008')
Hellforge_WEnabler=FourCC('h007')
Hellforge_EEnabler=FourCC('h006')
Hellforge_REnabler=FourCC('h009')