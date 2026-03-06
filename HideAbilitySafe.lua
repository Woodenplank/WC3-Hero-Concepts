--[[
    Untested. Should try it out.
    Fucking native function!
    
    To clarify;
        BlzUnitHideAbility(u, abil, true)
    Works by an integer count, for some reason:
    https://www.hiveworkshop.com/threads/blzunithideability-and-blzunitdisableability-dont-work.312477/
]]

do
    --[[global]] HiddenFlags={}

    function HideAbility(u, abil)
        local id = GetHandleId(u)
        local bool = HiddenFlags[id][abil] or false
        
        if bool then
            -- ability was already hidden
            -- do nothing
            return
        end

        -- Make new entry to table, if none exists
        if HiddenFlags[id]==nil then
            HiddenFlags[id] = {}
        end
        HiddenFlags[id][abil] = true
        BlzUnitHideAbility(u, abil, true)
    end
end