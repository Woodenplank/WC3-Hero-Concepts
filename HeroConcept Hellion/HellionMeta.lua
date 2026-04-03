do
    -- this should be populated as soon as possible. As soon as a Hellion hero is "picked" by a Player.
    -- this is a table (of tables) of booleans, for each Hellion, which checks which upgrade is currently chosen.
    HEL_HellionTab = {}
    local meta = {}
    setmetatable(HEL_HellionTab,meta)
    setmetatable(HEL_HellionTab, {__index = meta})

    ---------------------------------- set of fields ----------------------------------
    local allowed_fields = {
        handle_hero = nil,
        id_hero = 0,
        handle_forge = nil,
        id_forge = 0,
        player = nil,
        handle_group = nil,
        ArmsOfAstaroth=false,
        BelialsInsights=false,
        SevenTonguesOfPytho = false,
        CrownOfTheNineKingdoms = false,
        activeupgrade="",
    }
    function HEL_HellionTab.__newindex(t, k, v)
        if not allowed_fields[k] then
            print("attempt to set unknown field '"..tostring(k).."'")
        end
        rawset(t, k, v)
    end

    ---------------------------------- upgrade change method ----------------------------------
    
    HellforgedSpells = {
        ["ArmsOfAstaroth"] = FourCC('A00O'),
        ["BelialsInsights"] = FourCC('A00Q'),
        ["SevenTonguesOfPytho"] = FourCC('A00P'),
        ["CrownOfTheNineKingdoms"] = nil
    }
    HellforgedResearches = {
        ["ArmsOfAstaroth"] = FourCC('A00R'),
        ["BelialsInsights"] = FourCC('A00S'),
        ["SevenTonguesOfPytho"] = FourCC('A00T'),
        ["CrownOfTheNineKingdoms"] = FourCC('A00U')
    }
    HellforgedEnablers = {
        ["ArmsOfAstaroth"] = FourCC('h008'),
        ["BelialsInsights"] = FourCC('h007'),
        ["SevenTonguesOfPytho"] = FourCC('h006'),
        ["CrownOfTheNineKingdoms"] = FourCC('h009')
    }

    function meta:ChangeUpgrade(new_keyword)
        -- guard against faulty input
        if self.handle_hero==nil or self.handle_forge == nil then
            print("Attempted to update Hellforge settings for non-existent Hero/Forge combo. Aborting...")
            return
        end

        -- Clear all current research units for this Hellion
        -- then reenable the other Hellforge options again
        
        ForGroup(self.handle_group, function()
            RemoveUnit(GetEnumUnit())
        end)

        for key,unit_type in pairs(HellforgedEnablers) do
            if key~=new_keyword then 
                local temp = CreateUnit(self.player, unit_type, 0, 0, 270)
                GroupAddUnit(self.handle_group, temp)
            end
        end
        
        -- Remove all current Hellforged abilities
        -- then add the selected option back to the Hellion
        
        for key,spell in pairs(HellforgedSpells) do
            UnitRemoveAbility(self.handle_hero, spell)
        end

        UnitAddAbility(self.handle_hero, HellforgedSpells[new_keyword])
        
        return self
    end





    ---------------------------------- creator and destructor methods ----------------------------------
    
    -- This should only be used in cases where a Hellion Hero/Forge is PERMANENTLY removed from the map
    function meta:destroy()
        RemoveUnit(handle_hero)
        RemoveUnit(handle_forge)
        self.handle_hero = nil
        self.handle_forge = nil
        self.id_forge = nil
        self.id_hero = nil
        self.player = nil
        DestroyGroup(self.handle_group)
        self.ArmsOfAstaroth=false
        self.BelialsInsights=false
        self.SevenTonguesOfPytho = false
        self.CrownOfTheNineKingdoms = false
        self.activeupgrade=nil
    end

    ---@param u_hero unit
    ---@param u_forge unit
    function meta:create(u_hero, u_forge)
        local this = {}
        setmetatable(this, {__index = self})

        this.handle_hero = u_hero
        this.id_hero = GetHandleId(u_hero)
        this.handle_forge = u_forge
        this.id_forge = GetHandleId(u_forge)
        this.player = GetOwningPlayer(u_hero)
        if (this.player ~= GetOwningPlayer(u_forge)) then
            print("Error! Hellion unit and Forge unit appear to be owned by different Players!")
            print("Aborting metatable instance...")
            return
        end
        this.handle_group = CreateGroup()

        this.ArmsOfAstaroth=false
        this.BelialsInsights=false
        this.SevenTonguesOfPytho = false
        this.CrownOfTheNineKingdoms = false
        this.activeupgrade=""

        return this
    end

end