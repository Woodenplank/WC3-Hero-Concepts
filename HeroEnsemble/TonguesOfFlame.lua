do
--[[
function Trig_FlameTongues_Conditions takes nothing returns boolean
    return (GetSpellAbilityId() == 'A00P')
endfunction

function FlameBloom takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local integer custom_val
    local unit u = LoadUnitHandle(udg_Spell_Table, id, 1)
    local group ug = CreateGroup()
    local unit pu

    local real dmg = LoadReal(udg_Spell_Table, id, 2)

    local real x = GetUnitX(u)
    local real y = GetUnitY(u)

    local real ang = 0
    local real new_x    // forward declare for locality
    local real new_y    // forward declare for locality
    local real distance = LoadReal(udg_Spell_Table, id, 3) + 100
    local real distance_max = LoadReal(udg_Spell_Table, id, 4)


    if distance <= distance_max then
        // draw a circle of effects at current distance
        loop
            exitwhen ang >=360
                set new_x = x + distance * Cos(ang * bj_DEGTORAD)
                set new_y = y + distance * Sin(ang * bj_DEGTORAD)
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", new_x , new_y))
 
                //  ----------------- AoE damage -----------------
                call GroupEnumUnitsInRange(ug, new_x, new_y, 150, null)
                loop
                    set pu = FirstOfGroup(ug)
                    exitwhen (pu==null)
                    if IsUnitEnemy(pu, GetOwningPlayer(u)) then
                        // avoid damaging same unit twice
                        set custom_val = GetUnitUserData(pu)
                        if LoadInteger(udg_Misc_Table, id, custom_val) == 0 then
                            call UnitDamageTargetBJ(u, pu, dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
                        endif
                        call SaveInteger(udg_Misc_Table, id, custom_val, 1)
                    endif
                call GroupRemoveUnit(ug, pu)
                endloop
		 // --------------------- -------------------------
		set ang = ang + 360/7
        endloop
        call SaveReal(udg_Spell_Table, id, 3, distance)
        call TimerStart(t, 0.15, false, function FlameBloom)
    else
        call PauseTimer(t)
        call DestroyTimer(t)
        call FlushChildHashtable(udg_Spell_Table, id)
        call FlushChildHashtable(udg_Misc_Table, id)
    endif

    call DestroyGroup(ug)
    set ug = null
    set t = null
    set u = null
    set pu = null
endfunction

function Trig_FlameTongues_Actions takes nothing returns nothing
	local unit cast = GetTriggerUnit()

	local integer alv = GetUnitAbilityLevel(cast, 'A00P') - 1
	local real damage = GetAbilityReal("herodur", cast, alv, 'A00P') + addSP(cast, 2.0)
	local real size = GetAbilityReal("aoe", cast, alv, 'A00P')
	local real distance = 0

	local timer t = CreateTimer()
	local integer id = GetHandleId(t)

	call SaveUnitHandle(udg_Spell_Table, id, 1, cast)			
	call SaveReal(udg_Spell_Table, id, 2, damage)
	call SaveReal(udg_Spell_Table, id, 3, distance)             // will update runningly
	call SaveReal(udg_Spell_Table, id, 4, size)
	call TimerStart(t, 0.15, false, function FlameBloom)

	set t = null
	set cast = null
endfunction



//===========================================================================
function InitTrig_FlameTongues takes nothing returns nothing
    set gg_trg_FlameTongues = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_FlameTongues, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_FlameTongues, Condition( function Trig_FlameTongues_Conditions ) )
    call TriggerAddAction( gg_trg_FlameTongues, function Trig_FlameTongues_Actions )
endfunction
]]

    function TonguesOfFlameMain()
        -- Exit early if this is the wrong ability
        local abilId = GetSpellAbilityId()
        if abilId ~= FourCC('A00P') then
            return
        end
        -- Getters --
        local u = GetTriggerUnit()
        local x = GetUnitX(u)
        local y = GetUnitY(u)
        local lvl = GetUnitAbilityLevel(u, abilId) - 1

        -- Ability stats
        local dmg = GetAbilityField(FourCC('A00P'), "herodur", lvl) + addSP(u, 2.0)
        local area= GetAbilityField(FourCC('A00P'), "aoe", lvl)
        local tongues=7
        local tonguesteps = (2*bj_PI)/tongues

        -- Objects
        local ug = CreateGroup()
        local t = CreateTimer()
        
        -- Flame effect crawl
        local dist=0
        TimerStart(t, 0.15, true, function()
            -- Protect units from being damage multiple times in one flame round
            local protgroup = CreateGroup()
            -- Draw a 'circle' of flames at current distance
            local ang = 0
            while (ang < 2 * BJ_PI)
            do
                -- SFX
                local new_x = x + dist * math.cos(ang)
                local new_y = y + dist * math.sin(ang)
		        DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", new_x , new_y))
                -- area damage around each flame spout
                GroupEnumUnitsInRange(ug, new_x, new_y, 150, nil)
                ForGroup(ug, function()
                    local enemy = GetEnumUnit()
                    if (IsUnitEnemy(u, GetOwningPlayer(enemy)) and not IsUnitInGroup(enemy, protgroup)) then
                        UnitDamageTarget(u, enemy, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
                        GroupAddUnit(protgroup, enemy) 
                    end
                end)
                ang = ang + tonguesteps
            end
            DestroyGroup(protgroup)
            -- Advance distance ; Check if we've reached the max
            dist = dist + 100
            if (dist >= area) then
                DestroyGroup(ug)
                PauseTimer(t)
                DestroyTimer(t)
            end
        end)
        -- END --
    end
    

end