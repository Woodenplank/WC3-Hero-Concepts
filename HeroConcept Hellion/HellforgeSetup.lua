do
    --[[
    See HellionGlobal.lua for the variable declarations
    ]]

    -- This should probably be a loop through a table... TOO BAD!
    local function SetupResearchUnits()
        HellforgeResearchBlockers = CreateGroup()
        local temp = CreateUnit(Player(0), HellforgeEnabler_Qtype, 0, 0, 270)
        GroupAddUnit(HellforgeResearchBlockers, temp)
        temp = CreateUnit(Player(0), HellforgeEnabler_Wtype, 0, 0, 270)
        GroupAddUnit(HellforgeResearchBlockers, temp)
        temp = CreateUnit(Player(0), HellforgeEnabler_Etype, 0, 0, 270)
        GroupAddUnit(HellforgeResearchBlockers, temp)
        temp = CreateUnit(Player(0), HellforgeEnabler_Rtype, 0, 0, 270)
        GroupAddUnit(HellforgeResearchBlockers, temp)
    end

    -- Build Trigger --
    local function CreateSetupTrig()
        local tr = CreateTrigger()
        TriggerRegisterTimerEventSingle( tr, 0.01 )
        TriggerAddAction(tr, SetupResearchUnits)
    end
    OnInit.final(CreateSetupTrig)
end