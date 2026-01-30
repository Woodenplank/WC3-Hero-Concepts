do
    -- DO NOT IMPLEMENT; currently experimenting with OOP in lua and metatables.
    -- this will probably crash your map if imported
    local Orb = {}
    Orb.__index = Orb

    local allowed_fields = {
        origin = true,
        destination = true,
        coords = true,
        area = true,
        damage = true,
        model = true,
        lightning = true,
        speed = true,
        handle = true,
    }

    function Orb.__newindex(t, k, v)
        if not allowed_fields[k] then
            print("attempt to set unknown field '"..tostring(k).."'")
        end
        rawset(t, k, v)
    end

    function Orb:update(newcoords)
        self.coords = newcoords or {x = 0, y = 0, z = 0}
        if self.handle and self.coords then
            BlzSetSpecialEffectX(self.handle, self.coords.x)
            BlzSetSpecialEffectY(self.handle, self.coords.y)
            BlzSetSpecialEffectHeight(self.handle, self.coords.z)
        end
    end

    function Orb:zap_area(source_u)
        -- safety: require area and lightning to be valid
        if (not self.area) or (self.area <= 0) or (self.lightning == nil) then
            return true
        end

        local ug = CreateGroup()
        local cond = Condition(function()
            local fu = GetFilterUnit()
            return IsUnitEnemy(fu, GetOwningPlayer(source_u))
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
                and not BlzIsUnitInvulnerable(fu)
        end)

        -- enumerate units around current coords
        GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.area, cond)

        ForGroup(ug, function()
            local pu = GetEnumUnit()
            local dmg = self.damage or 0
            UnitDamageTarget(source_u, pu, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            local pu_x, pu_y = GetUnitX(pu), GetUnitY(pu)
            local chain = AddLightningEx(self.lightning, false, self.coords.x, self.coords.y, self.coords.z, pu_x, pu_y, 50)

            local t_lightning = CreateTimer()
            TimerStart(t_lightning, 0.5, false, function()
                DestroyLightning(chain)
                PauseTimer(t_lightning)
                DestroyTimer(t_lightning)
            end)
        end)

        DestroyGroup(ug)
        DestroyCondition(cond)
    end

    function Orb:destroy()
        if self.handle then
            DestroyEffect(self.handle)
            self.handle = nil
        end
    end

    function Orb.create(params)
        params = params or {}
        local o = {
            origin = params.origin or {x = 0, y = 0, z = 0},
            destination = params.destination or {x = 0, y = 0, z = 0},
            coords = params.coords or {x = 0, y = 0, z = 0},
            damage = params.damage or 0,
            area = params.area or 0,
            model = params.model or "",
            lightning = params.lightning or "",
            speed = params.speed or 15,
            handle = nil,
        }
        -- create effect only if model is provided
        if o.model and o.model ~= "" then
            o.handle = AddSpecialEffect(o.model, o.origin.x, o.origin.y)
            BlzSetSpecialEffectHeight(o.handle, o.origin.z)
        end
       
        return setmetatable(o, Orb)
    end

end