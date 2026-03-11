--[[
    The native function sucks ass.
    To clarify; "BlzUnitHideAbility(u, abil, true)" works by an integer count, for some reason.
    So we have to do this terribleness to prevent swapping back and forth between hidden/unhidden.

    See https://www.hiveworkshop.com/threads/blzunithideability-and-blzunitdisableability-dont-work.312477/ for discussion.
]]
do
    --[[global]] HiddenFlags={}

    function HideAbility(u, abil)
        local id = GetHandleId(u)
        
        if (HiddenFlags[id]) and (HiddenFlags[id][abil]) then
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

    function RemoveAbility(u, abil)
        UnitRemoveAbility(u, abil)
        -- Removing an resets hidden tag
        -- Make new entry to table, if none exists
        local id = GetHandleId(u)
        if HiddenFlags[id]==nil then
            HiddenFlags[id] = {}
        end
        HiddenFlags[id][abil] = false
    end
end