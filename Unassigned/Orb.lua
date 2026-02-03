do
    --Orb = setmetatable({},{})     -- empty table [1] with a metatable setting (also empty table, [2])
    --meta = getmetatable(Orb)      -- fetches the previously assigned metatable
    --equivalently....
    Orb = {}
    meta = {}
    setmetatable(Orb,meta)

    meta.__index = meta             -- redo access by [index] to the metatable

    -- Spelling-error protection when initiating new instances
    local allowed_fields = {
        origin = true,
        destination = true,
        coords = true,
        area = true,
        model = true,
        scale = true,
        speed = true,
        handle = true,
    }
    function Orb.__newindex(t, k, v)
        if not allowed_fields[k] then
            print("attempt to set unknown field '"..tostring(k).."'")
        end
        rawset(t, k, v)
    end

    ---------------------------------- movement methods ----------------------------------

    ---@return nil
    function meta:update()
        if self.handle and self.coords then
            BlzSetSpecialEffectX(self.handle, self.coords.x)
            BlzSetSpecialEffectY(self.handle, self.coords.y)
            BlzSetSpecialEffectHeight(self.handle, self.coords.z)
        end
    end

    ---@return boolean
    function meta:step()
        local dx = self.destination.x - self.coords.x
        local dy = self.destination.y - self.coords.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist <= self.speed then
            return true
        end
        local ang = AngleBetweenCoords(self.coords.x,self.destination.x, self.coords.y, self.destination.y)
        local nx, ny = PolarStep(self.coords.x, self.coords.y, self.speed, ang)
        self.coords = {x = nx, y = ny, z=self.coords.z}
        self:update()
        return dist <= self.speed
    end
    
    ---------------------------------- collision ----------------------------------

    ---@param size number
    ---@param source_u unit
    ---@return boolean
    function meta:collision_enemy(size, source_u)
        -- checks whether the orb has collided with a unit
        local op = GetOwningPlayer(source_u)
        local ug = CreateGroup()
        local cond = Condition(function()
            local fu = GetFilterUnit()
            return not IsUnitEnemy(fu, op) 
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
        end)
        GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.area, cond)
        local did_collide = (CountUnitsInGroup(ug) > 0)
        DestroyGroup(ug)
        DestroyCondition(cond)

        return did_collide
    end

    ---@param size number
    ---@param source_u unit
    ---@return boolean
    function meta:collision_friend(size, source_u)
        -- checks whether the orb has collided with a unit
        local op = GetOwningPlayer(source_u)
        local ug = CreateGroup()
        local cond = Condition(function()
            local fu = GetFilterUnit()
            return IsUnitEnemy(fu, op)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
                and not IsUnitType(fu, UNIT_TYPE_STRUCTURE)
        end)
        GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.area, cond)
        local did_collide = (CountUnitsInGroup(ug) > 0)
        DestroyGroup(ug)
        DestroyCondition(cond)

        return did_collide
    end

    



    ---------------------------------- creator and destructor methods ----------------------------------

    function meta:destroy()
        if self.handle then
            DestroyEffect(self.handle)
            self.handle = nil
        end
    end

    function meta:create(params)
        local this = {}
        setmetatable(this, meta)
        self.__index = self

        --[[ catch all method. No type or input checking. Probably a bad idea
        for key,val in pairs(params) do
           this.key = val
        end ]]
        
        if params.origin then this.origin = params.origin else
            this.origin.x = params.origin.x or params.x1 or 0
            this.origin.y = params.origin.y or params.y1 or 0
            this.origin.z = params.origin.z or params.z1 or 0
        end
        if params.destination then this.destination = params.destination else
            this.destination.x = params.destination.x or params.x2 or 0
            this.destination.y = params.destination.y or params.y2 or 0
            this.destination.z = params.destination.z or params.z2 or 0
        end
        this.area = params.area or 0
        this.model = params.model or ""
        this.scale = params.scale or 1.0
        this.speed = params.speed or 10

        -- spawn
        this.coords = {x = this.origin.x, y = this.origin.y, z = this.origin.z}
        if this.model~="" then
            this.handle = AddSpecialEffect(this.model, this.coords.x, this.coords.y)
            BlzSetSpecialEffectHeight(this.handle, this.coords.z)
            BlzSetSpecialEffectScale(this.handle, this.scale)
        else
            this.handle = nil
        end

        return this
    end
    -- END OF OBJECT DEFINITION --
end