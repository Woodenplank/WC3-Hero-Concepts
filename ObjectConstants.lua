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
utype_Huntress = FourCC('H001')     -- working title
utype_Gunner = FourCC('H004')       -- working title

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

-- Ratling Gunner
RAT_id_spool=FourCC('A012')
RAT_id_spray=FourCC('A013')
RAT_id_blast=FourCC('A014')
RAT_id_blastArmorDebuff=FourCC('A016')
RAT_id_makeway = FourCC('A015')
RAT_id_sewageaura = FourCC('A017')
RAT_id_sewage = FourCC('A018')
RAT_id_capacitor = FourCC('A019')
RAT_id_sewerbrew = FourCC('A01A')

-- Hellion object data
HEL_id_hfstrike=FourCC("A00I")
HEL_id_charge=FourCC('A00O')
HEL_id_domsin=FourCC('A00N')
HEL_id_domsinbuff=FourCC('S000')
HEL_id_emberstorm=FourCC("A00M")
HEL_id_hellgate=FourCC("A00Q")
HEL_id_flametongues=FourCC('A00P')
HEL_id_sinham=FourCC("A00K")
HEL_id_sinhambuff=FourCC('A00L')
HEL_id_sinhamattributes=FourCC('A00V')


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

Hellforge_utype = FourCC('h005')
Hellforge_QEnabler=FourCC('h008')
Hellforge_WEnabler=FourCC('h007')
Hellforge_EEnabler=FourCC('h006')
Hellforge_REnabler=FourCC('h009')

Hellforge_blockerstacks = {
    ["ArmsOfAstaroth"] = Hellforge_QEnabler,
    ["BelialsInsights"] = Hellforge_WEnabler,
    ["SevenTonguesOfPytho"] = Hellforge_EEnabler,
    ["CrownOfTheNineKingdoms"] = Hellforge_REnabler
}


PoisonDebuffsList={
    FourCC('Bssi'), --Slow Poison (info)
    FourCC('Bspo'), --Slow Poison (non-stacking)
    FourCC('Bssd'), --Slow Poison (stacking)
    FourCC('Bpsi'), --Poison (info)
    FourCC('Bpoi'), --Poison (non-stacking)
    FourCC('Bpsd'), --Poison (stacking)
    FourCC('Bapl') --Disease (from Cloud)
    ----unfinished!
}