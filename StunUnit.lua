do
    -- dummy ID should also be declared... somewhere!
    stun_ability_id = FourCC('A01C')
    -- stun intervals in HALF_SECONDS

    ---@param u_target unit
    ---@param u_source unit
    ---@param time number (multiple of 0.5)
    ---@return boolean (stun_succesful)
    function StunTarget(u_target, u_source, time)
        -- input sanitation
        if type(time) ~= "number" then
            print("Attempted to stun for an invalid time segment. Got time = "..tostring(time))
            return false
        end

        -- target resistance checks
        if (IsUnitDeadBJ(u_target) or IsUnitType(u_target, UNIT_TYPE_MAGIC_IMMUNE)) then
            return false
        end

        -- get appropiate stun duration
        local int_time = math.floor(time)
        if int_time ~= time then
            if int_time < time then
                time = int_time + 0.5
            else
                time = int_time - 0.5
            end
        end
        -- stormbolt dummy
        local dummy = CreateUnit(GetOwningPlayer(u_source), FourCC('e000'), GetUnitX(u_target), GetUnitY(u_target),270) --Dummy_utype=FourCC('e000')
        UnitAddAbility(dummy, stun_ability_id)
        SetUnitAbilityLevel(dummy, stun_ability_id, math.floor(time*2))
        IssueTargetOrderBJ(dummy, 'thunderbolt', u_target)

        return true
    end
end