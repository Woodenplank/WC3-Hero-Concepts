do
    --Proj = setmetatable({},{})     -- empty table [1] with a metatable setting (also empty table, [2])
    --meta = getmetatable(Proj)      -- fetches the previously assigned metatable
    --equivalently....
    Proj = {}
    local meta = {}
    setmetatable(Proj,meta)
    setmetatable(Proj, {__index = meta})
    
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

    function meta:update()
        if self.handle and self.coords then
            BlzSetSpecialEffectX(self.handle, self.coords.x)
            BlzSetSpecialEffectY(self.handle, self.coords.y)
            BlzSetSpecialEffectHeight(self.handle, self.coords.z)
        end
    end

    ---@return boolean
    function meta:step()
        --[[
            Moves the projectile <speed> distance towards target.
            
            Returns true if destination reached.
            otherwise false.
        ]]
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
        return false
    end
    
    ---------------------------------- collision ----------------------------------

    ---@return boolean
    function meta:collision_nowalk()
        --[[
            Detects if the projectile has hit "unwalkable" terrain.

            This doesn't respect the collision size of the projectile
            but this is much faster than checking if the collision circle
            overlaps ANY unwalkable pathing cell
        --]]
        return (not IsTerrainPathable(self.coords.x, self.coords.y, PATHING_TYPE_WALKABILITY) )
    end


    ---@param filter string
    ---@return boolean
    function meta:collision_unit(filter)
        --[[
            Detects if the projectile has collided with a unit.

            This does NOT account for damage/units-already hit.
            See "hitscan()" function for that.

            Filter can be set to "ally"/"friend" or "enemy"
            Optionally leave as nil for either case to trigger.
            Never detects dead units.
        ]]
        local ug = CreateGroup()
        local cond = Condition(function() 
            return not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
        end)
        if filter=="ally" or filter=="friend" then
            cond = Condition(function() 
                local fu= GetFilterUnit()
                return not IsUnitEnemy(fu, self.owner)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
            end)
        elseif filter=="enemy" then
            cond = Condition(function() 
                local fu= GetFilterUnit()
                return IsUnitEnemy(fu, self.owner)
                and not IsUnitType(fu, UNIT_TYPE_DEAD)
            end)
        end
        GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.collision, cond)
        return (CountUnitsInGroup(ug)>0)
    end


    local destructables_rect=Rect(0., 0., 0., 0.)
    ---@return boolean
    function meta:collision_destructable()
        --[[
        Detects if the projectile has hit a destructible.

        RETURN
            True if a destructible is within <collision> range
            False otherwise
        
        WARNING
            EnumDestructablesInRect() also catches hidden destructables.
            To avoid issues...
            • If any game action hides a destructable, it should also set a custom flag
            • this function should be updated to check that flag
        ]]
        SetRect(destructables_rect, self.coords.x-self.collision, self.coords.y-self.collision, self.coords.x+self.collision, self.coords.y+self.collision)
        hit = true,
        EnumDestructablesInRect(destructables_rect, nil, function()
            local des = GetEnumDestructable()
            if des~=nil then
                return true
            end
        end)
        return false
    end

    --------------------------------------- damage methods --------------------------------------------

    ---@return boolean
    function meta:hitscan()
        --[[
            Detects enemies in the <collision> range of the projectile, and damages them.
            Units damaged are added to self.hit group, to prevent multiple damage procs.
            
            RETURN
                True if a valid target was in range
                False otherwise
        ]]
        local ug = CreateGroup()
        local cond = Condition(function() local fu= GetFilterUnit()
            return IsUnitEnemy(fu, self.owner)
            and not IsUnitType(fu, UNIT_TYPE_DEAD)
            and not IsUnitInGroup(fu, self.hit)
        end)
        GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.collision, cond)
        local did_collide = (CountUnitsInGroup(ug)>0)
        ForGroup(ug, function()
            local pu = GetEnumUnit()
            UnitDamageTarget(self.source, pu, self.dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            GroupAddUnit(self.hit, pu)
        end)
        DestroyGroup(ug)
        DestroyCondition(cond)
        return did_collide
    end

    function meta:flush()
        GroupClear(self.hit)
    end
    

    ---------------------------------- visual methods ----------------------------------

    ---@param model_str string
    function meta:remodel(model_str)
        --[[
            Changes the model of projectile to the desired string
            Then updates size and height accordingly.

            There's no native way to check if a model string is appropiate
            So beware of bad formatting or typos.
        ]]
        if type(model_str) ~= "string" then 
            print("Error! Expected string in Proj:remodel, but got ".. type(model_str))
            return
        end
        DestroyEffect(self.handle)
        self.handle=nil

        self.model = model_str
        self.handle = AddSpecialEffect(model_str, self.coords.x, self.coords.y)
        BlzSetSpecialEffectHeight(self.handle, self.coords.z)
        BlzSetSpecialEffectScale(self.handle, self.scale)
    end

    ---@param value number
    function meta:rescale(value)
        --[[
            Updates model scale to new value.
            Inputs other than number will return error.
        ]]
        if type(value) ~= "number" then
            print("Error! Expected number in Proj:rescale, but got "..type(value))
            return
        end
        self.scale = value
        BlzSetSpecialEffectScale(self.handle, self.scale)
    end

    ---@param value number
    function meta:alpha(value)
        --[[
            Updates model alpha to new value.
            Inputs other than number will return error.
        ]]
        if type(value) ~= "number" then
            print("Error! Expected number in Proj:alpha, but got "..type(value))
            return
        end
        self.alpha = value
        BlzSetSpecialEffectAlpha(self.handle, self.alpha)
    end


    ---------------------------------- creator and destructor methods ----------------------------------

    function meta:destroy()
        if self.handle then
            DestroyEffect(self.handle)
            self.handle = nil
        end
        DestroyGroup(self.hit)
    end


    ---@param params table
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


-- template (example usage)
if false then
    -- ...
    local casting_unit = GetTriggerUnit()
    local target_unit = GetSpellTargetUnit()
    local spell_lvl = GetUnitAbilityLevel(casting_unit, GetSpellAbilityId())
    local my_params = {
        origin = {GetUnitX(casting_unit), GetUnitY(casting_unit), 50},
        destination = {GetUnitX(target_unit), GetUnitY(target_unit), GetUnitFlyHeight(target_unit)+50},
        source = casting_unit,
        collision = 200,
        dmg = 100*spell_lvl,
        model = "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl",
        speed = 20
    }
    local projectile = Proj:create(my_params)
    -- ...
end