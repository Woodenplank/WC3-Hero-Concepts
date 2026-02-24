do
    --Proj = setmetatable({},{})     -- empty table [1] with a metatable setting (also empty table, [2])
    --meta = getmetatable(Proj)      -- fetches the previously assigned metatable
    --equivalently....
    Proj = {}
    local meta = {}
    setmetatable(Proj,meta)

    meta.__index = meta             -- redo access by [index] to the metatable
    
    -- Spelling-error protection when initiating new instances
    local allowed_fields = {
        origin = true,
        destination = true,
        coords = true,
        collision = true,
        hit = true,
        dmg = true,
        source = true,
        model = true,
        scale = true,
        speed = true,
        handle = true,
    }
    function Proj.__newindex(t, k, v)
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

    ---@return boolean
    function meta:collision_nowalk()
        -- This doesn't respect the collision size of the projectile
        -- but this is much faster than checking if the collision circle
        -- overlaps ANY unwalkable pathing cell
        return (not IsTerrainPathable(self.coords.x, self.coords.y, PATHING_TYPE_WALKABILITY) )
    end


    local destructables_rect=Rect(0., 0., 0., 0.)
     --[[ WARNING
        EnumDestructablesInRect() also catches hidden destructables.
        There is no native way to detect if a destructable is set to hidden.
        
        TODO:
        • any game action which hides destructables should also set a custom flag
        • this function should be updated to check that flag
    ]]
    ---@return boolean
    function meta:collision_destructable()
        SetRect(destructables_rect, self.coords.x-self.collision, self.coords.y-self.collision, self.coords.x+self.collision, self.coords.y+self.collision)
        hit = true,
        EnumDestructablesInRect(destructables_rect, nil, function()
            local des = GetEnumDestructable()
            if des~=nil then
                return true
            end
        )        return false
    end

    --------------------------------------- damage methods --------------------------------------------


    ---@return boolean
    function meta:hitscan()
        local ug = CreateGroup()
        local cond = Condition(function() local fu= GetFilterUnit()
            return not IsUnitEnemy(fu, self.owner)
            and not IsUnitType(fu, UNIT_TYPE_DEAD)
            and not IsUnitInGroup(fu, self.hit)
        end)
        GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.collision, cond)
        local did_collide = (CountUnitsInGroup(ug)>0)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            UnitDamageTarget(self.owner, pu, self.dmg, true, false, DAMAGE_TYPE_NORMAL, ATTACK_TYPE_NORMAL, nil)
            GroupAddUnit(self.hit, pu)
        end)
        DestroyGroup(ug)
        DestroyCondition(cond)
        return did_collide
    end

    function meta:flush()
        GroupClear(self.hit)
    end
    

    ---------------------------------- creator and destructor methods ----------------------------------

    function meta:destroy()
        if self.handle then
            DestroyEffect(self.handle)
            self.handle = nil
            DestroyGroup(self.hit)
        end
    end

    function meta:create(params)
        local this = {}
        setmetatable(this, {__index = self})
        
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
        this.source = params.source or nil
        if this.source ~= nil then
            this.owner = GetOwningPlayer(this.source)
        else
            this.owner = nil
        end
        this.collision = params.collision or 0
        this.dmg = params.dmg or 0
        this.hit = CreateGroup()
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