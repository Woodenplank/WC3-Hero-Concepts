do
    Mine = {}
    local meta = {}
    setmetatable(Mine,meta)
    setmetatable(Mine, {__index = meta})

    function meta:create(params)
        local this = {}
        setmetatable(this, {__index = self})

        -- timing
        this.armed = false
        this.t = nil
        this.dynamic = false
        this.td = nil

        -- origin
        this.source = params.source or params.u or nil
        this.x = params.x or 0
        this.y = params.y or 0
        this.z = params.z or params.height or 0

        -- stats
        this.dur = params.dur or params.duration or 1
        this.lifetime = 0
        this.dmg = params.dmg or params.damage or 0
        this.aoe = params.aoe or params.area or 90

        -- aesthetics        
        this.modelwarn = params.model1 or params.modelwarn or ""
        this.modelblow = params.model2 or params.modelblow or ""
        this.scale1 = params.scalestart or params.scale1 or 1
        this.alpha1 = params.alphastart or params.alpha1 or 255
        this.scale2 = params.scaleend or params.scale2 or 1
        this.alpha2 = params.alphaend or params.alpha2 or 255

        -- values for storing current scale and alpha
        -- (There is no native to GetSpecialEffectAlpha(), so we must track it)
        this.s = this.scale1
        this.a = this.alpha1

        -- Special Effect
        if this.modelwarn ~= "" then
            this.handle = AddSpecialEffect(this.modelwarn, this.x, this.y)
            BlzSetSpecialEffectHeight(this.handle, this.z)
            BlzSetSpecialEffectScale(this.handle, this.scale1)
            BlzSetSpecialEffectAlpha(this.handle, this.alpha1)
        else
            this.handle = nil
        end

        return this
    end

    function meta:arm()
        -- early return if already armed
        if self.armed then 
            return
        end

        self.t = CreateTimer()
        TimerStart(self.t, self.dur, false, function()
            self:detonate()
        end)
        self.armed = true
    end

    function meta:detonate()
        -- blowup
        if self.handle and self.modelblow~="" then
            DestroyEffect(self.handle)
            DestroyEffect(AddSpecialEffect(self.modelblow, self.x, self.y))
        end
        local ug = CreateGroup()
        local p = GetOwningPlayer(self.source)
        local cond = Condition(function() 
            local fu= GetFilterUnit()
            return IsUnitEnemy(fu, p)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitInGroup(fu, self.hit)
        end)

        GroupEnumUnitsInRange(ug, self.x, self.y, self.aoe, cond)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            UnitDamageTarget(self.source, pu, self.dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
        end)

        -- clean temp memory
        DestroyGroup(ug)
        DestroyCondition(cond)

        -- misc cleanup
        if self.armed then
            PauseTimer(self.t)
            DestroyTimer(self.t)
        end
        if self.dynamic then
            PauseTimer(self.td)
            DestroyTimer(self.td)
        end
    end

    function meta:flagdynamic()
        -- if dynamic==true already, undo it
        if self.dynamic then
            self.dynamic = false
            PauseTimer(self.td)
            DestroyTimer(self.td)
            return false
        end

        -- Start dynamic mode
        self.dynamic = true
        -- dynamic step values
        local t_interval = 0.1
        local alphastep = ((self.alpha2 - self.alpha1) / self.dur) * t_interval
        local scalestep = ((self.scale2 - self.scale1) / self.dur) * t_interval

        -- Periodic update
        self.td = CreateTimer()
        TimerStart(self.td, t_interval, true, function()
            self.a = self.a + alphastep
            self.s = self.s + scalestep
            BlzSetSpecialEffectAlpha(self.handle, self.a)
            BlzSetSpecialEffectScale(self.handle, self.s)
            
            -- check if lifetime ended
            self.lifetime = self.lifetime + t_interval
            if self.lifetime >= self.dur then
                PauseTimer(self.td)
                DestroyTimer(self.td)
                self.dynamic = false                
            end
        end)
    end


    function meta:destroy()
        -- This method destroys the mine WITHOUT explosion or SFX
        -- Strictly a memory cleanup
        if self.handle then 
            DestroyEffect(self.handle)
            self.handle = nil
        end
        if self.armed then
            PauseTimer(self.t)
            DestroyTimer(self.t)
            self.armed = nil
        end
        if self.dynamic then
            PauseTimer(self.td)
            DestroyTimer(self.td)
            self.dynamic = nil
        end
    end
end