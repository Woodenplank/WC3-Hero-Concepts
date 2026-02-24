do
    dragonhead = {}
    local mt = {}
    setmetatable(dragonhead, mt)
    setmetatable(dragonhead, {__index = mt})

    function mt:dist_maxed()
        return (self.dist >= self.dist_end)
    end

    function mt:update_counter(max)
        local psc=self.pinspawn_counter
        psc = psc + 1
        if psc >= max then
            self.pinspawn_counter = 0
            return true
        else
            self.pinspawn_counter = psc
            return false
        end
    end
    -- for when to spawn pins
    -- e.g >>> if head:update_counter(__) then head:add_pin end

    
    function mt:advance(stepsize)
        self.ang = self.ang + math.random(-10,10)*math.pi/180
        nx, ny = PolarStep(self.x, self.y, stepsize, self.ang)
        BlzSetSpecialEffectX(self.handle, nx)
        BlzSetSpecialEffectY(self.handle, ny)
        BlzSetSpecialEffectZ(self.handle, 75)
        self.x = nx
        self.y = ny
        self.dist = self.dist + stepsize 
        -- >>> self.dist = self.dist + Distance(nx, self.x, ny, self.y)
        -- would be more accurate, but more computationally expensive
        return self
    end


    -- -- -- -- -- pin management -- -- -- -- --

    function mt:add_pin(dur, dmg)
        local px, py = self.x, self.y
        local phandle = AddSpecialEffect("Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl", px, py)
        BlzSetSpecialEffectScale(phandle, 0.55)
        local alpha = 255
        local dps_counter = 0
        local lifetime = dur or 5
        local damagepersecond = dmg or 0
        table.insert(self.pins, {x = px, y = py, ph = phandle, a = alpha, dps = damagepersecond, c = dps_counter, tm = lifetime})
        self.pinspawn_counter = 0
    end

    function mt:update_pins(t_interval, reduction)
        for pinnumber,pin in ipairs(self.pins) do
            -- pin alpha fade
            pin.a = pin.a-reduction
            BlzSetSpecialEffectAlpha(pin.ph, pin.a)     -- does not seem to work with Burning Oil

            -- pin area burn
            pin.c = pin.c+1
            if pin.c >= dps_counter_max then
                GroupEnumUnitsInRange(ug, pin.x, pin.y, self.aoe, cond)
                ForGroup(ug, function()
                    pu = GetEnumUnit()
                    UnitDamageTarget(self.source_u, pu, pin.dps, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                    --Abilities\Spells\Human\FlameStrike\FlameStrikeDamageTarget.mdl
                end)
                pin.c = 0
            end

            -- pin expiration
            pin.tm = pin.tm - t_interval
            if pin.tm <= 0 then
                DestroyEffect(pin.ph)
                table.remove(self.pins, pinnumber)
            end
        end
        return nil
    end


    function mt:is_empty()
        local next=next
        return (next(self.pins) == nil)
    end

    ------------------------------- Creator Method -----------------------------------------------
    function mt:create(params)
        local this = {}

        this.source_u = params.caster or nil
        this.aoe = params.aoe
        this.dist_end = params.dist_end or 0
        this.dist = params.dist or 10
        this.ang = params.ang or 270
        this.x = params.x or 0
        this.y = params.y or 0
        this.pinspawn_counter = -3 or 0
        this.pins = {}
        this.handle = AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", this.x, this.y)
        BlzSetSpecialEffectZ(this.handle, 75)
        return setmetatable(this, {__index = mt})
    end
    ------------------------------- End of dragonheadhead object definition ----------------------
end