local Orb={}
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
    --[[    Prevents accidental creation of spurious fields (typos like inst.dmage = 10 will raise).
    Gives a place to add type/validation checks if desired. ]]
    if not allowed_fields[k] then
        print("attempt to set unknown field '"..tostring(k).."'")
    end
    rawset(t,k,v)
end

function Orb:update(newcoords)
    self.coords = newcoords or {x=0, y=0, z=0}
    if self.handle then
        BlzSetSpecialEffectX(self.handle, self.coords.x)
        BlzSetSpecialEffectY(self.handle, self.coords.y)
        BlzSetSpecialEffectHeight(self.handle, self.coords.z)
    end
end

function Orb:zap_area(source_u)
    if (self.aoe <=0) or (self.lightning = nil) then
        return true
    end
    local ug = CreateGroup()
    local cond = Condition(function() return 
        IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(source_u)) 
        and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) 
        and not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) 
        and not BlzIsUnitInvulnerable(GetFilterUnit())
  end)
  GroupEnumUnitsInRange(ug, self.coords.x, self.coords.y, self.aoe, cond)
  
  ForGroup(ug, function()
      pu = GetEnumUnit()
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

-- function Orb:step(dt)
--     dt = dt or 1
--     local dx = self.destination.x - self.coords.x
--     local dy = self.destination.y - self.coords.y
--     local dz = self.destination.z - self.coords.z
--     local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
--     if dist <= 0.0001 then
--         return true
--     end
--     local step = math.min(self.speed * dt, dist)
--     local nx = self.coords.x + dx / dist * step
--     local ny = self.coords.y + dy / dist * step
--     local nz = self.coords.z + dz / dist * step
--     self:update{ x = nx, y = ny, z = nz }
--     return step >= dist
-- end

function Orb:destroy()
    if self.handle then
        -- Destroy or remove the effect using the proper engine function(s)
        DestroyEffect(self.handle)
        self.handle = nil
    end
end


function Orb.create(params)
    params = params or {}
    local o = {
        origin = params.origin or {x=0, y=0, z=0},
        destination = params.destination or {x=0, y=0, z=0},
        coords = params.coords or {x=0, y=0, z=0}
        damage = params.damage or 0,
        area = params.area or 0,
        model = params.model or ""
        lightning = params.lightning or "",
        speed = params.speed or 15
        handle = nil --init only
    }
    o.handle = AddSpecialEffect(o.model, o.origin.x, o.origin.y)
    BlzSetSpecialEffectHeight(o.handle, o.origin.z)
    return setmetatable(o, Orb)
end

return Orb